import { ReservationStatus, Customer, TableStatus } from '../../../shared/types/common.types';

export interface Table {
  id: string;
  tableNumber: number;
  capacity: number;
  status: TableStatus;
  location?: string; // e.g., 'window', 'patio', 'indoor'
  features?: string[]; // e.g., ['wheelchair accessible', 'near window']
}

export interface Reservation {
  id: string;
  reservationNumber: string;
  customer: Customer;
  partySize: number;
  reservationDate: Date;
  reservationTime: string; // e.g., '18:30'
  duration: number; // in minutes
  status: ReservationStatus;
  table?: Table;
  specialRequests?: string;
  occasion?: string; // e.g., 'birthday', 'anniversary'
  arrivalTime?: Date;
  seatedTime?: Date;
  completedTime?: Date;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface TableAvailability {
  table: Table;
  isAvailable: boolean;
  nextAvailableTime?: string;
}
