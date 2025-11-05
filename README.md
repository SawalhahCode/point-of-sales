# Restaurant Ordering System - Oracle PL/SQL

A comprehensive, feature-based restaurant ordering system built using Oracle Database with PL/SQL, implementing a clean three-layer architecture.

## Overview

This system provides a complete point-of-sale (POS) solution for restaurants with four main features:

1. **Ordering** - Customer order management (dine-in, takeout, delivery)
2. **Billing** - Payment processing and financial transactions
3. **Delivery** - Delivery management with driver tracking
4. **Reservations** - Table reservation and management system

## Architecture

The system follows a **three-layer architecture** with clear separation of concerns:

### 1. Physical Layer (Database Objects)
- **Tables** (TBL_*): Physical data storage
- **Sequences** (SEQ_*): Primary key generation
- **Indexes** (IDX_*): Query performance optimization
- **Constraints**: Data integrity and validation
- **Triggers** (TRG_*): Automated business logic

### 2. Logical Layer (Views & Types)
- **Views** (VW_*): Logical data abstraction
- **Object Types** (TYP_*): Custom data structures
- **Collections**: Arrays and nested tables
- **Materialized Views**: Precomputed aggregations

### 3. Application Layer (PL/SQL Packages)
- **Packages** (PKG_*): Business logic and API
- **Procedures**: Operations with side effects
- **Functions**: Return value operations
- **Error Handling**: Centralized exception management

## Documentation

- [METHODOLOGY.md](METHODOLOGY.md) - Complete methodology and design principles
- [DATABASE_DESIGN.md](DATABASE_DESIGN.md) - ERD and database design details
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture documentation (if exists)

## Prerequisites

- Oracle Database 12c or higher
- SQL*Plus or SQL Developer
- Database user with the following privileges:
  - CREATE TABLE
  - CREATE SEQUENCE
  - CREATE VIEW
  - CREATE TYPE
  - CREATE PROCEDURE
  - CREATE TRIGGER
  - CREATE INDEX
  - Sufficient tablespace quota

## Installation

### Quick Install

```sql
SQL> @INSTALL_ALL.sql
```

This master script installs all layers in the correct order.

### Manual Installation (Step by Step)

If you prefer to install layer by layer:

```sql
-- 1. Physical Layer
SQL> @database/physical_layer/01_sequences.sql
SQL> @database/physical_layer/02_tables_ordering.sql
SQL> @database/physical_layer/03_tables_billing.sql
SQL> @database/physical_layer/04_tables_delivery.sql
SQL> @database/physical_layer/05_tables_reservations.sql
SQL> @database/physical_layer/06_indexes.sql
SQL> @database/physical_layer/07_triggers.sql

-- 2. Logical Layer
SQL> @database/logical_layer/01_types.sql
SQL> @database/logical_layer/02_views_ordering.sql
SQL> @database/logical_layer/03_views_billing.sql
SQL> @database/logical_layer/04_views_delivery.sql
SQL> @database/logical_layer/05_views_reservations.sql

-- 3. Application Layer
SQL> @database/application_layer/01_pkg_ord_api.pks
SQL> @database/application_layer/02_pkg_ord_api.pkb
SQL> @database/application_layer/03_pkg_bil_api.pks
SQL> @database/application_layer/04_pkg_bil_api.pkb
SQL> @database/application_layer/05_pkg_del_api.sql
SQL> @database/application_layer/06_pkg_res_api.sql
```

## Features

### 1. Ordering (PKG_ORD_API)

Create and manage customer orders with automatic tax calculation.

**Example: Create an Order**
```sql
DECLARE
  v_items TYP_ORD_ITEMS_TAB;
  v_order_id NUMBER;
  v_order_number VARCHAR2(50);
  v_total NUMBER;
BEGIN
  -- Create items collection
  v_items := TYP_ORD_ITEMS_TAB(
    TYP_ORD_ITEM_REC('BURGER-001', 'Classic Burger', 2, 12.99, NULL),
    TYP_ORD_ITEM_REC('FRIES-001', 'French Fries', 1, 4.99, 'Extra crispy')
  );

  -- Create order
  PKG_ORD_API.PRC_CREATE_ORDER(
    p_customer_name => 'John Doe',
    p_customer_phone => '555-1234',
    p_customer_email => 'john@example.com',
    p_order_type => 'DINE_IN',
    p_table_number => 5,
    p_items => v_items,
    p_order_id => v_order_id,
    p_order_number => v_order_number,
    p_total_amount => v_total
  );

  DBMS_OUTPUT.PUT_LINE('Order Created: ' || v_order_number);
  DBMS_OUTPUT.PUT_LINE('Total Amount: $' || v_total);
END;
/
```

**Update Order Status**
```sql
BEGIN
  PKG_ORD_API.PRC_UPDATE_ORDER_STATUS(
    p_order_id => 1001,
    p_new_status => 'CONFIRMED'
  );
END;
/
```

**View Active Orders**
```sql
SELECT * FROM VW_ORD_ACTIVE_ORDERS;
```

### 2. Billing (PKG_BIL_API)

Handle payments and bill management.

**Example: Create Bill and Add Payment**
```sql
DECLARE
  v_bill_id NUMBER;
  v_bill_number VARCHAR2(50);
  v_total NUMBER;
  v_payment_id NUMBER;
BEGIN
  -- Create bill for order
  PKG_BIL_API.PRC_CREATE_BILL(
    p_order_id => 1001,
    p_tip_amount => 5.00,
    p_bill_id => v_bill_id,
    p_bill_number => v_bill_number,
    p_total_amount => v_total
  );

  -- Add payment
  PKG_BIL_API.PRC_ADD_PAYMENT(
    p_bill_id => v_bill_id,
    p_payment_amount => v_total,
    p_payment_method => 'CREDIT_CARD',
    p_transaction_id => 'TXN123456',
    p_payment_id => v_payment_id
  );

  DBMS_OUTPUT.PUT_LINE('Bill: ' || v_bill_number);
  DBMS_OUTPUT.PUT_LINE('Payment ID: ' || v_payment_id);
END;
/
```

**View Revenue Report**
```sql
SELECT * FROM VW_BIL_DAILY_REVENUE
WHERE REVENUE_DATE >= TRUNC(SYSDATE) - 7
ORDER BY REVENUE_DATE DESC;
```

### 3. Delivery (PKG_DEL_API)

Manage deliveries and drivers.

**Example: Create Delivery and Assign Driver**
```sql
DECLARE
  v_delivery_id NUMBER;
  v_delivery_number VARCHAR2(50);
  v_driver_id NUMBER;
BEGIN
  -- Create delivery
  PKG_DEL_API.PRC_CREATE_DELIVERY(
    p_order_id => 1001,
    p_delivery_address => '123 Main St, City, 12345',
    p_delivery_lat => 40.7128,
    p_delivery_long => -74.0060,
    p_delivery_id => v_delivery_id,
    p_delivery_number => v_delivery_number
  );

  -- Assign driver
  PKG_DEL_API.PRC_ASSIGN_DRIVER(
    p_delivery_id => v_delivery_id,
    p_driver_id => 1  -- Available driver
  );

  DBMS_OUTPUT.PUT_LINE('Delivery: ' || v_delivery_number);
END;
/
```

**View Active Deliveries**
```sql
SELECT * FROM VW_DEL_ACTIVE_DELIVERIES;
```

### 4. Reservations (PKG_RES_API)

Handle table reservations.

**Example: Create Reservation and Assign Table**
```sql
DECLARE
  v_reservation_id NUMBER;
  v_reservation_number VARCHAR2(50);
  v_tables TYP_RES_TABLES_TAB;
BEGIN
  -- Check availability
  v_tables := PKG_RES_API.FNC_CHECK_AVAILABILITY(
    p_date => TRUNC(SYSDATE + 1),
    p_time => '19:00',
    p_party_size => 4
  );

  -- Create reservation
  PKG_RES_API.PRC_CREATE_RESERVATION(
    p_customer_name => 'Jane Smith',
    p_customer_phone => '555-5678',
    p_party_size => 4,
    p_reservation_date => TRUNC(SYSDATE + 1),
    p_reservation_time => '19:00',
    p_reservation_id => v_reservation_id,
    p_reservation_number => v_reservation_number
  );

  -- Assign table
  IF v_tables.COUNT > 0 THEN
    PKG_RES_API.PRC_ASSIGN_TABLE(
      p_reservation_id => v_reservation_id,
      p_table_id => v_tables(1).TABLE_ID
    );
  END IF;

  DBMS_OUTPUT.PUT_LINE('Reservation: ' || v_reservation_number);
END;
/
```

**View Today's Reservations**
```sql
SELECT * FROM VW_RES_TODAYS_RESERVATIONS;
```

## Database Objects Summary

| Layer      | Object Type | Prefix | Count |
|------------|-------------|--------|-------|
| Physical   | Tables      | TBL_   | 9     |
| Physical   | Sequences   | SEQ_   | 9     |
| Physical   | Indexes     | IDX_   | 20+   |
| Physical   | Triggers    | TRG_   | 14    |
| Logical    | Types       | TYP_   | 15+   |
| Logical    | Views       | VW_    | 20+   |
| Application| Packages    | PKG_   | 4     |

## Naming Conventions

```
Tables:      TBL_<FEATURE>_<ENTITY>    (e.g., TBL_ORD_ORDERS)
Sequences:   SEQ_<FEATURE>_<ENTITY>    (e.g., SEQ_ORD_ORDERS)
Indexes:     IDX_<TABLE>_<COLUMNS>     (e.g., IDX_TBL_ORD_ORDERS_STATUS)
Constraints: PK_/FK_/CK_/UK_<TABLE>    (e.g., PK_TBL_ORD_ORDERS)
Triggers:    TRG_<TABLE>_<TIMING>_<EVENT> (e.g., TRG_TBL_ORD_ORDERS_BIR)
Views:       VW_<FEATURE>_<PURPOSE>    (e.g., VW_ORD_ORDERS_SUMMARY)
Types:       TYP_<FEATURE>_<PURPOSE>   (e.g., TYP_ORD_ITEM_REC)
Packages:    PKG_<FEATURE>_<PURPOSE>   (e.g., PKG_ORD_API)
```

## Security

### Recommended Privileges

For application users:
```sql
-- Grant execute on packages only (not direct table access)
GRANT EXECUTE ON PKG_ORD_API TO app_user;
GRANT EXECUTE ON PKG_BIL_API TO app_user;
GRANT EXECUTE ON PKG_DEL_API TO app_user;
GRANT EXECUTE ON PKG_RES_API TO app_user;

-- Grant read-only access to views for reporting
GRANT SELECT ON VW_ORD_ORDERS_SUMMARY TO app_user;
GRANT SELECT ON VW_BIL_DAILY_REVENUE TO app_user;
```

## Maintenance

### Gather Statistics
```sql
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(USER);
```

### Rebuild Indexes (if needed)
```sql
-- Find fragmented indexes
SELECT index_name, blevel, leaf_blocks
FROM user_indexes
WHERE blevel > 3;

-- Rebuild
ALTER INDEX idx_name REBUILD;
```

### Archive Old Data
```sql
-- Archive orders older than 1 year
CREATE TABLE TBL_ORD_ORDERS_ARCHIVE AS
SELECT * FROM TBL_ORD_ORDERS
WHERE CREATED_DATE < ADD_MONTHS(SYSDATE, -12);

DELETE FROM TBL_ORD_ORDERS
WHERE CREATED_DATE < ADD_MONTHS(SYSDATE, -12);

COMMIT;
```

## Troubleshooting

### Check Invalid Objects
```sql
SELECT object_type, object_name, status
FROM user_objects
WHERE status != 'VALID'
ORDER BY object_type, object_name;
```

### Recompile Invalid Objects
```sql
BEGIN
  DBMS_UTILITY.COMPILE_SCHEMA(USER);
END;
/
```

### View Package Errors
```sql
SHOW ERRORS PACKAGE PKG_ORD_API;
SHOW ERRORS PACKAGE BODY PKG_ORD_API;
```

## Performance Tips

1. **Use Bind Variables**: Always use bind variables in application code
2. **Bulk Operations**: Use BULK COLLECT and FORALL for large datasets
3. **Index Usage**: Monitor index usage with AWR reports
4. **Partitioning**: Consider partitioning large tables by date
5. **Statistics**: Keep statistics up-to-date

## Future Enhancements

- Menu management feature
- Employee/staff management
- Inventory management
- Loyalty program
- Analytics and reporting dashboard
- Integration with external payment gateways
- Mobile app API endpoints
- Real-time notifications

## Support

For issues, questions, or contributions:
- Review [METHODOLOGY.md](METHODOLOGY.md) for architectural guidance
- Check [DATABASE_DESIGN.md](DATABASE_DESIGN.md) for ERD and structure
- Refer to package specifications for API documentation

## License

[Your License Here]

## Credits

Restaurant POS System - Oracle PL/SQL Implementation
Built with feature-based architecture and three-layer design principles.
