import { Order } from '../models/order.model';
import { OrderStatus } from '../../../shared/types/common.types';

// In-memory storage for demonstration
// Replace with actual database implementation
export class OrderRepository {
  private orders: Map<string, Order> = new Map();

  async create(order: Order): Promise<Order> {
    this.orders.set(order.id, order);
    return order;
  }

  async findById(id: string): Promise<Order | null> {
    return this.orders.get(id) || null;
  }

  async findByOrderNumber(orderNumber: string): Promise<Order | null> {
    const orders = Array.from(this.orders.values());
    return orders.find(order => order.orderNumber === orderNumber) || null;
  }

  async findAll(filters?: {
    status?: OrderStatus;
    orderType?: string;
    fromDate?: Date;
    toDate?: Date;
  }): Promise<Order[]> {
    let orders = Array.from(this.orders.values());

    if (filters?.status) {
      orders = orders.filter(order => order.status === filters.status);
    }

    if (filters?.orderType) {
      orders = orders.filter(order => order.orderType === filters.orderType);
    }

    if (filters?.fromDate) {
      orders = orders.filter(order => order.createdAt >= filters.fromDate!);
    }

    if (filters?.toDate) {
      orders = orders.filter(order => order.createdAt <= filters.toDate!);
    }

    return orders.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  async update(id: string, updates: Partial<Order>): Promise<Order | null> {
    const order = this.orders.get(id);
    if (!order) {
      return null;
    }

    const updatedOrder = { ...order, ...updates, updatedAt: new Date() };
    this.orders.set(id, updatedOrder);
    return updatedOrder;
  }

  async delete(id: string): Promise<boolean> {
    return this.orders.delete(id);
  }

  async getActiveOrdersCount(): Promise<number> {
    const orders = Array.from(this.orders.values());
    return orders.filter(order =>
      order.status !== OrderStatus.COMPLETED &&
      order.status !== OrderStatus.CANCELLED
    ).length;
  }
}
