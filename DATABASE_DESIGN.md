# Database Design - Restaurant Ordering System

## Entity Relationship Diagram (ERD)

### Feature: ORDERING (ORD)

```
┌──────────────────────────────────────┐
│         TBL_ORD_ORDERS               │
├──────────────────────────────────────┤
│ PK: ORDER_ID          NUMBER         │
│     ORDER_NUMBER      VARCHAR2(50)   │ UK
│     CUSTOMER_NAME     VARCHAR2(200)  │
│     CUSTOMER_EMAIL    VARCHAR2(200)  │
│     CUSTOMER_PHONE    VARCHAR2(50)   │
│     CUSTOMER_ADDRESS  VARCHAR2(500)  │
│     ORDER_TYPE        VARCHAR2(20)   │ CK: dine-in/takeout/delivery
│     TABLE_NUMBER      NUMBER         │
│     SUBTOTAL          NUMBER(10,2)   │
│     TAX_AMOUNT        NUMBER(10,2)   │
│     TOTAL_AMOUNT      NUMBER(10,2)   │
│     STATUS            VARCHAR2(20)   │ CK: pending/confirmed/preparing/ready/completed/cancelled
│     SPECIAL_INSTRUCTIONS CLOB        │
│     CREATED_BY        VARCHAR2(100)  │
│     CREATED_DATE      DATE           │
│     UPDATED_BY        VARCHAR2(100)  │
│     UPDATED_DATE      DATE           │
│     COMPLETED_DATE    DATE           │
└──────────────┬───────────────────────┘
               │ 1
               │
               │ N
┌──────────────▼───────────────────────┐
│     TBL_ORD_ORDER_ITEMS              │
├──────────────────────────────────────┤
│ PK: ITEM_ID           NUMBER         │
│ FK: ORDER_ID          NUMBER         │ → TBL_ORD_ORDERS
│     MENU_ITEM_ID      VARCHAR2(50)   │
│     ITEM_NAME         VARCHAR2(200)  │
│     QUANTITY          NUMBER         │
│     UNIT_PRICE        NUMBER(10,2)   │
│     SUBTOTAL          NUMBER(10,2)   │
│     SPECIAL_INST      VARCHAR2(500)  │
│     CREATED_DATE      DATE           │
└──────────────────────────────────────┘
```

### Feature: BILLING (BIL)

```
┌──────────────────────────────────────┐
│         TBL_BIL_BILLS                │
├──────────────────────────────────────┤
│ PK: BILL_ID           NUMBER         │
│     BILL_NUMBER       VARCHAR2(50)   │ UK
│ FK: ORDER_ID          NUMBER         │ → TBL_ORD_ORDERS
│     SUBTOTAL          NUMBER(10,2)   │
│     TAX_AMOUNT        NUMBER(10,2)   │
│     DISCOUNT_AMOUNT   NUMBER(10,2)   │
│     TIP_AMOUNT        NUMBER(10,2)   │
│     TOTAL_AMOUNT      NUMBER(10,2)   │
│     AMOUNT_PAID       NUMBER(10,2)   │
│     AMOUNT_DUE        NUMBER(10,2)   │
│     PAYMENT_STATUS    VARCHAR2(20)   │ CK: pending/paid/failed/refunded/partially_paid
│     NOTES             VARCHAR2(500)  │
│     CREATED_BY        VARCHAR2(100)  │
│     CREATED_DATE      DATE           │
│     UPDATED_BY        VARCHAR2(100)  │
│     UPDATED_DATE      DATE           │
│     PAID_DATE         DATE           │
└──────────────┬───────────────────────┘
               │ 1
               │
               │ N
┌──────────────▼───────────────────────┐
│     TBL_BIL_PAYMENTS                 │
├──────────────────────────────────────┤
│ PK: PAYMENT_ID        NUMBER         │
│ FK: BILL_ID           NUMBER         │ → TBL_BIL_BILLS
│     PAYMENT_AMOUNT    NUMBER(10,2)   │
│     PAYMENT_METHOD    VARCHAR2(20)   │ CK: cash/credit_card/debit_card/mobile
│     TRANSACTION_ID    VARCHAR2(100)  │
│     PAYMENT_DATE      DATE           │
│     PROCESSED_BY      VARCHAR2(100)  │
│     NOTES             VARCHAR2(500)  │
└──────────────────────────────────────┘
```

### Feature: DELIVERY (DEL)

```
┌──────────────────────────────────────┐
│        TBL_DEL_DRIVERS               │
├──────────────────────────────────────┤
│ PK: DRIVER_ID         NUMBER         │
│     DRIVER_NAME       VARCHAR2(200)  │
│     PHONE_NUMBER      VARCHAR2(50)   │
│     VEHICLE_TYPE      VARCHAR2(50)   │
│     VEHICLE_NUMBER    VARCHAR2(50)   │
│     IS_AVAILABLE      CHAR(1)        │ CK: Y/N
│     CURRENT_LAT       NUMBER(10,6)   │
│     CURRENT_LONG      NUMBER(10,6)   │
│     CREATED_DATE      DATE           │
│     UPDATED_DATE      DATE           │
└──────────────┬───────────────────────┘
               │ 1
               │
               │ N
┌──────────────▼───────────────────────┐
│       TBL_DEL_DELIVERIES             │
├──────────────────────────────────────┤
│ PK: DELIVERY_ID       NUMBER         │
│     DELIVERY_NUMBER   VARCHAR2(50)   │ UK
│ FK: ORDER_ID          NUMBER         │ → TBL_ORD_ORDERS
│ FK: DRIVER_ID         NUMBER         │ → TBL_DEL_DRIVERS
│     PICKUP_ADDRESS    VARCHAR2(500)  │
│     DELIVERY_ADDRESS  VARCHAR2(500)  │
│     DELIVERY_LAT      NUMBER(10,6)   │
│     DELIVERY_LONG     NUMBER(10,6)   │
│     DELIVERY_INSTRUCT VARCHAR2(500)  │
│     DISTANCE_KM       NUMBER(10,2)   │
│     DELIVERY_FEE      NUMBER(10,2)   │
│     STATUS            VARCHAR2(20)   │ CK: pending/assigned/picked_up/in_transit/delivered/cancelled
│     EST_PICKUP_TIME   DATE           │
│     ACTUAL_PICKUP_TIME DATE          │
│     EST_DELIVERY_TIME DATE           │
│     ACTUAL_DELIVERY_TIME DATE        │
│     NOTES             VARCHAR2(500)  │
│     CREATED_DATE      DATE           │
│     UPDATED_DATE      DATE           │
└──────────────┬───────────────────────┘
               │ 1
               │
               │ N
┌──────────────▼───────────────────────┐
│    TBL_DEL_DELIVERY_TRACKING         │
├──────────────────────────────────────┤
│ PK: TRACKING_ID       NUMBER         │
│ FK: DELIVERY_ID       NUMBER         │ → TBL_DEL_DELIVERIES
│     STATUS            VARCHAR2(20)   │
│     LOCATION_LAT      NUMBER(10,6)   │
│     LOCATION_LONG     NUMBER(10,6)   │
│     MESSAGE           VARCHAR2(500)  │
│     TRACKING_DATE     DATE           │
└──────────────────────────────────────┘
```

### Feature: RESERVATIONS (RES)

```
┌──────────────────────────────────────┐
│         TBL_RES_TABLES               │
├──────────────────────────────────────┤
│ PK: TABLE_ID          NUMBER         │
│     TABLE_NUMBER      NUMBER         │ UK
│     CAPACITY          NUMBER         │
│     LOCATION          VARCHAR2(50)   │
│     FEATURES          VARCHAR2(500)  │
│     STATUS            VARCHAR2(20)   │ CK: available/occupied/reserved/cleaning
│     CREATED_DATE      DATE           │
│     UPDATED_DATE      DATE           │
└──────────────┬───────────────────────┘
               │ 1
               │
               │ N
┌──────────────▼───────────────────────┐
│      TBL_RES_RESERVATIONS            │
├──────────────────────────────────────┤
│ PK: RESERVATION_ID    NUMBER         │
│     RESERVATION_NUMBER VARCHAR2(50)  │ UK
│     CUSTOMER_NAME     VARCHAR2(200)  │
│     CUSTOMER_EMAIL    VARCHAR2(200)  │
│     CUSTOMER_PHONE    VARCHAR2(50)   │
│ FK: TABLE_ID          NUMBER         │ → TBL_RES_TABLES
│     PARTY_SIZE        NUMBER         │
│     RESERVATION_DATE  DATE           │
│     RESERVATION_TIME  VARCHAR2(5)    │
│     DURATION_MINUTES  NUMBER         │
│     STATUS            VARCHAR2(20)   │ CK: pending/confirmed/seated/completed/cancelled/no_show
│     SPECIAL_REQUESTS  VARCHAR2(500)  │
│     OCCASION          VARCHAR2(100)  │
│     ARRIVAL_TIME      DATE           │
│     SEATED_TIME       DATE           │
│     COMPLETED_TIME    DATE           │
│     NOTES             VARCHAR2(500)  │
│     CREATED_BY        VARCHAR2(100)  │
│     CREATED_DATE      DATE           │
│     UPDATED_BY        VARCHAR2(100)  │
│     UPDATED_DATE      DATE           │
└──────────────────────────────────────┘
```

## Cross-Feature Relationships

```
TBL_ORD_ORDERS
    ↓ (1:1)
    ├─→ TBL_BIL_BILLS      (Billing for order)
    └─→ TBL_DEL_DELIVERIES (Delivery for order)

TBL_RES_RESERVATIONS (Independent - no direct FK to orders)
```

## Indexes Strategy

### Primary Keys (Automatic)
All PK constraints create unique indexes automatically.

### Foreign Keys (Performance)
```sql
-- Ordering
IDX_TBL_ORD_ITEMS_ORDER_ID

-- Billing
IDX_TBL_BIL_BILLS_ORDER_ID
IDX_TBL_BIL_PAYMENTS_BILL_ID

-- Delivery
IDX_TBL_DEL_DELIVERIES_ORDER_ID
IDX_TBL_DEL_DELIVERIES_DRIVER_ID
IDX_TBL_DEL_TRACKING_DELIVERY_ID

-- Reservations
IDX_TBL_RES_RESERV_TABLE_ID
```

### Business Queries (Performance)
```sql
-- Ordering
IDX_TBL_ORD_ORDERS_STATUS
IDX_TBL_ORD_ORDERS_CREATED_DATE
IDX_TBL_ORD_ORDERS_ORDER_TYPE

-- Billing
IDX_TBL_BIL_BILLS_STATUS
IDX_TBL_BIL_BILLS_CREATED_DATE

-- Delivery
IDX_TBL_DEL_DELIVERIES_STATUS
IDX_TBL_DEL_DRIVERS_AVAILABLE

-- Reservations
IDX_TBL_RES_RESERV_DATE_TIME
IDX_TBL_RES_RESERV_STATUS
IDX_TBL_RES_TABLES_STATUS
```

## Sequences

```sql
-- Ordering
SEQ_ORD_ORDERS         -- For ORDER_ID
SEQ_ORD_ORDER_ITEMS    -- For ITEM_ID

-- Billing
SEQ_BIL_BILLS          -- For BILL_ID
SEQ_BIL_PAYMENTS       -- For PAYMENT_ID

-- Delivery
SEQ_DEL_DRIVERS        -- For DRIVER_ID
SEQ_DEL_DELIVERIES     -- For DELIVERY_ID
SEQ_DEL_TRACKING       -- For TRACKING_ID

-- Reservations
SEQ_RES_TABLES         -- For TABLE_ID
SEQ_RES_RESERVATIONS   -- For RESERVATION_ID
```

## Constraints Summary

### Check Constraints

```sql
-- Order Status
CK_TBL_ORD_ORDERS_STATUS:
  STATUS IN ('PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'COMPLETED', 'CANCELLED')

-- Order Type
CK_TBL_ORD_ORDERS_TYPE:
  ORDER_TYPE IN ('DINE_IN', 'TAKEOUT', 'DELIVERY')

-- Payment Status
CK_TBL_BIL_BILLS_STATUS:
  PAYMENT_STATUS IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'PARTIALLY_PAID')

-- Payment Method
CK_TBL_BIL_PAYMENTS_METHOD:
  PAYMENT_METHOD IN ('CASH', 'CREDIT_CARD', 'DEBIT_CARD', 'MOBILE_PAYMENT')

-- Delivery Status
CK_TBL_DEL_DELIVERIES_STATUS:
  STATUS IN ('PENDING', 'ASSIGNED', 'PICKED_UP', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED')

-- Driver Availability
CK_TBL_DEL_DRIVERS_AVAILABLE:
  IS_AVAILABLE IN ('Y', 'N')

-- Table Status
CK_TBL_RES_TABLES_STATUS:
  STATUS IN ('AVAILABLE', 'OCCUPIED', 'RESERVED', 'CLEANING')

-- Reservation Status
CK_TBL_RES_RESERV_STATUS:
  STATUS IN ('PENDING', 'CONFIRMED', 'SEATED', 'COMPLETED', 'CANCELLED', 'NO_SHOW')
```

### Unique Constraints

```sql
UK_TBL_ORD_ORDERS_NUMBER     (ORDER_NUMBER)
UK_TBL_BIL_BILLS_NUMBER      (BILL_NUMBER)
UK_TBL_DEL_DELIVERIES_NUMBER (DELIVERY_NUMBER)
UK_TBL_RES_TABLES_NUMBER     (TABLE_NUMBER)
UK_TBL_RES_RESERV_NUMBER     (RESERVATION_NUMBER)
```

## Triggers

### Audit Triggers (Before Insert/Update)

```sql
-- Set created_by/created_date on INSERT
TRG_TBL_ORD_ORDERS_BIR
TRG_TBL_BIL_BILLS_BIR
TRG_TBL_DEL_DELIVERIES_BIR
TRG_TBL_RES_RESERVATIONS_BIR

-- Set updated_by/updated_date on UPDATE
TRG_TBL_ORD_ORDERS_BUR
TRG_TBL_BIL_BILLS_BUR
TRG_TBL_DEL_DELIVERIES_BUR
TRG_TBL_RES_RESERVATIONS_BUR
```

### Business Logic Triggers

```sql
-- Update bill amounts when payment added
TRG_TBL_BIL_PAYMENTS_AIR

-- Update driver availability when delivery status changes
TRG_TBL_DEL_DELIVERIES_AUR

-- Update table status when reservation seated/completed
TRG_TBL_RES_RESERV_AUR
```

## Data Volume Estimates (1 Year)

```
TBL_ORD_ORDERS:           ~100,000 rows  (300 orders/day)
TBL_ORD_ORDER_ITEMS:      ~300,000 rows  (3 items/order avg)
TBL_BIL_BILLS:            ~100,000 rows  (1 bill per order)
TBL_BIL_PAYMENTS:         ~120,000 rows  (1.2 payments/bill avg)
TBL_DEL_DELIVERIES:       ~30,000 rows   (30% of orders)
TBL_DEL_TRACKING:         ~150,000 rows  (5 tracking/delivery avg)
TBL_DEL_DRIVERS:          ~50 rows       (drivers)
TBL_RES_RESERVATIONS:     ~50,000 rows   (150 reservations/day)
TBL_RES_TABLES:           ~50 rows       (tables)
```

## Storage Considerations

- Use tablespaces for better management
- Archive old orders (> 1 year) to archive tables
- Partition large tables by date for better performance
- Regular statistics gathering
- Index maintenance

## Security

- Grant execute on packages only (not direct table access)
- Use application roles
- Encrypt sensitive data (credit card info if stored)
- Audit critical operations
- Row-level security for multi-tenant if needed
