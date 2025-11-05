import { Request, Response } from 'express';
import { ReservationService } from '../services/reservation.service';
import {
  CreateReservationDto,
  UpdateReservationDto,
  AssignTableDto,
  CreateTableDto,
  UpdateTableDto,
  CheckAvailabilityDto
} from '../dtos/reservation.dto';
import { asyncHandler } from '../../../shared/middleware/errorHandler';
import { ReservationStatus, TableStatus } from '../../../shared/types/common.types';

export class ReservationController {
  constructor(private reservationService: ReservationService) {}

  // Reservation endpoints
  createReservation = asyncHandler(async (req: Request, res: Response) => {
    const dto: CreateReservationDto = req.body;
    const reservation = await this.reservationService.createReservation(dto);

    res.status(201).json({
      success: true,
      message: 'Reservation created successfully',
      data: reservation
    });
  });

  getReservation = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const reservation = await this.reservationService.getReservationById(id);

    res.json({
      success: true,
      data: reservation
    });
  });

  getReservationByNumber = asyncHandler(async (req: Request, res: Response) => {
    const { reservationNumber } = req.params;
    const reservation = await this.reservationService.getReservationByNumber(reservationNumber);

    res.json({
      success: true,
      data: reservation
    });
  });

  getAllReservations = asyncHandler(async (req: Request, res: Response) => {
    const filters = {
      status: req.query.status as ReservationStatus | undefined,
      date: req.query.date ? new Date(req.query.date as string) : undefined,
      customerId: req.query.customerId as string | undefined,
      fromDate: req.query.fromDate ? new Date(req.query.fromDate as string) : undefined,
      toDate: req.query.toDate ? new Date(req.query.toDate as string) : undefined
    };

    const reservations = await this.reservationService.getAllReservations(filters);

    res.json({
      success: true,
      data: reservations,
      count: reservations.length
    });
  });

  updateReservation = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const dto: UpdateReservationDto = req.body;

    const reservation = await this.reservationService.updateReservation(id, dto);

    res.json({
      success: true,
      message: 'Reservation updated successfully',
      data: reservation
    });
  });

  confirmReservation = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const reservation = await this.reservationService.confirmReservation(id);

    res.json({
      success: true,
      message: 'Reservation confirmed successfully',
      data: reservation
    });
  });

  cancelReservation = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { reason } = req.body;

    const reservation = await this.reservationService.cancelReservation(id, reason);

    res.json({
      success: true,
      message: 'Reservation cancelled successfully',
      data: reservation
    });
  });

  assignTable = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const dto: AssignTableDto = req.body;

    const reservation = await this.reservationService.assignTable(id, dto);

    res.json({
      success: true,
      message: 'Table assigned successfully',
      data: reservation
    });
  });

  seatReservation = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const reservation = await this.reservationService.seatReservation(id);

    res.json({
      success: true,
      message: 'Guests seated successfully',
      data: reservation
    });
  });

  completeReservation = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const reservation = await this.reservationService.completeReservation(id);

    res.json({
      success: true,
      message: 'Reservation completed successfully',
      data: reservation
    });
  });

  checkAvailability = asyncHandler(async (req: Request, res: Response) => {
    const dto: CheckAvailabilityDto = {
      date: new Date(req.query.date as string),
      time: req.query.time as string,
      partySize: parseInt(req.query.partySize as string)
    };

    const availability = await this.reservationService.checkAvailability(dto);

    res.json({
      success: true,
      data: availability
    });
  });

  // Table endpoints
  createTable = asyncHandler(async (req: Request, res: Response) => {
    const dto: CreateTableDto = req.body;
    const table = await this.reservationService.createTable(dto);

    res.status(201).json({
      success: true,
      message: 'Table created successfully',
      data: table
    });
  });

  getTable = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const table = await this.reservationService.getTableById(id);

    res.json({
      success: true,
      data: table
    });
  });

  getAllTables = asyncHandler(async (req: Request, res: Response) => {
    const filters = {
      status: req.query.status as TableStatus | undefined,
      minCapacity: req.query.minCapacity ? parseInt(req.query.minCapacity as string) : undefined,
      location: req.query.location as string | undefined
    };

    const tables = await this.reservationService.getAllTables(filters);

    res.json({
      success: true,
      data: tables,
      count: tables.length
    });
  });

  updateTable = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const dto: UpdateTableDto = req.body;

    const table = await this.reservationService.updateTable(id, dto);

    res.json({
      success: true,
      message: 'Table updated successfully',
      data: table
    });
  });

  updateTableStatus = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { status } = req.body;

    const table = await this.reservationService.updateTableStatus(id, status);

    res.json({
      success: true,
      message: 'Table status updated successfully',
      data: table
    });
  });
}
