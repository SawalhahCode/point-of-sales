import { PaymentStatus, PaymentMethod } from '../../../shared/types/common.types';

export interface Payment {
  id: string;
  amount: number;
  method: PaymentMethod;
  transactionId?: string;
  processedAt: Date;
}

export interface Bill {
  id: string;
  billNumber: string;
  orderId: string;
  subtotal: number;
  tax: number;
  discount: number;
  tip: number;
  total: number;
  amountPaid: number;
  amountDue: number;
  paymentStatus: PaymentStatus;
  payments: Payment[];
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
  paidAt?: Date;
}

export interface DiscountRule {
  id: string;
  name: string;
  type: 'percentage' | 'fixed';
  value: number;
  minOrderAmount?: number;
  validFrom?: Date;
  validUntil?: Date;
  active: boolean;
}
