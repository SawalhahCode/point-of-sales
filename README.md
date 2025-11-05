# Restaurant Ordering System - Point of Sale

A comprehensive, feature-based restaurant ordering system built with TypeScript and Node.js, implementing clean architecture principles.

## Features

The system is organized into four main feature modules:

### 1. Ordering
- Create and manage customer orders
- Support for dine-in, takeout, and delivery orders
- Menu item management with modifiers
- Order status tracking (pending, confirmed, preparing, ready, completed, cancelled)
- Real-time order updates

### 2. Billing
- Automated bill generation from orders
- Multiple payment method support (cash, credit card, debit card, mobile payment)
- Split payments and partial payment handling
- Discount management (percentage and fixed)
- Payment tracking and refund processing
- Revenue reporting

### 3. Delivery
- Delivery order management
- Driver assignment and tracking
- Real-time delivery status updates
- Distance-based delivery fee calculation
- Delivery location management with GPS coordinates
- Driver availability management

### 4. Reservations
- Table reservation system
- Customer booking management
- Table availability checking
- Reservation status tracking
- Table management (capacity, location, features)
- Party size validation
- Special occasion handling

## Architecture

### Project Structure

```
src/
├── features/                 # Feature modules
│   ├── ordering/            # Ordering feature
│   │   ├── models/          # Data models
│   │   ├── dtos/            # Data Transfer Objects
│   │   ├── repositories/    # Data access layer
│   │   ├── services/        # Business logic
│   │   ├── controllers/     # Request handlers
│   │   ├── routes/          # Route definitions
│   │   └── index.ts         # Feature exports
│   ├── billing/             # Billing feature
│   ├── delivery/            # Delivery feature
│   └── reservations/        # Reservations feature
├── shared/                  # Shared utilities
│   ├── types/              # Common TypeScript types
│   ├── utils/              # Utility functions
│   └── middleware/         # Express middleware
├── config/                 # Configuration files
└── index.ts               # Application entry point
```

### Architecture Principles

- **Feature-Based Structure**: Each feature is self-contained with its own models, services, and controllers
- **Clean Architecture**: Separation of concerns with clear layers (models, repositories, services, controllers)
- **Dependency Injection**: Services receive dependencies through constructors
- **Type Safety**: Full TypeScript implementation with strict type checking
- **Error Handling**: Centralized error handling with custom error types
- **Validation**: Input validation at service layer
- **Repository Pattern**: Data access abstraction for easy database switching

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd point-of-sales
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```
NODE_ENV=development
PORT=3000
RESTAURANT_TAX_RATE=0.08
```

4. Build the project:
```bash
npm run build
```

5. Start the server:
```bash
# Development mode with hot reload
npm run dev

# Production mode
npm start
```

## API Endpoints

### Ordering API

- `POST /api/v1/orders` - Create new order
- `GET /api/v1/orders` - Get all orders (with filters)
- `GET /api/v1/orders/:id` - Get order by ID
- `GET /api/v1/orders/number/:orderNumber` - Get order by number
- `PATCH /api/v1/orders/:id/status` - Update order status
- `POST /api/v1/orders/:id/cancel` - Cancel order
- `GET /api/v1/orders/active/count` - Get active orders count

### Billing API

- `POST /api/v1/bills` - Create new bill
- `GET /api/v1/bills` - Get all bills (with filters)
- `GET /api/v1/bills/:id` - Get bill by ID
- `GET /api/v1/bills/number/:billNumber` - Get bill by number
- `GET /api/v1/bills/order/:orderId` - Get bill by order ID
- `POST /api/v1/bills/:id/payment` - Add payment to bill
- `POST /api/v1/bills/:id/discount` - Apply discount to bill
- `POST /api/v1/bills/:id/payment/:paymentId/refund` - Refund payment
- `GET /api/v1/bills/revenue` - Get total revenue

### Delivery API

- `POST /api/v1/deliveries` - Create new delivery
- `GET /api/v1/deliveries` - Get all deliveries (with filters)
- `GET /api/v1/deliveries/:id` - Get delivery by ID
- `GET /api/v1/deliveries/number/:deliveryNumber` - Get delivery by number
- `GET /api/v1/deliveries/order/:orderId` - Get delivery by order ID
- `POST /api/v1/deliveries/:id/assign-driver` - Assign driver to delivery
- `PATCH /api/v1/deliveries/:id/status` - Update delivery status
- `GET /api/v1/deliveries/:id/tracking` - Get delivery tracking history
- `POST /api/v1/deliveries/drivers` - Create new driver
- `GET /api/v1/deliveries/drivers` - Get all drivers
- `PATCH /api/v1/deliveries/drivers/:id/availability` - Update driver availability

### Reservations API

- `POST /api/v1/reservations` - Create new reservation
- `GET /api/v1/reservations` - Get all reservations (with filters)
- `GET /api/v1/reservations/availability` - Check table availability
- `GET /api/v1/reservations/:id` - Get reservation by ID
- `GET /api/v1/reservations/number/:reservationNumber` - Get reservation by number
- `PATCH /api/v1/reservations/:id` - Update reservation
- `POST /api/v1/reservations/:id/confirm` - Confirm reservation
- `POST /api/v1/reservations/:id/cancel` - Cancel reservation
- `POST /api/v1/reservations/:id/assign-table` - Assign table to reservation
- `POST /api/v1/reservations/:id/seat` - Seat guests
- `POST /api/v1/reservations/:id/complete` - Complete reservation
- `POST /api/v1/reservations/tables` - Create new table
- `GET /api/v1/reservations/tables` - Get all tables
- `PATCH /api/v1/reservations/tables/:id/status` - Update table status

## API Usage Examples

### Create an Order

```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customer": {
      "name": "John Doe",
      "phone": "+1234567890",
      "email": "john@example.com"
    },
    "items": [
      {
        "menuItemId": "item-1",
        "name": "Burger",
        "quantity": 2,
        "unitPrice": 12.99
      }
    ],
    "orderType": "dine-in",
    "tableNumber": 5
  }'
```

### Create a Reservation

```bash
curl -X POST http://localhost:3000/api/v1/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "customer": {
      "name": "Jane Smith",
      "phone": "+1234567890"
    },
    "partySize": 4,
    "reservationDate": "2025-11-10",
    "reservationTime": "19:00",
    "specialRequests": "Window seat preferred"
  }'
```

## Development

### Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm run lint` - Run ESLint
- `npm test` - Run tests

### Adding a New Feature

1. Create feature directory under `src/features/`
2. Implement models, DTOs, repositories, services, controllers
3. Define routes
4. Export feature in `index.ts`
5. Register routes in main `src/index.ts`

## Data Persistence

Currently, the system uses in-memory storage for demonstration purposes. To integrate with a real database:

1. Choose your database (PostgreSQL, MongoDB, MySQL, etc.)
2. Update `src/config/database.ts` with actual connection logic
3. Modify repositories to use database queries instead of in-memory maps
4. Add database migration scripts

## Future Enhancements

- [ ] Database integration (PostgreSQL/MongoDB)
- [ ] Authentication and authorization
- [ ] Real-time updates with WebSockets
- [ ] Menu management feature
- [ ] Kitchen display system
- [ ] Analytics and reporting dashboard
- [ ] Integration with payment gateways
- [ ] SMS/Email notifications
- [ ] Mobile app support
- [ ] Multi-restaurant support
- [ ] Loyalty program

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

ISC
