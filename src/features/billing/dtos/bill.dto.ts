import { PaymentMethod, PaymentStatus } from '../../../shared/types/common.types';

export interface CreateBillDto {
  orderId: string;
  tip?: number;
  discountCode?: string;
  notes?: string;
}

export interface AddPaymentDto {
  amount: number;
  method: PaymentMethod;
  transactionId?: string;
}

export interface ApplyDiscountDto {
  discountCode?: string;
  discountType: 'percentage' | 'fixed';
  discountValue: number;
  reason?: string;
}

export interface BillResponseDto {
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
  payments: {
    id: string;
    amount: number;
    method: PaymentMethod;
    processedAt: Date;
  }[];
  createdAt: Date;
}
