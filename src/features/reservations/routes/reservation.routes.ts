import { Router } from 'express';
import { ReservationController } from '../controllers/reservation.controller';
import { ReservationService } from '../services/reservation.service';
import { ReservationRepository } from '../repositories/reservation.repository';

const router = Router();

// Initialize dependencies
const reservationRepository = new ReservationRepository();
const reservationService = new ReservationService(reservationRepository);
const reservationController = new ReservationController(reservationService);

// Reservation routes
router.post('/', reservationController.createReservation);
router.get('/', reservationController.getAllReservations);
router.get('/availability', reservationController.checkAvailability);
router.get('/:id', reservationController.getReservation);
router.get('/number/:reservationNumber', reservationController.getReservationByNumber);
router.patch('/:id', reservationController.updateReservation);
router.post('/:id/confirm', reservationController.confirmReservation);
router.post('/:id/cancel', reservationController.cancelReservation);
router.post('/:id/assign-table', reservationController.assignTable);
router.post('/:id/seat', reservationController.seatReservation);
router.post('/:id/complete', reservationController.completeReservation);

// Table routes
router.post('/tables', reservationController.createTable);
router.get('/tables', reservationController.getAllTables);
router.get('/tables/:id', reservationController.getTable);
router.patch('/tables/:id', reservationController.updateTable);
router.patch('/tables/:id/status', reservationController.updateTableStatus);

export default router;
