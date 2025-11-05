import { Router } from 'express';
import { DeliveryController } from '../controllers/delivery.controller';
import { DeliveryService } from '../services/delivery.service';
import { DeliveryRepository } from '../repositories/delivery.repository';

const router = Router();

// Initialize dependencies
const deliveryRepository = new DeliveryRepository();
const deliveryService = new DeliveryService(deliveryRepository);
const deliveryController = new DeliveryController(deliveryService);

// Delivery routes
router.post('/', deliveryController.createDelivery);
router.get('/', deliveryController.getAllDeliveries);
router.get('/:id', deliveryController.getDelivery);
router.get('/number/:deliveryNumber', deliveryController.getDeliveryByNumber);
router.get('/order/:orderId', deliveryController.getDeliveryByOrderId);
router.post('/:id/assign-driver', deliveryController.assignDriver);
router.patch('/:id/status', deliveryController.updateDeliveryStatus);
router.get('/:id/tracking', deliveryController.getTrackingHistory);

// Driver routes
router.post('/drivers', deliveryController.createDriver);
router.get('/drivers', deliveryController.getAllDrivers);
router.get('/drivers/:id', deliveryController.getDriver);
router.patch('/drivers/:id/availability', deliveryController.updateDriverAvailability);

export default router;
