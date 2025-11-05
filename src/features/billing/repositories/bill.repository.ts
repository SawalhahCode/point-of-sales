import { Bill } from '../models/bill.model';
import { PaymentStatus } from '../../../shared/types/common.types';

export class BillRepository {
  private bills: Map<string, Bill> = new Map();

  async create(bill: Bill): Promise<Bill> {
    this.bills.set(bill.id, bill);
    return bill;
  }

  async findById(id: string): Promise<Bill | null> {
    return this.bills.get(id) || null;
  }

  async findByBillNumber(billNumber: string): Promise<Bill | null> {
    const bills = Array.from(this.bills.values());
    return bills.find(bill => bill.billNumber === billNumber) || null;
  }

  async findByOrderId(orderId: string): Promise<Bill | null> {
    const bills = Array.from(this.bills.values());
    return bills.find(bill => bill.orderId === orderId) || null;
  }

  async findAll(filters?: {
    paymentStatus?: PaymentStatus;
    fromDate?: Date;
    toDate?: Date;
  }): Promise<Bill[]> {
    let bills = Array.from(this.bills.values());

    if (filters?.paymentStatus) {
      bills = bills.filter(bill => bill.paymentStatus === filters.paymentStatus);
    }

    if (filters?.fromDate) {
      bills = bills.filter(bill => bill.createdAt >= filters.fromDate!);
    }

    if (filters?.toDate) {
      bills = bills.filter(bill => bill.createdAt <= filters.toDate!);
    }

    return bills.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  async update(id: string, updates: Partial<Bill>): Promise<Bill | null> {
    const bill = this.bills.get(id);
    if (!bill) {
      return null;
    }

    const updatedBill = { ...bill, ...updates, updatedAt: new Date() };
    this.bills.set(id, updatedBill);
    return updatedBill;
  }

  async delete(id: string): Promise<boolean> {
    return this.bills.delete(id);
  }

  async getTotalRevenue(fromDate?: Date, toDate?: Date): Promise<number> {
    let bills = Array.from(this.bills.values()).filter(
      bill => bill.paymentStatus === PaymentStatus.PAID
    );

    if (fromDate) {
      bills = bills.filter(bill => bill.paidAt && bill.paidAt >= fromDate);
    }

    if (toDate) {
      bills = bills.filter(bill => bill.paidAt && bill.paidAt <= toDate);
    }

    return bills.reduce((sum, bill) => sum + bill.total, 0);
  }
}
