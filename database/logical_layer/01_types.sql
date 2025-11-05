/*==============================================================================
 * File: 01_types.sql
 * Purpose: Create Object Types and Collections for data structures
 * Layer: Logical Layer
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating Object Types & Collections
PROMPT ========================================
PROMPT

-- ============================================================================
-- ORDERING Feature Types
-- ============================================================================

PROMPT Creating types for ORDERING feature...

-- Type: Single order item record
CREATE OR REPLACE TYPE TYP_ORD_ITEM_REC AS OBJECT (
  MENU_ITEM_ID          VARCHAR2(50),
  ITEM_NAME             VARCHAR2(200),
  QUANTITY              NUMBER,
  UNIT_PRICE            NUMBER,
  SPECIAL_INSTRUCTIONS  VARCHAR2(500)
);
/

-- Type: Collection of order items
CREATE OR REPLACE TYPE TYP_ORD_ITEMS_TAB AS TABLE OF TYP_ORD_ITEM_REC;
/

-- Type: Order summary record
CREATE OR REPLACE TYPE TYP_ORD_ORDER_REC AS OBJECT (
  ORDER_ID              NUMBER,
  ORDER_NUMBER          VARCHAR2(50),
  CUSTOMER_NAME         VARCHAR2(200),
  CUSTOMER_PHONE        VARCHAR2(50),
  ORDER_TYPE            VARCHAR2(20),
  TOTAL_AMOUNT          NUMBER,
  STATUS                VARCHAR2(20),
  CREATED_DATE          DATE
);
/

-- Type: Collection of order summaries
CREATE OR REPLACE TYPE TYP_ORD_ORDERS_TAB AS TABLE OF TYP_ORD_ORDER_REC;
/

-- ============================================================================
-- BILLING Feature Types
-- ============================================================================

PROMPT Creating types for BILLING feature...

-- Type: Payment record
CREATE OR REPLACE TYPE TYP_BIL_PAYMENT_REC AS OBJECT (
  PAYMENT_AMOUNT        NUMBER,
  PAYMENT_METHOD        VARCHAR2(20),
  TRANSACTION_ID        VARCHAR2(100)
);
/

-- Type: Collection of payments
CREATE OR REPLACE TYPE TYP_BIL_PAYMENTS_TAB AS TABLE OF TYP_BIL_PAYMENT_REC;
/

-- Type: Bill summary record
CREATE OR REPLACE TYPE TYP_BIL_BILL_REC AS OBJECT (
  BILL_ID               NUMBER,
  BILL_NUMBER           VARCHAR2(50),
  ORDER_ID              NUMBER,
  TOTAL_AMOUNT          NUMBER,
  AMOUNT_PAID           NUMBER,
  AMOUNT_DUE            NUMBER,
  PAYMENT_STATUS        VARCHAR2(20),
  CREATED_DATE          DATE
);
/

-- ============================================================================
-- DELIVERY Feature Types
-- ============================================================================

PROMPT Creating types for DELIVERY feature...

-- Type: Driver record
CREATE OR REPLACE TYPE TYP_DEL_DRIVER_REC AS OBJECT (
  DRIVER_ID             NUMBER,
  DRIVER_NAME           VARCHAR2(200),
  PHONE_NUMBER          VARCHAR2(50),
  VEHICLE_TYPE          VARCHAR2(50),
  IS_AVAILABLE          CHAR(1)
);
/

-- Type: Collection of drivers
CREATE OR REPLACE TYPE TYP_DEL_DRIVERS_TAB AS TABLE OF TYP_DEL_DRIVER_REC;
/

-- Type: Delivery summary record
CREATE OR REPLACE TYPE TYP_DEL_DELIVERY_REC AS OBJECT (
  DELIVERY_ID           NUMBER,
  DELIVERY_NUMBER       VARCHAR2(50),
  ORDER_ID              NUMBER,
  DRIVER_NAME           VARCHAR2(200),
  DELIVERY_ADDRESS      VARCHAR2(500),
  STATUS                VARCHAR2(20),
  EST_DELIVERY_TIME     DATE,
  ACTUAL_DELIVERY_TIME  DATE
);
/

-- Type: Tracking event record
CREATE OR REPLACE TYPE TYP_DEL_TRACKING_REC AS OBJECT (
  TRACKING_ID           NUMBER,
  STATUS                VARCHAR2(20),
  MESSAGE               VARCHAR2(500),
  TRACKING_DATE         DATE
);
/

-- Type: Collection of tracking events
CREATE OR REPLACE TYPE TYP_DEL_TRACKING_TAB AS TABLE OF TYP_DEL_TRACKING_REC;
/

-- ============================================================================
-- RESERVATIONS Feature Types
-- ============================================================================

PROMPT Creating types for RESERVATIONS feature...

-- Type: Table record
CREATE OR REPLACE TYPE TYP_RES_TABLE_REC AS OBJECT (
  TABLE_ID              NUMBER,
  TABLE_NUMBER          NUMBER,
  CAPACITY              NUMBER,
  LOCATION              VARCHAR2(50),
  STATUS                VARCHAR2(20)
);
/

-- Type: Collection of tables
CREATE OR REPLACE TYPE TYP_RES_TABLES_TAB AS TABLE OF TYP_RES_TABLE_REC;
/

-- Type: Reservation record
CREATE OR REPLACE TYPE TYP_RES_RESERVATION_REC AS OBJECT (
  RESERVATION_ID        NUMBER,
  RESERVATION_NUMBER    VARCHAR2(50),
  CUSTOMER_NAME         VARCHAR2(200),
  CUSTOMER_PHONE        VARCHAR2(50),
  TABLE_NUMBER          NUMBER,
  PARTY_SIZE            NUMBER,
  RESERVATION_DATE      DATE,
  RESERVATION_TIME      VARCHAR2(5),
  STATUS                VARCHAR2(20)
);
/

-- Type: Collection of reservations
CREATE OR REPLACE TYPE TYP_RES_RESERVATIONS_TAB AS TABLE OF TYP_RES_RESERVATION_REC;
/

-- ============================================================================
-- COMMON/SYSTEM Types
-- ============================================================================

PROMPT Creating common/system types...

-- Type: Generic result record
CREATE OR REPLACE TYPE TYP_SYS_RESULT_REC AS OBJECT (
  SUCCESS               CHAR(1),         -- Y/N
  MESSAGE               VARCHAR2(500),
  ERROR_CODE            VARCHAR2(50),
  RECORD_ID             NUMBER
);
/

-- Type: Key-value pair for parameters
CREATE OR REPLACE TYPE TYP_SYS_PARAM_REC AS OBJECT (
  PARAM_NAME            VARCHAR2(100),
  PARAM_VALUE           VARCHAR2(4000)
);
/

-- Type: Collection of parameters
CREATE OR REPLACE TYPE TYP_SYS_PARAMS_TAB AS TABLE OF TYP_SYS_PARAM_REC;
/

PROMPT
PROMPT Object Types & Collections created successfully!
PROMPT
