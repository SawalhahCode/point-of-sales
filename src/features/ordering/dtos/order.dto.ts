import { OrderStatus } from '../../../shared/types/common.types';

export interface CreateOrderItemDto {
  menuItemId: string;
  name: string;
  quantity: number;
  unitPrice: number;
  specialInstructions?: string;
  modifiers?: {
    id: string;
    name: string;
    price: number;
  }[];
}

export interface CreateOrderDto {
  customer: {
    name: string;
    email?: string;
    phone: string;
    address?: {
      street: string;
      city: string;
      state: string;
      zipCode: string;
      country: string;
    };
  };
  items: CreateOrderItemDto[];
  tableNumber?: number;
  orderType: 'dine-in' | 'takeout' | 'delivery';
  specialInstructions?: string;
}

export interface UpdateOrderDto {
  status?: OrderStatus;
  items?: CreateOrderItemDto[];
  specialInstructions?: string;
}

export interface OrderResponseDto {
  id: string;
  orderNumber: string;
  customer: {
    name: string;
    phone: string;
  };
  items: {
    id: string;
    name: string;
    quantity: number;
    unitPrice: number;
    subtotal: number;
  }[];
  subtotal: number;
  tax: number;
  total: number;
  status: OrderStatus;
  orderType: string;
  tableNumber?: number;
  createdAt: Date;
}
