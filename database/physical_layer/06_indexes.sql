/*==============================================================================
 * File: 06_indexes.sql
 * Purpose: Create indexes for performance optimization
 * Layer: Physical Layer
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *
 * Note: Primary Key and Unique constraints automatically create indexes
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating Indexes
PROMPT ========================================
PROMPT

-- ============================================================================
-- ORDERING Feature Indexes
-- ============================================================================

PROMPT Creating indexes for ORDERING feature...

-- Foreign key index for performance
CREATE INDEX IDX_TBL_ORD_ITEMS_ORDER_ID
  ON TBL_ORD_ORDER_ITEMS(ORDER_ID);

-- Business query indexes
CREATE INDEX IDX_TBL_ORD_ORDERS_STATUS
  ON TBL_ORD_ORDERS(STATUS);

CREATE INDEX IDX_TBL_ORD_ORDERS_CREATED
  ON TBL_ORD_ORDERS(CREATED_DATE);

CREATE INDEX IDX_TBL_ORD_ORDERS_TYPE
  ON TBL_ORD_ORDERS(ORDER_TYPE);

-- Composite index for date range queries with status
CREATE INDEX IDX_TBL_ORD_ORDERS_DATE_STAT
  ON TBL_ORD_ORDERS(CREATED_DATE, STATUS);

-- ============================================================================
-- BILLING Feature Indexes
-- ============================================================================

PROMPT Creating indexes for BILLING feature...

-- Foreign key indexes
CREATE INDEX IDX_TBL_BIL_BILLS_ORDER_ID
  ON TBL_BIL_BILLS(ORDER_ID);

CREATE INDEX IDX_TBL_BIL_PAYMENTS_BILL_ID
  ON TBL_BIL_PAYMENTS(BILL_ID);

-- Business query indexes
CREATE INDEX IDX_TBL_BIL_BILLS_STATUS
  ON TBL_BIL_BILLS(PAYMENT_STATUS);

CREATE INDEX IDX_TBL_BIL_BILLS_CREATED
  ON TBL_BIL_BILLS(CREATED_DATE);

CREATE INDEX IDX_TBL_BIL_BILLS_PAID_DATE
  ON TBL_BIL_BILLS(PAID_DATE);

-- Index for payment method reporting
CREATE INDEX IDX_TBL_BIL_PAYMENTS_METHOD
  ON TBL_BIL_PAYMENTS(PAYMENT_METHOD);

-- Composite index for revenue queries
CREATE INDEX IDX_TBL_BIL_BILLS_DATE_STAT
  ON TBL_BIL_BILLS(CREATED_DATE, PAYMENT_STATUS);

-- ============================================================================
-- DELIVERY Feature Indexes
-- ============================================================================

PROMPT Creating indexes for DELIVERY feature...

-- Foreign key indexes
CREATE INDEX IDX_TBL_DEL_DELIV_ORDER_ID
  ON TBL_DEL_DELIVERIES(ORDER_ID);

CREATE INDEX IDX_TBL_DEL_DELIV_DRIVER_ID
  ON TBL_DEL_DELIVERIES(DRIVER_ID);

CREATE INDEX IDX_TBL_DEL_TRACK_DELIV_ID
  ON TBL_DEL_DELIVERY_TRACKING(DELIVERY_ID);

-- Business query indexes
CREATE INDEX IDX_TBL_DEL_DELIVERIES_STAT
  ON TBL_DEL_DELIVERIES(STATUS);

CREATE INDEX IDX_TBL_DEL_DRIVERS_AVAILABLE
  ON TBL_DEL_DRIVERS(IS_AVAILABLE);

CREATE INDEX IDX_TBL_DEL_DELIVERIES_CREATED
  ON TBL_DEL_DELIVERIES(CREATED_DATE);

-- Composite index for driver assignment queries
CREATE INDEX IDX_TBL_DEL_DELIV_STAT_DRIVER
  ON TBL_DEL_DELIVERIES(STATUS, DRIVER_ID);

-- ============================================================================
-- RESERVATIONS Feature Indexes
-- ============================================================================

PROMPT Creating indexes for RESERVATIONS feature...

-- Foreign key index
CREATE INDEX IDX_TBL_RES_RESERV_TABLE_ID
  ON TBL_RES_RESERVATIONS(TABLE_ID);

-- Business query indexes
CREATE INDEX IDX_TBL_RES_RESERV_STATUS
  ON TBL_RES_RESERVATIONS(STATUS);

CREATE INDEX IDX_TBL_RES_TABLES_STATUS
  ON TBL_RES_TABLES(STATUS);

-- Critical composite index for availability checking
CREATE INDEX IDX_TBL_RES_RESERV_DATE_TIME
  ON TBL_RES_RESERVATIONS(RESERVATION_DATE, RESERVATION_TIME, STATUS);

-- Index for phone number lookups
CREATE INDEX IDX_TBL_RES_RESERV_PHONE
  ON TBL_RES_RESERVATIONS(CUSTOMER_PHONE);

-- Index for finding reservations by date
CREATE INDEX IDX_TBL_RES_RESERV_DATE
  ON TBL_RES_RESERVATIONS(RESERVATION_DATE);

PROMPT
PROMPT Indexes created successfully!
PROMPT

-- Gather statistics on new indexes
PROMPT Gathering statistics...
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(USER);

PROMPT Statistics gathered successfully!
PROMPT
