/*==============================================================================
 * File: 02_tables_ordering.sql
 * Purpose: Create tables for ORDERING feature
 * Layer: Physical Layer
 * Feature: ORDERING (ORD)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating ORDERING Feature Tables
PROMPT ========================================
PROMPT

-- ============================================================================
-- Table: TBL_ORD_ORDERS
-- Purpose: Store customer orders (main order information)
-- ============================================================================

PROMPT Creating TBL_ORD_ORDERS...
CREATE TABLE TBL_ORD_ORDERS (
  ORDER_ID              NUMBER            NOT NULL,
  ORDER_NUMBER          VARCHAR2(50)      NOT NULL,
  CUSTOMER_NAME         VARCHAR2(200)     NOT NULL,
  CUSTOMER_EMAIL        VARCHAR2(200),
  CUSTOMER_PHONE        VARCHAR2(50)      NOT NULL,
  CUSTOMER_ADDRESS      VARCHAR2(500),
  ORDER_TYPE            VARCHAR2(20)      NOT NULL,
  TABLE_NUMBER          NUMBER,
  SUBTOTAL              NUMBER(10,2)      NOT NULL,
  TAX_AMOUNT            NUMBER(10,2)      NOT NULL,
  TOTAL_AMOUNT          NUMBER(10,2)      NOT NULL,
  STATUS                VARCHAR2(20)      DEFAULT 'PENDING' NOT NULL,
  SPECIAL_INSTRUCTIONS  CLOB,
  CREATED_BY            VARCHAR2(100)     DEFAULT USER,
  CREATED_DATE          DATE              DEFAULT SYSDATE NOT NULL,
  UPDATED_BY            VARCHAR2(100),
  UPDATED_DATE          DATE,
  COMPLETED_DATE        DATE,
  -- Constraints
  CONSTRAINT PK_TBL_ORD_ORDERS PRIMARY KEY (ORDER_ID),
  CONSTRAINT UK_TBL_ORD_ORDERS_NUMBER UNIQUE (ORDER_NUMBER),
  CONSTRAINT CK_TBL_ORD_ORDERS_STATUS CHECK (
    STATUS IN ('PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'COMPLETED', 'CANCELLED')
  ),
  CONSTRAINT CK_TBL_ORD_ORDERS_TYPE CHECK (
    ORDER_TYPE IN ('DINE_IN', 'TAKEOUT', 'DELIVERY')
  ),
  CONSTRAINT CK_TBL_ORD_ORDERS_SUBTOTAL CHECK (SUBTOTAL >= 0),
  CONSTRAINT CK_TBL_ORD_ORDERS_TAX CHECK (TAX_AMOUNT >= 0),
  CONSTRAINT CK_TBL_ORD_ORDERS_TOTAL CHECK (TOTAL_AMOUNT >= 0)
);

COMMENT ON TABLE TBL_ORD_ORDERS IS 'Stores customer orders for dine-in, takeout, and delivery';
COMMENT ON COLUMN TBL_ORD_ORDERS.ORDER_ID IS 'Primary key - unique order identifier';
COMMENT ON COLUMN TBL_ORD_ORDERS.ORDER_NUMBER IS 'Business key - order number (e.g., ORD-1001)';
COMMENT ON COLUMN TBL_ORD_ORDERS.ORDER_TYPE IS 'Type of order: DINE_IN, TAKEOUT, or DELIVERY';
COMMENT ON COLUMN TBL_ORD_ORDERS.STATUS IS 'Current order status';

-- ============================================================================
-- Table: TBL_ORD_ORDER_ITEMS
-- Purpose: Store individual items in an order
-- ============================================================================

PROMPT Creating TBL_ORD_ORDER_ITEMS...
CREATE TABLE TBL_ORD_ORDER_ITEMS (
  ITEM_ID               NUMBER            NOT NULL,
  ORDER_ID              NUMBER            NOT NULL,
  MENU_ITEM_ID          VARCHAR2(50)      NOT NULL,
  ITEM_NAME             VARCHAR2(200)     NOT NULL,
  QUANTITY              NUMBER            NOT NULL,
  UNIT_PRICE            NUMBER(10,2)      NOT NULL,
  SUBTOTAL              NUMBER(10,2)      NOT NULL,
  SPECIAL_INSTRUCTIONS  VARCHAR2(500),
  CREATED_DATE          DATE              DEFAULT SYSDATE NOT NULL,
  -- Constraints
  CONSTRAINT PK_TBL_ORD_ORDER_ITEMS PRIMARY KEY (ITEM_ID),
  CONSTRAINT FK_TBL_ORD_ITEMS_ORDER FOREIGN KEY (ORDER_ID)
    REFERENCES TBL_ORD_ORDERS(ORDER_ID) ON DELETE CASCADE,
  CONSTRAINT CK_TBL_ORD_ITEMS_QTY CHECK (QUANTITY > 0),
  CONSTRAINT CK_TBL_ORD_ITEMS_PRICE CHECK (UNIT_PRICE >= 0),
  CONSTRAINT CK_TBL_ORD_ITEMS_SUBTOTAL CHECK (SUBTOTAL >= 0)
);

COMMENT ON TABLE TBL_ORD_ORDER_ITEMS IS 'Stores line items for each order';
COMMENT ON COLUMN TBL_ORD_ORDER_ITEMS.ITEM_ID IS 'Primary key - unique item identifier';
COMMENT ON COLUMN TBL_ORD_ORDER_ITEMS.ORDER_ID IS 'Foreign key to TBL_ORD_ORDERS';
COMMENT ON COLUMN TBL_ORD_ORDER_ITEMS.MENU_ITEM_ID IS 'Reference to menu item (external ID)';
COMMENT ON COLUMN TBL_ORD_ORDER_ITEMS.SUBTOTAL IS 'Calculated: QUANTITY * UNIT_PRICE';

PROMPT ORDERING tables created successfully!
PROMPT
