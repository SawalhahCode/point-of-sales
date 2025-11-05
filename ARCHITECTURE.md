# Architecture Documentation

## Overview

This document describes the architecture of the Restaurant Ordering System, a feature-based Node.js application built with TypeScript and Express.

## Architecture Pattern

### Feature-Based Architecture

The application follows a **feature-based architecture** where the codebase is organized by business features rather than technical layers. Each feature is a self-contained module with its own:

- **Models**: Data structures and entities
- **DTOs**: Data Transfer Objects for API communication
- **Repositories**: Data access layer
- **Services**: Business logic and use cases
- **Controllers**: HTTP request handlers
- **Routes**: API endpoint definitions

### Benefits

1. **Modularity**: Each feature is independent and can be developed/tested in isolation
2. **Scalability**: New features can be added without affecting existing ones
3. **Maintainability**: Related code is co-located, making it easier to understand and modify
4. **Team Collaboration**: Different teams can work on different features simultaneously
5. **Code Reusability**: Shared utilities and types are centralized

## System Features

### 1. Ordering Feature

**Purpose**: Manage customer orders from creation to completion

**Key Components**:
- `Order` model with items, pricing, and status
- Order lifecycle management (pending → confirmed → preparing → ready → completed)
- Support for multiple order types (dine-in, takeout, delivery)
- Automatic tax calculation
- Order modification and cancellation

**Dependencies**: None (can operate independently)

### 2. Billing Feature

**Purpose**: Handle payment processing and financial transactions

**Key Components**:
- Bill generation from orders
- Multiple payment methods support
- Split and partial payment handling
- Discount application (percentage and fixed)
- Payment refund processing
- Revenue tracking and reporting

**Dependencies**: Requires Order data (orderId reference)

### 3. Delivery Feature

**Purpose**: Manage order deliveries and driver assignments

**Key Components**:
- Delivery order creation and tracking
- Driver management and assignment
- Real-time status updates with GPS tracking
- Distance-based fee calculation
- Delivery history and analytics

**Dependencies**: Requires Order data (orderId reference)

### 4. Reservations Feature

**Purpose**: Handle table reservations and restaurant capacity management

**Key Components**:
- Reservation booking and confirmation
- Table management (capacity, status, features)
- Availability checking
- Guest seating workflow
- Special occasion handling

**Dependencies**: None (can operate independently)

## Layer Architecture

Each feature follows a **clean architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────┐
│              HTTP Layer (Routes)                 │
│  - Define API endpoints                          │
│  - Route requests to controllers                 │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│         Presentation Layer (Controllers)         │
│  - Handle HTTP requests/responses                │
│  - Input validation (DTO)                        │
│  - Call service methods                          │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│          Business Layer (Services)               │
│  - Business logic and rules                      │
│  - Data validation                               │
│  - Orchestrate operations                        │
│  - Error handling                                │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│        Data Access Layer (Repositories)          │
│  - CRUD operations                               │
│  - Data queries and filters                      │
│  - Database abstraction                          │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Data Layer (Models)                 │
│  - Entity definitions                            │
│  - Type definitions                              │
└─────────────────────────────────────────────────┘
```

## Shared Components

### Types (`src/shared/types/`)

Common TypeScript types and enums used across features:
- `OrderStatus`, `PaymentStatus`, `DeliveryStatus`, `ReservationStatus`
- `Customer`, `Address`, `ApiResponse`
- Pagination types

### Utils (`src/shared/utils/`)

Utility functions:
- **Logger**: Structured logging with different log levels
- **Validation**: Common validation functions for input sanitization

### Middleware (`src/shared/middleware/`)

Express middleware:
- **Error Handler**: Centralized error handling
- **Async Handler**: Wrapper for async route handlers

## Data Flow

### Example: Create Order Flow

```
1. Client sends POST /api/v1/orders
   ↓
2. Express routes to orderRoutes
   ↓
3. OrderController.createOrder() receives request
   ↓
4. Controller extracts CreateOrderDto from request body
   ↓
5. Controller calls OrderService.createOrder(dto)
   ↓
6. Service validates input data
   ↓
7. Service calculates order totals (subtotal, tax, total)
   ↓
8. Service creates Order entity
   ↓
9. Service calls OrderRepository.create(order)
   ↓
10. Repository stores order in database/memory
   ↓
11. Repository returns created order
   ↓
12. Service logs operation and returns order
   ↓
13. Controller sends 201 response with order data
```

## Design Patterns

### 1. Repository Pattern

Abstracts data access logic from business logic:

```typescript
class OrderRepository {
  async create(order: Order): Promise<Order>
  async findById(id: string): Promise<Order | null>
  async findAll(filters?: any): Promise<Order[]>
  async update(id: string, updates: Partial<Order>): Promise<Order | null>
  async delete(id: string): Promise<boolean>
}
```

**Benefits**:
- Easy to swap database implementations
- Testable with mock repositories
- Centralized data access logic

### 2. Service Layer Pattern

Encapsulates business logic:

```typescript
class OrderService {
  constructor(private repository: OrderRepository) {}

  async createOrder(dto: CreateOrderDto): Promise<Order> {
    // Validation
    // Business logic
    // Call repository
  }
}
```

**Benefits**:
- Single responsibility
- Reusable business logic
- Easy to test

### 3. DTO Pattern

Data Transfer Objects for API communication:

```typescript
interface CreateOrderDto {
  customer: { name: string; phone: string }
  items: CreateOrderItemDto[]
  orderType: 'dine-in' | 'takeout' | 'delivery'
}
```

**Benefits**:
- Type safety
- Input validation
- Decouples API from internal models

### 4. Dependency Injection

Dependencies are injected through constructors:

```typescript
const repository = new OrderRepository();
const service = new OrderService(repository);
const controller = new OrderController(service);
```

**Benefits**:
- Loose coupling
- Easy to test with mocks
- Better code organization

## Error Handling

### Error Types

1. **ValidationError**: Input validation failures (400)
2. **AppError**: Business logic errors (400-499)
3. **System Errors**: Unexpected errors (500)

### Error Flow

```
Try/Catch in Service
  ↓
Throw AppError/ValidationError
  ↓
Caught by asyncHandler middleware
  ↓
Passed to errorHandler middleware
  ↓
Formatted error response sent to client
```

## Security Considerations

1. **Helmet**: Security headers
2. **CORS**: Cross-origin resource sharing
3. **Input Validation**: All inputs validated before processing
4. **Error Messages**: No sensitive information in error responses
5. **Environment Variables**: Sensitive config in .env files

## Performance Considerations

1. **In-Memory Storage**: Fast but not persistent (replace with database)
2. **Async Operations**: All I/O operations are asynchronous
3. **Error Handling**: Efficient error propagation
4. **Logging**: Structured logging for debugging

## Scalability

### Horizontal Scaling

- Stateless design allows multiple instances
- Add load balancer for distribution
- Use external database for shared state

### Vertical Scaling

- Increase server resources
- Optimize database queries
- Add caching layer (Redis)

### Feature Scaling

- Each feature can be extracted to microservice
- Use message queue for feature communication
- Implement API gateway for routing

## Testing Strategy

1. **Unit Tests**: Test individual functions and methods
2. **Integration Tests**: Test feature workflows
3. **API Tests**: Test HTTP endpoints
4. **End-to-End Tests**: Test complete user flows

## Deployment

### Development
```bash
npm run dev
```

### Production
```bash
npm run build
npm start
```

### Docker (Future)
```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY dist ./dist
CMD ["node", "dist/index.js"]
```

## Future Architecture Improvements

1. **Microservices**: Split features into separate services
2. **Event-Driven**: Use message queue (RabbitMQ, Kafka) for feature communication
3. **CQRS**: Separate read and write operations
4. **GraphQL**: Add GraphQL API alongside REST
5. **Caching**: Implement Redis for performance
6. **Database**: Add PostgreSQL or MongoDB
7. **Authentication**: Add JWT-based auth
8. **API Gateway**: Centralize routing and auth
9. **Service Mesh**: For microservices communication
10. **Monitoring**: Add APM (Application Performance Monitoring)
