import { Reservation, Table, TableAvailability } from '../models/reservation.model';
import { ReservationStatus, TableStatus } from '../../../shared/types/common.types';

export class ReservationRepository {
  private reservations: Map<string, Reservation> = new Map();
  private tables: Map<string, Table> = new Map();

  async createReservation(reservation: Reservation): Promise<Reservation> {
    this.reservations.set(reservation.id, reservation);
    return reservation;
  }

  async findReservationById(id: string): Promise<Reservation | null> {
    return this.reservations.get(id) || null;
  }

  async findReservationByNumber(reservationNumber: string): Promise<Reservation | null> {
    const reservations = Array.from(this.reservations.values());
    return reservations.find(r => r.reservationNumber === reservationNumber) || null;
  }

  async findAllReservations(filters?: {
    status?: ReservationStatus;
    date?: Date;
    customerId?: string;
    fromDate?: Date;
    toDate?: Date;
  }): Promise<Reservation[]> {
    let reservations = Array.from(this.reservations.values());

    if (filters?.status) {
      reservations = reservations.filter(r => r.status === filters.status);
    }

    if (filters?.date) {
      const targetDate = filters.date.toISOString().split('T')[0];
      reservations = reservations.filter(r => {
        const reservationDate = r.reservationDate.toISOString().split('T')[0];
        return reservationDate === targetDate;
      });
    }

    if (filters?.customerId) {
      reservations = reservations.filter(r => r.customer.id === filters.customerId);
    }

    if (filters?.fromDate) {
      reservations = reservations.filter(r => r.reservationDate >= filters.fromDate!);
    }

    if (filters?.toDate) {
      reservations = reservations.filter(r => r.reservationDate <= filters.toDate!);
    }

    return reservations.sort((a, b) =>
      a.reservationDate.getTime() - b.reservationDate.getTime()
    );
  }

  async updateReservation(id: string, updates: Partial<Reservation>): Promise<Reservation | null> {
    const reservation = this.reservations.get(id);
    if (!reservation) {
      return null;
    }

    const updatedReservation = { ...reservation, ...updates, updatedAt: new Date() };
    this.reservations.set(id, updatedReservation);
    return updatedReservation;
  }

  async deleteReservation(id: string): Promise<boolean> {
    return this.reservations.delete(id);
  }

  // Table methods
  async createTable(table: Table): Promise<Table> {
    this.tables.set(table.id, table);
    return table;
  }

  async findTableById(id: string): Promise<Table | null> {
    return this.tables.get(id) || null;
  }

  async findTableByNumber(tableNumber: number): Promise<Table | null> {
    const tables = Array.from(this.tables.values());
    return tables.find(t => t.tableNumber === tableNumber) || null;
  }

  async findAllTables(filters?: {
    status?: TableStatus;
    minCapacity?: number;
    location?: string;
  }): Promise<Table[]> {
    let tables = Array.from(this.tables.values());

    if (filters?.status) {
      tables = tables.filter(t => t.status === filters.status);
    }

    if (filters?.minCapacity) {
      tables = tables.filter(t => t.capacity >= filters.minCapacity);
    }

    if (filters?.location) {
      tables = tables.filter(t => t.location === filters.location);
    }

    return tables.sort((a, b) => a.tableNumber - b.tableNumber);
  }

  async updateTable(id: string, updates: Partial<Table>): Promise<Table | null> {
    const table = this.tables.get(id);
    if (!table) {
      return null;
    }

    const updatedTable = { ...table, ...updates };
    this.tables.set(id, updatedTable);
    return updatedTable;
  }

  async deleteTable(id: string): Promise<boolean> {
    return this.tables.delete(id);
  }

  async getReservationsForDateAndTime(date: Date, time: string): Promise<Reservation[]> {
    const reservations = Array.from(this.reservations.values());
    const targetDate = date.toISOString().split('T')[0];

    return reservations.filter(r => {
      const reservationDate = r.reservationDate.toISOString().split('T')[0];
      return (
        reservationDate === targetDate &&
        r.reservationTime === time &&
        r.status !== ReservationStatus.CANCELLED &&
        r.status !== ReservationStatus.NO_SHOW &&
        r.status !== ReservationStatus.COMPLETED
      );
    });
  }
}
