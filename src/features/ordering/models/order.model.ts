import { OrderStatus, Customer } from '../../../shared/types/common.types';

export interface OrderItem {
  id: string;
  menuItemId: string;
  name: string;
  quantity: number;
  unitPrice: number;
  subtotal: number;
  specialInstructions?: string;
  modifiers?: OrderModifier[];
}

export interface OrderModifier {
  id: string;
  name: string;
  price: number;
}

export interface Order {
  id: string;
  orderNumber: string;
  customer: Customer;
  items: OrderItem[];
  subtotal: number;
  tax: number;
  total: number;
  status: OrderStatus;
  tableNumber?: number;
  orderType: 'dine-in' | 'takeout' | 'delivery';
  specialInstructions?: string;
  createdAt: Date;
  updatedAt: Date;
  completedAt?: Date;
}
