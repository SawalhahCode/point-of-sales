import { Router } from 'express';
import { OrderController } from '../controllers/order.controller';
import { OrderService } from '../services/order.service';
import { OrderRepository } from '../repositories/order.repository';

const router = Router();

// Initialize dependencies
const orderRepository = new OrderRepository();
const orderService = new OrderService(orderRepository);
const orderController = new OrderController(orderService);

// Routes
router.post('/', orderController.createOrder);
router.get('/', orderController.getAllOrders);
router.get('/active/count', orderController.getActiveOrdersCount);
router.get('/:id', orderController.getOrder);
router.get('/number/:orderNumber', orderController.getOrderByNumber);
router.patch('/:id/status', orderController.updateOrderStatus);
router.post('/:id/cancel', orderController.cancelOrder);

export default router;
