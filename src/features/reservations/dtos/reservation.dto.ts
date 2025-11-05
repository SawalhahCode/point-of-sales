import { ReservationStatus, TableStatus } from '../../../shared/types/common.types';

export interface CreateReservationDto {
  customer: {
    name: string;
    email?: string;
    phone: string;
  };
  partySize: number;
  reservationDate: Date;
  reservationTime: string; // HH:MM format
  duration?: number; // default 90 minutes
  specialRequests?: string;
  occasion?: string;
}

export interface UpdateReservationDto {
  partySize?: number;
  reservationDate?: Date;
  reservationTime?: string;
  specialRequests?: string;
  status?: ReservationStatus;
}

export interface AssignTableDto {
  tableId: string;
}

export interface CreateTableDto {
  tableNumber: number;
  capacity: number;
  location?: string;
  features?: string[];
}

export interface UpdateTableDto {
  capacity?: number;
  status?: TableStatus;
  location?: string;
  features?: string[];
}

export interface CheckAvailabilityDto {
  date: Date;
  time: string;
  partySize: number;
}

export interface ReservationResponseDto {
  id: string;
  reservationNumber: string;
  customer: {
    name: string;
    phone: string;
  };
  partySize: number;
  reservationDate: Date;
  reservationTime: string;
  status: ReservationStatus;
  table?: {
    tableNumber: number;
    capacity: number;
  };
  specialRequests?: string;
  createdAt: Date;
}
