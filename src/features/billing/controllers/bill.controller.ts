import { Request, Response } from 'express';
import { BillService } from '../services/bill.service';
import { CreateBillDto, AddPaymentDto, ApplyDiscountDto } from '../dtos/bill.dto';
import { asyncHandler } from '../../../shared/middleware/errorHandler';
import { PaymentStatus } from '../../../shared/types/common.types';

export class BillController {
  constructor(private billService: BillService) {}

  createBill = asyncHandler(async (req: Request, res: Response) => {
    const dto: CreateBillDto = req.body;

    // In a real application, you would fetch order data from the order service
    // For this example, we'll use mock data
    const orderData = {
      id: dto.orderId,
      subtotal: 100.00,
      tax: 8.00,
      total: 108.00
    };

    const bill = await this.billService.createBill(dto, orderData);

    res.status(201).json({
      success: true,
      message: 'Bill created successfully',
      data: bill
    });
  });

  getBill = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const bill = await this.billService.getBillById(id);

    res.json({
      success: true,
      data: bill
    });
  });

  getBillByNumber = asyncHandler(async (req: Request, res: Response) => {
    const { billNumber } = req.params;
    const bill = await this.billService.getBillByNumber(billNumber);

    res.json({
      success: true,
      data: bill
    });
  });

  getBillByOrderId = asyncHandler(async (req: Request, res: Response) => {
    const { orderId } = req.params;
    const bill = await this.billService.getBillByOrderId(orderId);

    res.json({
      success: true,
      data: bill
    });
  });

  getAllBills = asyncHandler(async (req: Request, res: Response) => {
    const filters = {
      paymentStatus: req.query.paymentStatus as PaymentStatus | undefined,
      fromDate: req.query.fromDate ? new Date(req.query.fromDate as string) : undefined,
      toDate: req.query.toDate ? new Date(req.query.toDate as string) : undefined
    };

    const bills = await this.billService.getAllBills(filters);

    res.json({
      success: true,
      data: bills,
      count: bills.length
    });
  });

  addPayment = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const dto: AddPaymentDto = req.body;

    const bill = await this.billService.addPayment(id, dto);

    res.json({
      success: true,
      message: 'Payment added successfully',
      data: bill
    });
  });

  applyDiscount = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const dto: ApplyDiscountDto = req.body;

    const bill = await this.billService.applyDiscount(id, dto);

    res.json({
      success: true,
      message: 'Discount applied successfully',
      data: bill
    });
  });

  refundPayment = asyncHandler(async (req: Request, res: Response) => {
    const { id, paymentId } = req.params;
    const { reason } = req.body;

    const bill = await this.billService.refundPayment(id, paymentId, reason);

    res.json({
      success: true,
      message: 'Payment refunded successfully',
      data: bill
    });
  });

  getTotalRevenue = asyncHandler(async (req: Request, res: Response) => {
    const fromDate = req.query.fromDate ? new Date(req.query.fromDate as string) : undefined;
    const toDate = req.query.toDate ? new Date(req.query.toDate as string) : undefined;

    const revenue = await this.billService.getTotalRevenue(fromDate, toDate);

    res.json({
      success: true,
      data: {
        revenue,
        fromDate,
        toDate
      }
    });
  });
}
