import { Request, Response } from 'express';
import { OrderService } from '../services/order.service';
import { CreateOrderDto, UpdateOrderDto } from '../dtos/order.dto';
import { asyncHandler } from '../../../shared/middleware/errorHandler';
import { OrderStatus } from '../../../shared/types/common.types';

export class OrderController {
  constructor(private orderService: OrderService) {}

  createOrder = asyncHandler(async (req: Request, res: Response) => {
    const dto: CreateOrderDto = req.body;
    const order = await this.orderService.createOrder(dto);

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: order
    });
  });

  getOrder = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const order = await this.orderService.getOrderById(id);

    res.json({
      success: true,
      data: order
    });
  });

  getOrderByNumber = asyncHandler(async (req: Request, res: Response) => {
    const { orderNumber } = req.params;
    const order = await this.orderService.getOrderByNumber(orderNumber);

    res.json({
      success: true,
      data: order
    });
  });

  getAllOrders = asyncHandler(async (req: Request, res: Response) => {
    const filters = {
      status: req.query.status as OrderStatus | undefined,
      orderType: req.query.orderType as string | undefined,
      fromDate: req.query.fromDate ? new Date(req.query.fromDate as string) : undefined,
      toDate: req.query.toDate ? new Date(req.query.toDate as string) : undefined
    };

    const orders = await this.orderService.getAllOrders(filters);

    res.json({
      success: true,
      data: orders,
      count: orders.length
    });
  });

  updateOrderStatus = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { status } = req.body;

    const order = await this.orderService.updateOrderStatus(id, status);

    res.json({
      success: true,
      message: 'Order status updated successfully',
      data: order
    });
  });

  cancelOrder = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { reason } = req.body;

    const order = await this.orderService.cancelOrder(id, reason);

    res.json({
      success: true,
      message: 'Order cancelled successfully',
      data: order
    });
  });

  getActiveOrdersCount = asyncHandler(async (req: Request, res: Response) => {
    const count = await this.orderService.getActiveOrdersCount();

    res.json({
      success: true,
      data: { activeOrders: count }
    });
  });
}
