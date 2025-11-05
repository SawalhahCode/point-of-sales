import { Request, Response } from 'express';
import { DeliveryService } from '../services/delivery.service';
import {
  CreateDeliveryDto,
  AssignDriverDto,
  UpdateDeliveryStatusDto,
  CreateDriverDto
} from '../dtos/delivery.dto';
import { asyncHandler } from '../../../shared/middleware/errorHandler';
import { DeliveryStatus } from '../../../shared/types/common.types';

export class DeliveryController {
  constructor(private deliveryService: DeliveryService) {}

  // Delivery endpoints
  createDelivery = asyncHandler(async (req: Request, res: Response) => {
    const dto: CreateDeliveryDto = req.body;
    const delivery = await this.deliveryService.createDelivery(dto);

    res.status(201).json({
      success: true,
      message: 'Delivery created successfully',
      data: delivery
    });
  });

  getDelivery = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const delivery = await this.deliveryService.getDeliveryById(id);

    res.json({
      success: true,
      data: delivery
    });
  });

  getDeliveryByNumber = asyncHandler(async (req: Request, res: Response) => {
    const { deliveryNumber } = req.params;
    const delivery = await this.deliveryService.getDeliveryByNumber(deliveryNumber);

    res.json({
      success: true,
      data: delivery
    });
  });

  getDeliveryByOrderId = asyncHandler(async (req: Request, res: Response) => {
    const { orderId } = req.params;
    const delivery = await this.deliveryService.getDeliveryByOrderId(orderId);

    res.json({
      success: true,
      data: delivery
    });
  });

  getAllDeliveries = asyncHandler(async (req: Request, res: Response) => {
    const filters = {
      status: req.query.status as DeliveryStatus | undefined,
      driverId: req.query.driverId as string | undefined,
      fromDate: req.query.fromDate ? new Date(req.query.fromDate as string) : undefined,
      toDate: req.query.toDate ? new Date(req.query.toDate as string) : undefined
    };

    const deliveries = await this.deliveryService.getAllDeliveries(filters);

    res.json({
      success: true,
      data: deliveries,
      count: deliveries.length
    });
  });

  assignDriver = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const dto: AssignDriverDto = req.body;

    const delivery = await this.deliveryService.assignDriver(id, dto);

    res.json({
      success: true,
      message: 'Driver assigned successfully',
      data: delivery
    });
  });

  updateDeliveryStatus = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const dto: UpdateDeliveryStatusDto = req.body;

    const delivery = await this.deliveryService.updateDeliveryStatus(id, dto);

    res.json({
      success: true,
      message: 'Delivery status updated successfully',
      data: delivery
    });
  });

  getTrackingHistory = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const tracking = await this.deliveryService.getTrackingHistory(id);

    res.json({
      success: true,
      data: tracking
    });
  });

  // Driver endpoints
  createDriver = asyncHandler(async (req: Request, res: Response) => {
    const dto: CreateDriverDto = req.body;
    const driver = await this.deliveryService.createDriver(dto);

    res.status(201).json({
      success: true,
      message: 'Driver created successfully',
      data: driver
    });
  });

  getDriver = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const driver = await this.deliveryService.getDriverById(id);

    res.json({
      success: true,
      data: driver
    });
  });

  getAllDrivers = asyncHandler(async (req: Request, res: Response) => {
    const availableOnly = req.query.available === 'true';
    const drivers = await this.deliveryService.getAllDrivers(availableOnly);

    res.json({
      success: true,
      data: drivers,
      count: drivers.length
    });
  });

  updateDriverAvailability = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { isAvailable } = req.body;

    const driver = await this.deliveryService.updateDriverAvailability(id, isAvailable);

    res.json({
      success: true,
      message: 'Driver availability updated successfully',
      data: driver
    });
  });
}
