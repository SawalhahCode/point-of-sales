/*==============================================================================
 * File: 03_tables_billing.sql
 * Purpose: Create tables for BILLING feature
 * Layer: Physical Layer
 * Feature: BILLING (BIL)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating BILLING Feature Tables
PROMPT ========================================
PROMPT

-- ============================================================================
-- Table: TBL_BIL_BILLS
-- Purpose: Store bills for orders
-- ============================================================================

PROMPT Creating TBL_BIL_BILLS...
CREATE TABLE TBL_BIL_BILLS (
  BILL_ID               NUMBER            NOT NULL,
  BILL_NUMBER           VARCHAR2(50)      NOT NULL,
  ORDER_ID              NUMBER            NOT NULL,
  SUBTOTAL              NUMBER(10,2)      NOT NULL,
  TAX_AMOUNT            NUMBER(10,2)      NOT NULL,
  DISCOUNT_AMOUNT       NUMBER(10,2)      DEFAULT 0 NOT NULL,
  TIP_AMOUNT            NUMBER(10,2)      DEFAULT 0 NOT NULL,
  TOTAL_AMOUNT          NUMBER(10,2)      NOT NULL,
  AMOUNT_PAID           NUMBER(10,2)      DEFAULT 0 NOT NULL,
  AMOUNT_DUE            NUMBER(10,2)      NOT NULL,
  PAYMENT_STATUS        VARCHAR2(20)      DEFAULT 'PENDING' NOT NULL,
  NOTES                 VARCHAR2(500),
  CREATED_BY            VARCHAR2(100)     DEFAULT USER,
  CREATED_DATE          DATE              DEFAULT SYSDATE NOT NULL,
  UPDATED_BY            VARCHAR2(100),
  UPDATED_DATE          DATE,
  PAID_DATE             DATE,
  -- Constraints
  CONSTRAINT PK_TBL_BIL_BILLS PRIMARY KEY (BILL_ID),
  CONSTRAINT UK_TBL_BIL_BILLS_NUMBER UNIQUE (BILL_NUMBER),
  CONSTRAINT FK_TBL_BIL_BILLS_ORDER FOREIGN KEY (ORDER_ID)
    REFERENCES TBL_ORD_ORDERS(ORDER_ID),
  CONSTRAINT CK_TBL_BIL_BILLS_STATUS CHECK (
    PAYMENT_STATUS IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'PARTIALLY_PAID')
  ),
  CONSTRAINT CK_TBL_BIL_BILLS_SUBTOTAL CHECK (SUBTOTAL >= 0),
  CONSTRAINT CK_TBL_BIL_BILLS_TAX CHECK (TAX_AMOUNT >= 0),
  CONSTRAINT CK_TBL_BIL_BILLS_DISCOUNT CHECK (DISCOUNT_AMOUNT >= 0),
  CONSTRAINT CK_TBL_BIL_BILLS_TIP CHECK (TIP_AMOUNT >= 0),
  CONSTRAINT CK_TBL_BIL_BILLS_TOTAL CHECK (TOTAL_AMOUNT >= 0),
  CONSTRAINT CK_TBL_BIL_BILLS_PAID CHECK (AMOUNT_PAID >= 0),
  CONSTRAINT CK_TBL_BIL_BILLS_DUE CHECK (AMOUNT_DUE >= 0)
);

COMMENT ON TABLE TBL_BIL_BILLS IS 'Stores bills for customer orders';
COMMENT ON COLUMN TBL_BIL_BILLS.BILL_ID IS 'Primary key - unique bill identifier';
COMMENT ON COLUMN TBL_BIL_BILLS.BILL_NUMBER IS 'Business key - bill number (e.g., BILL-5001)';
COMMENT ON COLUMN TBL_BIL_BILLS.ORDER_ID IS 'Foreign key to TBL_ORD_ORDERS';
COMMENT ON COLUMN TBL_BIL_BILLS.TOTAL_AMOUNT IS 'Calculated: SUBTOTAL + TAX - DISCOUNT + TIP';
COMMENT ON COLUMN TBL_BIL_BILLS.AMOUNT_DUE IS 'Remaining amount: TOTAL_AMOUNT - AMOUNT_PAID';

-- ============================================================================
-- Table: TBL_BIL_PAYMENTS
-- Purpose: Store payment transactions for bills
-- ============================================================================

PROMPT Creating TBL_BIL_PAYMENTS...
CREATE TABLE TBL_BIL_PAYMENTS (
  PAYMENT_ID            NUMBER            NOT NULL,
  BILL_ID               NUMBER            NOT NULL,
  PAYMENT_AMOUNT        NUMBER(10,2)      NOT NULL,
  PAYMENT_METHOD        VARCHAR2(20)      NOT NULL,
  TRANSACTION_ID        VARCHAR2(100),
  PAYMENT_DATE          DATE              DEFAULT SYSDATE NOT NULL,
  PROCESSED_BY          VARCHAR2(100)     DEFAULT USER,
  NOTES                 VARCHAR2(500),
  -- Constraints
  CONSTRAINT PK_TBL_BIL_PAYMENTS PRIMARY KEY (PAYMENT_ID),
  CONSTRAINT FK_TBL_BIL_PAYMENTS_BILL FOREIGN KEY (BILL_ID)
    REFERENCES TBL_BIL_BILLS(BILL_ID) ON DELETE CASCADE,
  CONSTRAINT CK_TBL_BIL_PAYMENTS_METHOD CHECK (
    PAYMENT_METHOD IN ('CASH', 'CREDIT_CARD', 'DEBIT_CARD', 'MOBILE_PAYMENT', 'ONLINE')
  ),
  CONSTRAINT CK_TBL_BIL_PAYMENTS_AMOUNT CHECK (PAYMENT_AMOUNT > 0)
);

COMMENT ON TABLE TBL_BIL_PAYMENTS IS 'Stores payment transactions for bills';
COMMENT ON COLUMN TBL_BIL_PAYMENTS.PAYMENT_ID IS 'Primary key - unique payment identifier';
COMMENT ON COLUMN TBL_BIL_PAYMENTS.BILL_ID IS 'Foreign key to TBL_BIL_BILLS';
COMMENT ON COLUMN TBL_BIL_PAYMENTS.PAYMENT_METHOD IS 'Method of payment';
COMMENT ON COLUMN TBL_BIL_PAYMENTS.TRANSACTION_ID IS 'External transaction reference (for card payments)';

PROMPT BILLING tables created successfully!
PROMPT
