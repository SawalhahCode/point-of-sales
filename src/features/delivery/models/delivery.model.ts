import { DeliveryStatus, Address } from '../../../shared/types/common.types';

export interface DeliveryDriver {
  id: string;
  name: string;
  phone: string;
  vehicleType: string;
  vehicleNumber: string;
  isAvailable: boolean;
  currentLocation?: {
    latitude: number;
    longitude: number;
  };
}

export interface DeliveryLocation {
  address: Address;
  coordinates?: {
    latitude: number;
    longitude: number;
  };
  instructions?: string;
}

export interface Delivery {
  id: string;
  deliveryNumber: string;
  orderId: string;
  driver?: DeliveryDriver;
  pickupLocation: DeliveryLocation;
  deliveryLocation: DeliveryLocation;
  status: DeliveryStatus;
  estimatedPickupTime?: Date;
  actualPickupTime?: Date;
  estimatedDeliveryTime?: Date;
  actualDeliveryTime?: Date;
  distance?: number; // in kilometers
  deliveryFee: number;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface DeliveryTracking {
  deliveryId: string;
  timestamp: Date;
  status: DeliveryStatus;
  location?: {
    latitude: number;
    longitude: number;
  };
  message: string;
}
