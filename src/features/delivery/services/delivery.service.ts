import { v4 as uuidv4 } from 'uuid';
import { DeliveryRepository } from '../repositories/delivery.repository';
import { Delivery, DeliveryDriver, DeliveryTracking } from '../models/delivery.model';
import {
  CreateDeliveryDto,
  AssignDriverDto,
  UpdateDeliveryStatusDto,
  CreateDriverDto
} from '../dtos/delivery.dto';
import { DeliveryStatus } from '../../../shared/types/common.types';
import { validate } from '../../../shared/utils/validation';
import { AppError } from '../../../shared/middleware/errorHandler';
import { logger } from '../../../shared/utils/logger';

export class DeliveryService {
  private repository: DeliveryRepository;
  private deliveryCounter: number = 7000;
  private readonly BASE_DELIVERY_FEE = 5.00;
  private readonly PER_KM_RATE = 1.50;

  constructor(repository: DeliveryRepository) {
    this.repository = repository;
  }

  private generateDeliveryNumber(): string {
    this.deliveryCounter++;
    return `DEL-${this.deliveryCounter}`;
  }

  private calculateDeliveryFee(distance?: number): number {
    if (!distance) {
      return this.BASE_DELIVERY_FEE;
    }
    const fee = this.BASE_DELIVERY_FEE + (distance * this.PER_KM_RATE);
    return Math.round(fee * 100) / 100;
  }

  private async addTrackingEvent(
    deliveryId: string,
    status: DeliveryStatus,
    message: string,
    location?: { latitude: number; longitude: number }
  ): Promise<void> {
    const tracking: DeliveryTracking = {
      deliveryId,
      timestamp: new Date(),
      status,
      location,
      message
    };
    await this.repository.addTrackingEvent(tracking);
  }

  async createDelivery(dto: CreateDeliveryDto): Promise<Delivery> {
    try {
      validate.required(dto.orderId, 'Order ID');
      validate.required(dto.deliveryAddress.street, 'Street address');
      validate.required(dto.deliveryAddress.city, 'City');
      validate.required(dto.deliveryAddress.zipCode, 'Zip code');

      // Check if delivery already exists for this order
      const existingDelivery = await this.repository.findDeliveryByOrderId(dto.orderId);
      if (existingDelivery) {
        throw new AppError(400, 'Delivery already exists for this order');
      }

      // Mock restaurant location (in real app, this would come from config/database)
      const restaurantAddress = {
        street: '123 Restaurant St',
        city: 'Food City',
        state: 'FC',
        zipCode: '12345',
        country: 'USA'
      };

      // In a real app, calculate actual distance using mapping API
      const mockDistance = Math.random() * 10 + 2; // 2-12 km
      const deliveryFee = this.calculateDeliveryFee(mockDistance);

      // Calculate estimated delivery time (mock: 30-60 minutes from now)
      const estimatedMinutes = Math.floor(Math.random() * 30) + 30;
      const estimatedDeliveryTime = new Date();
      estimatedDeliveryTime.setMinutes(estimatedDeliveryTime.getMinutes() + estimatedMinutes);

      const delivery: Delivery = {
        id: uuidv4(),
        deliveryNumber: this.generateDeliveryNumber(),
        orderId: dto.orderId,
        pickupLocation: {
          address: restaurantAddress
        },
        deliveryLocation: {
          address: dto.deliveryAddress,
          instructions: dto.deliveryInstructions
        },
        status: DeliveryStatus.PENDING,
        estimatedDeliveryTime: dto.estimatedDeliveryTime || estimatedDeliveryTime,
        distance: mockDistance,
        deliveryFee,
        notes: dto.notes,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      const createdDelivery = await this.repository.createDelivery(delivery);
      await this.addTrackingEvent(
        createdDelivery.id,
        DeliveryStatus.PENDING,
        'Delivery created and waiting for driver assignment'
      );

      logger.info(`Delivery created: ${createdDelivery.deliveryNumber} for order ${dto.orderId}`);

      return createdDelivery;
    } catch (error) {
      logger.error('Error creating delivery:', error);
      throw error;
    }
  }

  async getDeliveryById(id: string): Promise<Delivery> {
    const delivery = await this.repository.findDeliveryById(id);
    if (!delivery) {
      throw new AppError(404, 'Delivery not found');
    }
    return delivery;
  }

  async getDeliveryByNumber(deliveryNumber: string): Promise<Delivery> {
    const delivery = await this.repository.findDeliveryByNumber(deliveryNumber);
    if (!delivery) {
      throw new AppError(404, 'Delivery not found');
    }
    return delivery;
  }

  async getDeliveryByOrderId(orderId: string): Promise<Delivery> {
    const delivery = await this.repository.findDeliveryByOrderId(orderId);
    if (!delivery) {
      throw new AppError(404, 'Delivery not found for this order');
    }
    return delivery;
  }

  async getAllDeliveries(filters?: any): Promise<Delivery[]> {
    return await this.repository.findAllDeliveries(filters);
  }

  async assignDriver(deliveryId: string, dto: AssignDriverDto): Promise<Delivery> {
    validate.required(dto.driverId, 'Driver ID');

    const delivery = await this.getDeliveryById(deliveryId);
    const driver = await this.repository.findDriverById(dto.driverId);

    if (!driver) {
      throw new AppError(404, 'Driver not found');
    }

    if (!driver.isAvailable) {
      throw new AppError(400, 'Driver is not available');
    }

    if (delivery.status !== DeliveryStatus.PENDING) {
      throw new AppError(400, 'Can only assign driver to pending deliveries');
    }

    const updates: Partial<Delivery> = {
      driver,
      status: DeliveryStatus.ASSIGNED
    };

    const updatedDelivery = await this.repository.updateDelivery(deliveryId, updates);
    if (!updatedDelivery) {
      throw new AppError(404, 'Delivery not found');
    }

    // Update driver availability
    await this.repository.updateDriver(dto.driverId, { isAvailable: false });

    await this.addTrackingEvent(
      deliveryId,
      DeliveryStatus.ASSIGNED,
      `Driver ${driver.name} assigned to delivery`
    );

    logger.info(`Driver ${driver.name} assigned to delivery ${delivery.deliveryNumber}`);

    return updatedDelivery;
  }

  async updateDeliveryStatus(deliveryId: string, dto: UpdateDeliveryStatusDto): Promise<Delivery> {
    validate.isEnum(dto.status, DeliveryStatus, 'Status');

    const delivery = await this.getDeliveryById(deliveryId);

    const updates: Partial<Delivery> = { status: dto.status };

    // Update timestamps based on status
    if (dto.status === DeliveryStatus.PICKED_UP) {
      updates.actualPickupTime = new Date();
    } else if (dto.status === DeliveryStatus.DELIVERED) {
      updates.actualDeliveryTime = new Date();
      // Make driver available again
      if (delivery.driver) {
        await this.repository.updateDriver(delivery.driver.id, { isAvailable: true });
      }
    } else if (dto.status === DeliveryStatus.CANCELLED) {
      // Make driver available again
      if (delivery.driver) {
        await this.repository.updateDriver(delivery.driver.id, { isAvailable: true });
      }
    }

    const updatedDelivery = await this.repository.updateDelivery(deliveryId, updates);
    if (!updatedDelivery) {
      throw new AppError(404, 'Delivery not found');
    }

    await this.addTrackingEvent(
      deliveryId,
      dto.status,
      dto.notes || `Delivery status updated to ${dto.status}`,
      dto.location
    );

    logger.info(`Delivery ${delivery.deliveryNumber} status updated to ${dto.status}`);

    return updatedDelivery;
  }

  async getTrackingHistory(deliveryId: string): Promise<DeliveryTracking[]> {
    await this.getDeliveryById(deliveryId); // Verify delivery exists
    return await this.repository.getTrackingHistory(deliveryId);
  }

  // Driver management
  async createDriver(dto: CreateDriverDto): Promise<DeliveryDriver> {
    validate.required(dto.name, 'Driver name');
    validate.required(dto.phone, 'Driver phone');

    if (!validate.phone(dto.phone)) {
      throw new AppError(400, 'Invalid phone number format');
    }

    const driver: DeliveryDriver = {
      id: uuidv4(),
      name: dto.name,
      phone: dto.phone,
      vehicleType: dto.vehicleType,
      vehicleNumber: dto.vehicleNumber,
      isAvailable: true
    };

    const createdDriver = await this.repository.createDriver(driver);
    logger.info(`Driver created: ${createdDriver.name}`);

    return createdDriver;
  }

  async getDriverById(id: string): Promise<DeliveryDriver> {
    const driver = await this.repository.findDriverById(id);
    if (!driver) {
      throw new AppError(404, 'Driver not found');
    }
    return driver;
  }

  async getAllDrivers(availableOnly: boolean = false): Promise<DeliveryDriver[]> {
    return await this.repository.findAllDrivers(availableOnly);
  }

  async updateDriverAvailability(driverId: string, isAvailable: boolean): Promise<DeliveryDriver> {
    const driver = await this.getDriverById(driverId);

    const updatedDriver = await this.repository.updateDriver(driverId, { isAvailable });
    if (!updatedDriver) {
      throw new AppError(404, 'Driver not found');
    }

    logger.info(`Driver ${driver.name} availability updated to ${isAvailable}`);

    return updatedDriver;
  }
}
