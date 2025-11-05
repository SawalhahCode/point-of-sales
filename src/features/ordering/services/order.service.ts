import { v4 as uuidv4 } from 'uuid';
import { OrderRepository } from '../repositories/order.repository';
import { Order, OrderItem } from '../models/order.model';
import { CreateOrderDto, UpdateOrderDto } from '../dtos/order.dto';
import { OrderStatus } from '../../../shared/types/common.types';
import { validate } from '../../../shared/utils/validation';
import { AppError } from '../../../shared/middleware/errorHandler';
import { logger } from '../../../shared/utils/logger';

export class OrderService {
  private repository: OrderRepository;
  private orderCounter: number = 1000;
  private readonly TAX_RATE = parseFloat(process.env.RESTAURANT_TAX_RATE || '0.08');

  constructor(repository: OrderRepository) {
    this.repository = repository;
  }

  private generateOrderNumber(): string {
    this.orderCounter++;
    return `ORD-${this.orderCounter}`;
  }

  private calculateOrderTotals(items: OrderItem[]): {
    subtotal: number;
    tax: number;
    total: number;
  } {
    const subtotal = items.reduce((sum, item) => sum + item.subtotal, 0);
    const tax = subtotal * this.TAX_RATE;
    const total = subtotal + tax;

    return {
      subtotal: Math.round(subtotal * 100) / 100,
      tax: Math.round(tax * 100) / 100,
      total: Math.round(total * 100) / 100
    };
  }

  private validateOrderItems(items: any[]): void {
    if (!items || items.length === 0) {
      throw new AppError(400, 'Order must contain at least one item');
    }

    items.forEach((item, index) => {
      validate.required(item.menuItemId, `Item ${index + 1} menuItemId`);
      validate.required(item.name, `Item ${index + 1} name`);
      validate.positiveNumber(item.quantity, `Item ${index + 1} quantity`);
      validate.positiveNumber(item.unitPrice, `Item ${index + 1} unitPrice`);
    });
  }

  async createOrder(dto: CreateOrderDto): Promise<Order> {
    try {
      // Validate customer
      validate.required(dto.customer.name, 'Customer name');
      validate.required(dto.customer.phone, 'Customer phone');

      if (dto.customer.email && !validate.email(dto.customer.email)) {
        throw new AppError(400, 'Invalid email format');
      }

      if (!validate.phone(dto.customer.phone)) {
        throw new AppError(400, 'Invalid phone number format');
      }

      // Validate items
      this.validateOrderItems(dto.items);

      // Validate order type
      const validOrderTypes = ['dine-in', 'takeout', 'delivery'];
      if (!validOrderTypes.includes(dto.orderType)) {
        throw new AppError(400, 'Invalid order type');
      }

      // Create order items
      const orderItems: OrderItem[] = dto.items.map(item => {
        const modifiersCost = item.modifiers?.reduce((sum, mod) => sum + mod.price, 0) || 0;
        const subtotal = (item.unitPrice + modifiersCost) * item.quantity;

        return {
          id: uuidv4(),
          menuItemId: item.menuItemId,
          name: item.name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          subtotal: Math.round(subtotal * 100) / 100,
          specialInstructions: item.specialInstructions,
          modifiers: item.modifiers
        };
      });

      // Calculate totals
      const { subtotal, tax, total } = this.calculateOrderTotals(orderItems);

      // Create order
      const order: Order = {
        id: uuidv4(),
        orderNumber: this.generateOrderNumber(),
        customer: {
          id: uuidv4(),
          name: dto.customer.name,
          email: dto.customer.email,
          phone: dto.customer.phone,
          address: dto.customer.address
        },
        items: orderItems,
        subtotal,
        tax,
        total,
        status: OrderStatus.PENDING,
        orderType: dto.orderType,
        tableNumber: dto.tableNumber,
        specialInstructions: dto.specialInstructions,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      const createdOrder = await this.repository.create(order);
      logger.info(`Order created: ${createdOrder.orderNumber}`);

      return createdOrder;
    } catch (error) {
      logger.error('Error creating order:', error);
      throw error;
    }
  }

  async getOrderById(id: string): Promise<Order> {
    const order = await this.repository.findById(id);
    if (!order) {
      throw new AppError(404, 'Order not found');
    }
    return order;
  }

  async getOrderByNumber(orderNumber: string): Promise<Order> {
    const order = await this.repository.findByOrderNumber(orderNumber);
    if (!order) {
      throw new AppError(404, 'Order not found');
    }
    return order;
  }

  async getAllOrders(filters?: any): Promise<Order[]> {
    return await this.repository.findAll(filters);
  }

  async updateOrderStatus(id: string, status: OrderStatus): Promise<Order> {
    validate.isEnum(status, OrderStatus, 'Status');

    const order = await this.getOrderById(id);

    const updates: Partial<Order> = { status };
    if (status === OrderStatus.COMPLETED) {
      updates.completedAt = new Date();
    }

    const updatedOrder = await this.repository.update(id, updates);
    if (!updatedOrder) {
      throw new AppError(404, 'Order not found');
    }

    logger.info(`Order ${order.orderNumber} status updated to ${status}`);
    return updatedOrder;
  }

  async cancelOrder(id: string, reason?: string): Promise<Order> {
    const order = await this.getOrderById(id);

    if (order.status === OrderStatus.COMPLETED) {
      throw new AppError(400, 'Cannot cancel completed order');
    }

    const updatedOrder = await this.repository.update(id, {
      status: OrderStatus.CANCELLED
    });

    if (!updatedOrder) {
      throw new AppError(404, 'Order not found');
    }

    logger.info(`Order ${order.orderNumber} cancelled. Reason: ${reason || 'Not specified'}`);
    return updatedOrder;
  }

  async getActiveOrdersCount(): Promise<number> {
    return await this.repository.getActiveOrdersCount();
  }
}
