import { v4 as uuidv4 } from 'uuid';
import { BillRepository } from '../repositories/bill.repository';
import { Bill, Payment } from '../models/bill.model';
import { CreateBillDto, AddPaymentDto, ApplyDiscountDto } from '../dtos/bill.dto';
import { PaymentStatus, PaymentMethod } from '../../../shared/types/common.types';
import { validate } from '../../../shared/utils/validation';
import { AppError } from '../../../shared/middleware/errorHandler';
import { logger } from '../../../shared/utils/logger';

// Note: In a real application, you would inject OrderService or use an event-driven approach
// For this example, we'll assume we can get order data
interface OrderData {
  id: string;
  subtotal: number;
  tax: number;
  total: number;
}

export class BillService {
  private repository: BillRepository;
  private billCounter: number = 5000;

  constructor(repository: BillRepository) {
    this.repository = repository;
  }

  private generateBillNumber(): string {
    this.billCounter++;
    return `BILL-${this.billCounter}`;
  }

  private calculateTotal(subtotal: number, tax: number, discount: number, tip: number): number {
    const total = subtotal + tax - discount + tip;
    return Math.round(total * 100) / 100;
  }

  async createBill(dto: CreateBillDto, orderData: OrderData): Promise<Bill> {
    try {
      validate.required(dto.orderId, 'Order ID');

      // Check if bill already exists for this order
      const existingBill = await this.repository.findByOrderId(dto.orderId);
      if (existingBill) {
        throw new AppError(400, 'Bill already exists for this order');
      }

      const tip = dto.tip || 0;
      if (tip < 0) {
        throw new AppError(400, 'Tip cannot be negative');
      }

      const total = this.calculateTotal(
        orderData.subtotal,
        orderData.tax,
        0, // no discount initially
        tip
      );

      const bill: Bill = {
        id: uuidv4(),
        billNumber: this.generateBillNumber(),
        orderId: dto.orderId,
        subtotal: orderData.subtotal,
        tax: orderData.tax,
        discount: 0,
        tip,
        total,
        amountPaid: 0,
        amountDue: total,
        paymentStatus: PaymentStatus.PENDING,
        payments: [],
        notes: dto.notes,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      const createdBill = await this.repository.create(bill);
      logger.info(`Bill created: ${createdBill.billNumber} for order ${dto.orderId}`);

      return createdBill;
    } catch (error) {
      logger.error('Error creating bill:', error);
      throw error;
    }
  }

  async getBillById(id: string): Promise<Bill> {
    const bill = await this.repository.findById(id);
    if (!bill) {
      throw new AppError(404, 'Bill not found');
    }
    return bill;
  }

  async getBillByNumber(billNumber: string): Promise<Bill> {
    const bill = await this.repository.findByBillNumber(billNumber);
    if (!bill) {
      throw new AppError(404, 'Bill not found');
    }
    return bill;
  }

  async getBillByOrderId(orderId: string): Promise<Bill> {
    const bill = await this.repository.findByOrderId(orderId);
    if (!bill) {
      throw new AppError(404, 'Bill not found for this order');
    }
    return bill;
  }

  async getAllBills(filters?: any): Promise<Bill[]> {
    return await this.repository.findAll(filters);
  }

  async addPayment(billId: string, dto: AddPaymentDto): Promise<Bill> {
    validate.positiveNumber(dto.amount, 'Payment amount');
    validate.isEnum(dto.method, PaymentMethod, 'Payment method');

    const bill = await this.getBillById(billId);

    if (bill.paymentStatus === PaymentStatus.PAID) {
      throw new AppError(400, 'Bill is already fully paid');
    }

    if (dto.amount > bill.amountDue) {
      throw new AppError(400, `Payment amount exceeds amount due ($${bill.amountDue})`);
    }

    const payment: Payment = {
      id: uuidv4(),
      amount: dto.amount,
      method: dto.method,
      transactionId: dto.transactionId,
      processedAt: new Date()
    };

    const amountPaid = bill.amountPaid + dto.amount;
    const amountDue = bill.total - amountPaid;

    let paymentStatus: PaymentStatus;
    if (amountDue === 0) {
      paymentStatus = PaymentStatus.PAID;
    } else if (amountPaid > 0) {
      paymentStatus = PaymentStatus.PARTIALLY_PAID;
    } else {
      paymentStatus = PaymentStatus.PENDING;
    }

    const updates: Partial<Bill> = {
      payments: [...bill.payments, payment],
      amountPaid,
      amountDue,
      paymentStatus,
      ...(paymentStatus === PaymentStatus.PAID && { paidAt: new Date() })
    };

    const updatedBill = await this.repository.update(billId, updates);
    if (!updatedBill) {
      throw new AppError(404, 'Bill not found');
    }

    logger.info(
      `Payment of $${dto.amount} added to bill ${bill.billNumber}. Status: ${paymentStatus}`
    );

    return updatedBill;
  }

  async applyDiscount(billId: string, dto: ApplyDiscountDto): Promise<Bill> {
    const bill = await this.getBillById(billId);

    if (bill.paymentStatus === PaymentStatus.PAID) {
      throw new AppError(400, 'Cannot apply discount to paid bill');
    }

    let discountAmount: number;

    if (dto.discountType === 'percentage') {
      if (dto.discountValue < 0 || dto.discountValue > 100) {
        throw new AppError(400, 'Percentage discount must be between 0 and 100');
      }
      discountAmount = (bill.subtotal * dto.discountValue) / 100;
    } else {
      if (dto.discountValue < 0 || dto.discountValue > bill.subtotal) {
        throw new AppError(400, 'Fixed discount cannot exceed subtotal');
      }
      discountAmount = dto.discountValue;
    }

    discountAmount = Math.round(discountAmount * 100) / 100;

    const newTotal = this.calculateTotal(
      bill.subtotal,
      bill.tax,
      discountAmount,
      bill.tip
    );

    const amountDue = newTotal - bill.amountPaid;

    const updates: Partial<Bill> = {
      discount: discountAmount,
      total: newTotal,
      amountDue
    };

    const updatedBill = await this.repository.update(billId, updates);
    if (!updatedBill) {
      throw new AppError(404, 'Bill not found');
    }

    logger.info(
      `Discount of $${discountAmount} applied to bill ${bill.billNumber}. Reason: ${dto.reason || 'Not specified'}`
    );

    return updatedBill;
  }

  async refundPayment(billId: string, paymentId: string, reason?: string): Promise<Bill> {
    const bill = await this.getBillById(billId);

    const payment = bill.payments.find(p => p.id === paymentId);
    if (!payment) {
      throw new AppError(404, 'Payment not found');
    }

    const amountPaid = bill.amountPaid - payment.amount;
    const amountDue = bill.total - amountPaid;

    const updates: Partial<Bill> = {
      payments: bill.payments.filter(p => p.id !== paymentId),
      amountPaid,
      amountDue,
      paymentStatus: amountPaid === 0 ? PaymentStatus.REFUNDED : PaymentStatus.PARTIALLY_PAID,
      paidAt: undefined
    };

    const updatedBill = await this.repository.update(billId, updates);
    if (!updatedBill) {
      throw new AppError(404, 'Bill not found');
    }

    logger.info(
      `Payment of $${payment.amount} refunded from bill ${bill.billNumber}. Reason: ${reason || 'Not specified'}`
    );

    return updatedBill;
  }

  async getTotalRevenue(fromDate?: Date, toDate?: Date): Promise<number> {
    return await this.repository.getTotalRevenue(fromDate, toDate);
  }
}
