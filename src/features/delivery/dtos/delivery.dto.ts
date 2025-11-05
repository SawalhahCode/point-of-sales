import { DeliveryStatus, Address } from '../../../shared/types/common.types';

export interface CreateDeliveryDto {
  orderId: string;
  deliveryAddress: Address;
  deliveryInstructions?: string;
  estimatedDeliveryTime?: Date;
  notes?: string;
}

export interface AssignDriverDto {
  driverId: string;
}

export interface UpdateDeliveryStatusDto {
  status: DeliveryStatus;
  location?: {
    latitude: number;
    longitude: number;
  };
  notes?: string;
}

export interface CreateDriverDto {
  name: string;
  phone: string;
  vehicleType: string;
  vehicleNumber: string;
}

export interface DeliveryResponseDto {
  id: string;
  deliveryNumber: string;
  orderId: string;
  driver?: {
    id: string;
    name: string;
    phone: string;
    vehicleType: string;
  };
  deliveryAddress: Address;
  status: DeliveryStatus;
  estimatedDeliveryTime?: Date;
  actualDeliveryTime?: Date;
  deliveryFee: number;
  createdAt: Date;
}
