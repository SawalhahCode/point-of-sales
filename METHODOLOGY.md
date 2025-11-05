# Oracle PL/SQL Feature-Based Methodology

## Overview

This document describes the methodology for building a feature-based restaurant ordering system using Oracle Database with a clear separation of concerns across three architectural layers.

## Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│              APPLICATION LAYER (PL/SQL)                  │
│  - Packages (PKG_*)                                      │
│  - Business Logic & Procedures                           │
│  - API Functions                                         │
│  - Validation & Error Handling                           │
└────────────────────┬────────────────────────────────────┘
                     │ Uses
┌────────────────────▼────────────────────────────────────┐
│              LOGICAL LAYER (Views & Types)               │
│  - Views (VW_*)                                          │
│  - Object Types (TYP_*)                                  │
│  - Collections                                           │
│  - Materialized Views                                    │
└────────────────────┬────────────────────────────────────┘
                     │ Built on
┌────────────────────▼────────────────────────────────────┐
│              PHYSICAL LAYER (Database Objects)           │
│  - Tables (TBL_*)                                        │
│  - Sequences (SEQ_*)                                     │
│  - Indexes (IDX_*)                                       │
│  - Constraints (PK_*, FK_*, CK_*, UK_*)                  │
│  - Triggers (TRG_*)                                      │
└─────────────────────────────────────────────────────────┘
```

## Layer Descriptions

### 1. Physical Layer (Database Objects)

**Purpose**: Store and organize data physically on disk

**Components**:
- **Tables (TBL_*)**: Physical storage of data
- **Sequences (SEQ_*)**: Generate unique IDs
- **Indexes (IDX_*)**: Optimize query performance
- **Primary Keys (PK_*)**: Unique row identifiers
- **Foreign Keys (FK_*)**: Referential integrity
- **Check Constraints (CK_*)**: Data validation
- **Unique Constraints (UK_*)**: Unique values
- **Triggers (TRG_*)**: Automated actions

**Naming Convention**:
```sql
Tables:      TBL_<FEATURE>_<ENTITY>
             Example: TBL_ORD_ORDERS, TBL_ORD_ORDER_ITEMS

Sequences:   SEQ_<FEATURE>_<ENTITY>
             Example: SEQ_ORD_ORDERS

Indexes:     IDX_<TABLE>_<COLUMNS>
             Example: IDX_TBL_ORD_ORDERS_CUSTOMER_ID

Constraints:
  PK:        PK_<TABLE>
  FK:        FK_<TABLE>_<REFERENCE>
  CK:        CK_<TABLE>_<COLUMN>
  UK:        UK_<TABLE>_<COLUMNS>

Triggers:    TRG_<TABLE>_<TIMING>_<EVENT>
             Example: TRG_TBL_ORD_ORDERS_BIR (Before Insert Row)
```

**Characteristics**:
- Permanent storage
- Performance-critical
- Rarely changed after deployment
- Schema changes require careful planning

### 2. Logical Layer (Views & Types)

**Purpose**: Provide logical abstraction and reusable structures

**Components**:
- **Views (VW_*)**: Logical data representation
- **Object Types (TYP_*)**: Custom data structures
- **Collections**: Arrays and nested tables
- **Materialized Views (MV_*)**: Precomputed aggregations

**Naming Convention**:
```sql
Views:       VW_<FEATURE>_<ENTITY>
             Example: VW_ORD_ORDERS_SUMMARY

Types:       TYP_<FEATURE>_<PURPOSE>
             Example: TYP_ORD_ORDER_REC, TYP_ORD_ITEM_REC

Collections: TYP_<FEATURE>_<PURPOSE>_TAB
             Example: TYP_ORD_ITEMS_TAB

Materialized:MV_<FEATURE>_<PURPOSE>
             Example: MV_RPT_DAILY_REVENUE
```

**Characteristics**:
- No data storage (views)
- Simplify complex queries
- Provide security layer
- Easier to modify than physical layer

**View Types**:

1. **Simple Views**: Direct table access with selection
```sql
CREATE OR REPLACE VIEW VW_ORD_ACTIVE_ORDERS AS
SELECT order_id, order_number, customer_name, status
FROM TBL_ORD_ORDERS
WHERE status IN ('PENDING', 'CONFIRMED', 'PREPARING');
```

2. **Complex Views**: Multi-table joins with calculations
```sql
CREATE OR REPLACE VIEW VW_ORD_ORDERS_DETAIL AS
SELECT
    o.order_id,
    o.order_number,
    o.customer_name,
    COUNT(oi.item_id) as total_items,
    SUM(oi.subtotal) as order_total
FROM TBL_ORD_ORDERS o
JOIN TBL_ORD_ORDER_ITEMS oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, o.customer_name;
```

3. **Security Views**: Row-level security
```sql
CREATE OR REPLACE VIEW VW_ORD_USER_ORDERS AS
SELECT * FROM TBL_ORD_ORDERS
WHERE created_by = USER;
```

### 3. Application Layer (PL/SQL Packages)

**Purpose**: Implement business logic and provide APIs

**Components**:
- **Package Specifications (PKG_*_API)**: Public interface
- **Package Bodies**: Implementation
- **Procedures**: Operations with side effects
- **Functions**: Return values
- **Exception Handlers**: Error management

**Naming Convention**:
```sql
Packages:    PKG_<FEATURE>_<PURPOSE>
             Example: PKG_ORD_API, PKG_ORD_UTILS

Procedures:  PRC_<ACTION>_<ENTITY>
             Example: PRC_CREATE_ORDER, PRC_UPDATE_STATUS

Functions:   FNC_<PURPOSE>
             Example: FNC_CALCULATE_TOTAL, FNC_CHECK_AVAILABILITY
```

**Package Structure**:
```sql
-- Specification (Interface)
CREATE OR REPLACE PACKAGE PKG_ORD_API AS
  -- Public procedures
  PROCEDURE PRC_CREATE_ORDER(
    p_customer_name   IN VARCHAR2,
    p_order_items     IN TYP_ORD_ITEMS_TAB,
    p_order_id        OUT NUMBER
  );

  -- Public functions
  FUNCTION FNC_GET_ORDER_STATUS(
    p_order_id IN NUMBER
  ) RETURN VARCHAR2;

END PKG_ORD_API;

-- Body (Implementation)
CREATE OR REPLACE PACKAGE BODY PKG_ORD_API AS
  -- Private variables
  g_tax_rate CONSTANT NUMBER := 0.08;

  -- Private procedures
  PROCEDURE PRC_CALCULATE_TOTALS(...) IS
  BEGIN
    -- Implementation
  END;

  -- Public implementations
  PROCEDURE PRC_CREATE_ORDER(...) IS
  BEGIN
    -- Implementation
  END;

END PKG_ORD_API;
```

## Feature-Based Organization

Each feature is self-contained with its own set of objects across all three layers:

### Feature Structure

```
ORDERING Feature (ORD)
├── Physical Layer
│   ├── TBL_ORD_ORDERS
│   ├── TBL_ORD_ORDER_ITEMS
│   ├── SEQ_ORD_ORDERS
│   └── Indexes, Constraints, Triggers
├── Logical Layer
│   ├── VW_ORD_ORDERS_SUMMARY
│   ├── VW_ORD_ACTIVE_ORDERS
│   ├── TYP_ORD_ORDER_REC
│   └── TYP_ORD_ITEMS_TAB
└── Application Layer
    ├── PKG_ORD_API (Main API)
    ├── PKG_ORD_UTILS (Utilities)
    └── PKG_ORD_VALIDATIONS (Validations)
```

## Feature Codes

Each feature has a 3-letter code:

- **ORD**: Ordering
- **BIL**: Billing
- **DEL**: Delivery
- **RES**: Reservations
- **RPT**: Reporting (cross-feature)
- **SYS**: System utilities

## Dependencies & Relationships

### Inter-Layer Dependencies

```
APPLICATION → LOGICAL → PHYSICAL
(Can use)      (Can use)   (Foundation)
```

**Rules**:
1. Application layer CAN use Logical and Physical layers
2. Logical layer CAN use Physical layer only
3. Physical layer CANNOT reference other layers
4. Always prefer using Logical layer from Application layer

### Inter-Feature Dependencies

```
         ┌──────────┐
         │ ORDERING │ (Independent)
         └────┬─────┘
              │ order_id
     ┌────────┼────────┐
     │        │        │
┌────▼───┐ ┌─▼────┐ ┌─▼──────┐
│ BILLING│ │DELIVER│ │RESERVAT│
└────────┘ └──────┘ └────────┘
(Depends)  (Depends) (Independ)
```

**Dependency Matrix**:

| Feature      | Depends On  | Reason                |
|--------------|-------------|-----------------------|
| Ordering     | None        | Core feature          |
| Billing      | Ordering    | Needs order data      |
| Delivery     | Ordering    | Needs order data      |
| Reservations | None        | Independent feature   |

### Impact Analysis

When changing a layer, here's what gets affected:

**Physical Layer Changes**:
```
TBL_ORD_ORDERS (add column)
  ↓ Affects
  ├─ VW_ORD_ORDERS_SUMMARY (may need update)
  ├─ TYP_ORD_ORDER_REC (may need new field)
  └─ PKG_ORD_API (may need new parameter)
```

**Logical Layer Changes**:
```
VW_ORD_ORDERS_SUMMARY (change view logic)
  ↓ Affects
  └─ PKG_ORD_API (if using this view)
```

**Application Layer Changes**:
```
PKG_ORD_API (change procedure signature)
  ↓ Affects
  └─ External applications calling this package
```

## Error Handling Strategy

### Standard Error Codes

```sql
-- System Errors: -20000 to -20099
-20001: Generic System Error
-20002: Database Connection Error
-20003: Transaction Error

-- Validation Errors: -20100 to -20199
-20101: Required Field Missing
-20102: Invalid Data Format
-20103: Invalid Value
-20104: Duplicate Entry

-- Business Logic Errors: -20200 to -20299
-20201: Insufficient Permissions
-20202: Business Rule Violation
-20203: Invalid State Transition
-20204: Resource Not Available

-- Feature-Specific Errors: -20300 onwards
-- Ordering: -20300 to -20399
-20301: Order Not Found
-20302: Order Already Cancelled
-20303: Invalid Order Status

-- Billing: -20400 to -20499
-20401: Bill Not Found
-20402: Payment Amount Exceeds Due Amount
-20403: Bill Already Paid

-- Delivery: -20500 to -20599
-20501: Delivery Not Found
-20502: Driver Not Available

-- Reservations: -20600 to -20699
-20601: Reservation Not Found
-20602: Table Not Available
```

### Error Handling Pattern

```sql
CREATE OR REPLACE PACKAGE BODY PKG_ORD_API AS

  PROCEDURE PRC_CREATE_ORDER(...) IS
    v_order_id NUMBER;
  BEGIN
    -- Input validation
    IF p_customer_name IS NULL THEN
      RAISE_APPLICATION_ERROR(-20101, 'Customer name is required');
    END IF;

    -- Business logic
    BEGIN
      -- Implementation
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        -- Log error
        PKG_SYS_UTILS.PRC_LOG_ERROR(
          p_package => 'PKG_ORD_API',
          p_procedure => 'PRC_CREATE_ORDER',
          p_error_msg => SQLERRM
        );
        RAISE;
    END;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,
        'Error creating order: ' || SQLERRM);
  END PRC_CREATE_ORDER;

END PKG_ORD_API;
```

## Installation Order

### 1. Physical Layer (Bottom-Up)
```sql
-- 1.1 Sequences
@physical/sequences.sql

-- 1.2 Tables (respect FK dependencies)
@physical/tables/independent_tables.sql
@physical/tables/dependent_tables.sql

-- 1.3 Indexes
@physical/indexes.sql

-- 1.4 Triggers
@physical/triggers.sql
```

### 2. Logical Layer
```sql
-- 2.1 Object Types
@logical/types.sql

-- 2.2 Views (simple first, then complex)
@logical/views/simple_views.sql
@logical/views/complex_views.sql
```

### 3. Application Layer
```sql
-- 3.1 Package Specifications (API contracts)
@application/specifications/pkg_ord_api.pks
@application/specifications/pkg_bil_api.pks
@application/specifications/pkg_del_api.pks
@application/specifications/pkg_res_api.pks

-- 3.2 Package Bodies (implementations)
@application/bodies/pkg_ord_api.pkb
@application/bodies/pkg_bil_api.pkb
@application/bodies/pkg_del_api.pkb
@application/bodies/pkg_res_api.pkb
```

## Development Workflow

### 1. Design Phase
- Define feature requirements
- Design ERD (Physical layer)
- Define data structures (Logical layer)
- Design API interface (Application layer)

### 2. Implementation Phase
- Create physical objects (tables, sequences)
- Create logical objects (views, types)
- Implement packages (specification → body)
- Write unit tests

### 3. Testing Phase
- Unit test each package procedure/function
- Integration test cross-feature interactions
- Performance test with sample data
- Security test access controls

### 4. Deployment Phase
- Generate installation scripts
- Document dependencies
- Execute in correct order
- Verify compilation
- Run smoke tests

## Best Practices

### 1. Physical Layer
- Always use surrogate keys (sequences)
- Index foreign keys
- Add audit columns (created_by, created_date, updated_by, updated_date)
- Use check constraints for status fields
- Document constraints clearly

### 2. Logical Layer
- Keep views simple and focused
- Use view naming to indicate complexity
- Document view dependencies
- Create types for complex structures
- Use collections for bulk operations

### 3. Application Layer
- One package per feature
- Keep procedures focused (single responsibility)
- Use OUT parameters for return values
- Always handle exceptions
- Log all errors
- Use constants for magic numbers
- Comment complex logic
- Version your packages

### 4. General
- Use consistent naming conventions
- Document all objects
- Keep related objects together
- Use version control
- Review code before deployment
- Test thoroughly
- Monitor performance

## Benefits of This Methodology

1. **Separation of Concerns**: Each layer has clear responsibility
2. **Maintainability**: Easy to locate and modify code
3. **Scalability**: Add features without affecting others
4. **Testability**: Test each layer independently
5. **Reusability**: Share types and views across features
6. **Security**: Control access at package level
7. **Performance**: Optimize at appropriate layer
8. **Team Collaboration**: Multiple developers can work on different features

## Conclusion

This methodology provides a robust, scalable architecture for building enterprise applications in Oracle Database. By clearly separating Physical, Logical, and Application layers, and organizing by features, we create a maintainable and extensible system.
