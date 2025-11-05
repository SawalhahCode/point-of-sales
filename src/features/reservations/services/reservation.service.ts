import { v4 as uuidv4 } from 'uuid';
import { ReservationRepository } from '../repositories/reservation.repository';
import { Reservation, Table, TableAvailability } from '../models/reservation.model';
import {
  CreateReservationDto,
  UpdateReservationDto,
  AssignTableDto,
  CreateTableDto,
  UpdateTableDto,
  CheckAvailabilityDto
} from '../dtos/reservation.dto';
import { ReservationStatus, TableStatus } from '../../../shared/types/common.types';
import { validate } from '../../../shared/utils/validation';
import { AppError } from '../../../shared/middleware/errorHandler';
import { logger } from '../../../shared/utils/logger';

export class ReservationService {
  private repository: ReservationRepository;
  private reservationCounter: number = 3000;
  private readonly DEFAULT_DURATION = 90; // minutes

  constructor(repository: ReservationRepository) {
    this.repository = repository;
  }

  private generateReservationNumber(): string {
    this.reservationCounter++;
    return `RES-${this.reservationCounter}`;
  }

  private validateTimeFormat(time: string): boolean {
    const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;
    return timeRegex.test(time);
  }

  async createReservation(dto: CreateReservationDto): Promise<Reservation> {
    try {
      // Validate customer
      validate.required(dto.customer.name, 'Customer name');
      validate.required(dto.customer.phone, 'Customer phone');

      if (dto.customer.email && !validate.email(dto.customer.email)) {
        throw new AppError(400, 'Invalid email format');
      }

      if (!validate.phone(dto.customer.phone)) {
        throw new AppError(400, 'Invalid phone number format');
      }

      // Validate party size
      validate.positiveNumber(dto.partySize, 'Party size');
      if (dto.partySize > 20) {
        throw new AppError(400, 'Party size cannot exceed 20 guests. Please contact for large groups.');
      }

      // Validate reservation date
      const reservationDate = new Date(dto.reservationDate);
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      if (reservationDate < today) {
        throw new AppError(400, 'Cannot create reservation for past dates');
      }

      // Validate time format
      if (!this.validateTimeFormat(dto.reservationTime)) {
        throw new AppError(400, 'Invalid time format. Use HH:MM (e.g., 18:30)');
      }

      const duration = dto.duration || this.DEFAULT_DURATION;
      if (duration < 30 || duration > 240) {
        throw new AppError(400, 'Duration must be between 30 and 240 minutes');
      }

      const reservation: Reservation = {
        id: uuidv4(),
        reservationNumber: this.generateReservationNumber(),
        customer: {
          id: uuidv4(),
          name: dto.customer.name,
          email: dto.customer.email,
          phone: dto.customer.phone
        },
        partySize: dto.partySize,
        reservationDate,
        reservationTime: dto.reservationTime,
        duration,
        status: ReservationStatus.PENDING,
        specialRequests: dto.specialRequests,
        occasion: dto.occasion,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      const createdReservation = await this.repository.createReservation(reservation);
      logger.info(
        `Reservation created: ${createdReservation.reservationNumber} for ${dto.customer.name} on ${dto.reservationDate}`
      );

      return createdReservation;
    } catch (error) {
      logger.error('Error creating reservation:', error);
      throw error;
    }
  }

  async getReservationById(id: string): Promise<Reservation> {
    const reservation = await this.repository.findReservationById(id);
    if (!reservation) {
      throw new AppError(404, 'Reservation not found');
    }
    return reservation;
  }

  async getReservationByNumber(reservationNumber: string): Promise<Reservation> {
    const reservation = await this.repository.findReservationByNumber(reservationNumber);
    if (!reservation) {
      throw new AppError(404, 'Reservation not found');
    }
    return reservation;
  }

  async getAllReservations(filters?: any): Promise<Reservation[]> {
    return await this.repository.findAllReservations(filters);
  }

  async updateReservation(id: string, dto: UpdateReservationDto): Promise<Reservation> {
    const reservation = await this.getReservationById(id);

    if (reservation.status === ReservationStatus.COMPLETED) {
      throw new AppError(400, 'Cannot update completed reservation');
    }

    if (dto.reservationTime && !this.validateTimeFormat(dto.reservationTime)) {
      throw new AppError(400, 'Invalid time format. Use HH:MM');
    }

    if (dto.partySize) {
      validate.positiveNumber(dto.partySize, 'Party size');
    }

    const updates: Partial<Reservation> = {};

    if (dto.partySize) updates.partySize = dto.partySize;
    if (dto.reservationDate) updates.reservationDate = new Date(dto.reservationDate);
    if (dto.reservationTime) updates.reservationTime = dto.reservationTime;
    if (dto.specialRequests !== undefined) updates.specialRequests = dto.specialRequests;
    if (dto.status) {
      validate.isEnum(dto.status, ReservationStatus, 'Status');
      updates.status = dto.status;
    }

    const updatedReservation = await this.repository.updateReservation(id, updates);
    if (!updatedReservation) {
      throw new AppError(404, 'Reservation not found');
    }

    logger.info(`Reservation ${reservation.reservationNumber} updated`);

    return updatedReservation;
  }

  async confirmReservation(id: string): Promise<Reservation> {
    return await this.updateReservation(id, { status: ReservationStatus.CONFIRMED });
  }

  async cancelReservation(id: string, reason?: string): Promise<Reservation> {
    const reservation = await this.getReservationById(id);

    if (reservation.status === ReservationStatus.COMPLETED) {
      throw new AppError(400, 'Cannot cancel completed reservation');
    }

    // Free up the table if assigned
    if (reservation.table) {
      await this.repository.updateTable(reservation.table.id, {
        status: TableStatus.AVAILABLE
      });
    }

    const updatedReservation = await this.repository.updateReservation(id, {
      status: ReservationStatus.CANCELLED
    });

    if (!updatedReservation) {
      throw new AppError(404, 'Reservation not found');
    }

    logger.info(
      `Reservation ${reservation.reservationNumber} cancelled. Reason: ${reason || 'Not specified'}`
    );

    return updatedReservation;
  }

  async assignTable(reservationId: string, dto: AssignTableDto): Promise<Reservation> {
    validate.required(dto.tableId, 'Table ID');

    const reservation = await this.getReservationById(reservationId);
    const table = await this.repository.findTableById(dto.tableId);

    if (!table) {
      throw new AppError(404, 'Table not found');
    }

    if (table.capacity < reservation.partySize) {
      throw new AppError(400, `Table capacity (${table.capacity}) is less than party size (${reservation.partySize})`);
    }

    if (table.status !== TableStatus.AVAILABLE && table.status !== TableStatus.RESERVED) {
      throw new AppError(400, 'Table is not available');
    }

    const updatedReservation = await this.repository.updateReservation(reservationId, {
      table,
      status: ReservationStatus.CONFIRMED
    });

    await this.repository.updateTable(dto.tableId, {
      status: TableStatus.RESERVED
    });

    if (!updatedReservation) {
      throw new AppError(404, 'Reservation not found');
    }

    logger.info(
      `Table ${table.tableNumber} assigned to reservation ${reservation.reservationNumber}`
    );

    return updatedReservation;
  }

  async seatReservation(id: string): Promise<Reservation> {
    const reservation = await this.getReservationById(id);

    if (!reservation.table) {
      throw new AppError(400, 'No table assigned to this reservation');
    }

    if (reservation.status !== ReservationStatus.CONFIRMED) {
      throw new AppError(400, 'Can only seat confirmed reservations');
    }

    const updates: Partial<Reservation> = {
      status: ReservationStatus.SEATED,
      seatedTime: new Date()
    };

    const updatedReservation = await this.repository.updateReservation(id, updates);

    await this.repository.updateTable(reservation.table.id, {
      status: TableStatus.OCCUPIED
    });

    if (!updatedReservation) {
      throw new AppError(404, 'Reservation not found');
    }

    logger.info(`Reservation ${reservation.reservationNumber} seated at table ${reservation.table.tableNumber}`);

    return updatedReservation;
  }

  async completeReservation(id: string): Promise<Reservation> {
    const reservation = await this.getReservationById(id);

    if (reservation.table) {
      await this.repository.updateTable(reservation.table.id, {
        status: TableStatus.CLEANING
      });
    }

    const updatedReservation = await this.repository.updateReservation(id, {
      status: ReservationStatus.COMPLETED,
      completedTime: new Date()
    });

    if (!updatedReservation) {
      throw new AppError(404, 'Reservation not found');
    }

    logger.info(`Reservation ${reservation.reservationNumber} completed`);

    return updatedReservation;
  }

  async checkAvailability(dto: CheckAvailabilityDto): Promise<TableAvailability[]> {
    validate.positiveNumber(dto.partySize, 'Party size');

    if (!this.validateTimeFormat(dto.time)) {
      throw new AppError(400, 'Invalid time format. Use HH:MM');
    }

    // Get all tables that can accommodate the party size
    const tables = await this.repository.findAllTables({
      minCapacity: dto.partySize
    });

    // Get reservations for this date and time
    const existingReservations = await this.repository.getReservationsForDateAndTime(
      dto.date,
      dto.time
    );

    const availability: TableAvailability[] = tables.map(table => {
      const isReserved = existingReservations.some(
        r => r.table?.id === table.id
      );

      return {
        table,
        isAvailable: !isReserved && table.status === TableStatus.AVAILABLE,
        nextAvailableTime: isReserved ? '20:00' : undefined // Mock data
      };
    });

    return availability;
  }

  // Table management
  async createTable(dto: CreateTableDto): Promise<Table> {
    validate.positiveNumber(dto.tableNumber, 'Table number');
    validate.positiveNumber(dto.capacity, 'Table capacity');

    // Check if table number already exists
    const existingTable = await this.repository.findTableByNumber(dto.tableNumber);
    if (existingTable) {
      throw new AppError(400, `Table ${dto.tableNumber} already exists`);
    }

    const table: Table = {
      id: uuidv4(),
      tableNumber: dto.tableNumber,
      capacity: dto.capacity,
      status: TableStatus.AVAILABLE,
      location: dto.location,
      features: dto.features
    };

    const createdTable = await this.repository.createTable(table);
    logger.info(`Table ${createdTable.tableNumber} created`);

    return createdTable;
  }

  async getTableById(id: string): Promise<Table> {
    const table = await this.repository.findTableById(id);
    if (!table) {
      throw new AppError(404, 'Table not found');
    }
    return table;
  }

  async getAllTables(filters?: any): Promise<Table[]> {
    return await this.repository.findAllTables(filters);
  }

  async updateTable(id: string, dto: UpdateTableDto): Promise<Table> {
    const table = await this.getTableById(id);

    if (dto.status) {
      validate.isEnum(dto.status, TableStatus, 'Status');
    }

    const updatedTable = await this.repository.updateTable(id, dto);
    if (!updatedTable) {
      throw new AppError(404, 'Table not found');
    }

    logger.info(`Table ${table.tableNumber} updated`);

    return updatedTable;
  }

  async updateTableStatus(id: string, status: TableStatus): Promise<Table> {
    return await this.updateTable(id, { status });
  }
}
