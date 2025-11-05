import { Router } from 'express';
import { BillController } from '../controllers/bill.controller';
import { BillService } from '../services/bill.service';
import { BillRepository } from '../repositories/bill.repository';

const router = Router();

// Initialize dependencies
const billRepository = new BillRepository();
const billService = new BillService(billRepository);
const billController = new BillController(billService);

// Routes
router.post('/', billController.createBill);
router.get('/', billController.getAllBills);
router.get('/revenue', billController.getTotalRevenue);
router.get('/:id', billController.getBill);
router.get('/number/:billNumber', billController.getBillByNumber);
router.get('/order/:orderId', billController.getBillByOrderId);
router.post('/:id/payment', billController.addPayment);
router.post('/:id/discount', billController.applyDiscount);
router.post('/:id/payment/:paymentId/refund', billController.refundPayment);

export default router;
