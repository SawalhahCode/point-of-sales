import { Delivery, DeliveryDriver, DeliveryTracking } from '../models/delivery.model';
import { DeliveryStatus } from '../../../shared/types/common.types';

export class DeliveryRepository {
  private deliveries: Map<string, Delivery> = new Map();
  private drivers: Map<string, DeliveryDriver> = new Map();
  private trackingHistory: Map<string, DeliveryTracking[]> = new Map();

  async createDelivery(delivery: Delivery): Promise<Delivery> {
    this.deliveries.set(delivery.id, delivery);
    return delivery;
  }

  async findDeliveryById(id: string): Promise<Delivery | null> {
    return this.deliveries.get(id) || null;
  }

  async findDeliveryByNumber(deliveryNumber: string): Promise<Delivery | null> {
    const deliveries = Array.from(this.deliveries.values());
    return deliveries.find(d => d.deliveryNumber === deliveryNumber) || null;
  }

  async findDeliveryByOrderId(orderId: string): Promise<Delivery | null> {
    const deliveries = Array.from(this.deliveries.values());
    return deliveries.find(d => d.orderId === orderId) || null;
  }

  async findAllDeliveries(filters?: {
    status?: DeliveryStatus;
    driverId?: string;
    fromDate?: Date;
    toDate?: Date;
  }): Promise<Delivery[]> {
    let deliveries = Array.from(this.deliveries.values());

    if (filters?.status) {
      deliveries = deliveries.filter(d => d.status === filters.status);
    }

    if (filters?.driverId) {
      deliveries = deliveries.filter(d => d.driver?.id === filters.driverId);
    }

    if (filters?.fromDate) {
      deliveries = deliveries.filter(d => d.createdAt >= filters.fromDate!);
    }

    if (filters?.toDate) {
      deliveries = deliveries.filter(d => d.createdAt <= filters.toDate!);
    }

    return deliveries.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  async updateDelivery(id: string, updates: Partial<Delivery>): Promise<Delivery | null> {
    const delivery = this.deliveries.get(id);
    if (!delivery) {
      return null;
    }

    const updatedDelivery = { ...delivery, ...updates, updatedAt: new Date() };
    this.deliveries.set(id, updatedDelivery);
    return updatedDelivery;
  }

  async deleteDelivery(id: string): Promise<boolean> {
    return this.deliveries.delete(id);
  }

  // Driver methods
  async createDriver(driver: DeliveryDriver): Promise<DeliveryDriver> {
    this.drivers.set(driver.id, driver);
    return driver;
  }

  async findDriverById(id: string): Promise<DeliveryDriver | null> {
    return this.drivers.get(id) || null;
  }

  async findAllDrivers(availableOnly: boolean = false): Promise<DeliveryDriver[]> {
    let drivers = Array.from(this.drivers.values());

    if (availableOnly) {
      drivers = drivers.filter(d => d.isAvailable);
    }

    return drivers;
  }

  async updateDriver(id: string, updates: Partial<DeliveryDriver>): Promise<DeliveryDriver | null> {
    const driver = this.drivers.get(id);
    if (!driver) {
      return null;
    }

    const updatedDriver = { ...driver, ...updates };
    this.drivers.set(id, updatedDriver);
    return updatedDriver;
  }

  // Tracking methods
  async addTrackingEvent(tracking: DeliveryTracking): Promise<void> {
    const history = this.trackingHistory.get(tracking.deliveryId) || [];
    history.push(tracking);
    this.trackingHistory.set(tracking.deliveryId, history);
  }

  async getTrackingHistory(deliveryId: string): Promise<DeliveryTracking[]> {
    return this.trackingHistory.get(deliveryId) || [];
  }
}
