/*==============================================================================
 * File: 04_tables_delivery.sql
 * Purpose: Create tables for DELIVERY feature
 * Layer: Physical Layer
 * Feature: DELIVERY (DEL)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating DELIVERY Feature Tables
PROMPT ========================================
PROMPT

-- ============================================================================
-- Table: TBL_DEL_DRIVERS
-- Purpose: Store delivery driver information
-- ============================================================================

PROMPT Creating TBL_DEL_DRIVERS...
CREATE TABLE TBL_DEL_DRIVERS (
  DRIVER_ID             NUMBER            NOT NULL,
  DRIVER_NAME           VARCHAR2(200)     NOT NULL,
  PHONE_NUMBER          VARCHAR2(50)      NOT NULL,
  VEHICLE_TYPE          VARCHAR2(50)      NOT NULL,
  VEHICLE_NUMBER        VARCHAR2(50)      NOT NULL,
  IS_AVAILABLE          CHAR(1)           DEFAULT 'Y' NOT NULL,
  CURRENT_LAT           NUMBER(10,6),
  CURRENT_LONG          NUMBER(10,6),
  CREATED_DATE          DATE              DEFAULT SYSDATE NOT NULL,
  UPDATED_DATE          DATE,
  -- Constraints
  CONSTRAINT PK_TBL_DEL_DRIVERS PRIMARY KEY (DRIVER_ID),
  CONSTRAINT CK_TBL_DEL_DRIVERS_AVAILABLE CHECK (IS_AVAILABLE IN ('Y', 'N'))
);

COMMENT ON TABLE TBL_DEL_DRIVERS IS 'Stores delivery driver information';
COMMENT ON COLUMN TBL_DEL_DRIVERS.DRIVER_ID IS 'Primary key - unique driver identifier';
COMMENT ON COLUMN TBL_DEL_DRIVERS.IS_AVAILABLE IS 'Y if driver is available for new deliveries';
COMMENT ON COLUMN TBL_DEL_DRIVERS.CURRENT_LAT IS 'Current latitude coordinate';
COMMENT ON COLUMN TBL_DEL_DRIVERS.CURRENT_LONG IS 'Current longitude coordinate';

-- ============================================================================
-- Table: TBL_DEL_DELIVERIES
-- Purpose: Store delivery information for orders
-- ============================================================================

PROMPT Creating TBL_DEL_DELIVERIES...
CREATE TABLE TBL_DEL_DELIVERIES (
  DELIVERY_ID           NUMBER            NOT NULL,
  DELIVERY_NUMBER       VARCHAR2(50)      NOT NULL,
  ORDER_ID              NUMBER            NOT NULL,
  DRIVER_ID             NUMBER,
  PICKUP_ADDRESS        VARCHAR2(500)     NOT NULL,
  DELIVERY_ADDRESS      VARCHAR2(500)     NOT NULL,
  DELIVERY_LAT          NUMBER(10,6),
  DELIVERY_LONG         NUMBER(10,6),
  DELIVERY_INSTRUCTIONS VARCHAR2(500),
  DISTANCE_KM           NUMBER(10,2),
  DELIVERY_FEE          NUMBER(10,2)      NOT NULL,
  STATUS                VARCHAR2(20)      DEFAULT 'PENDING' NOT NULL,
  EST_PICKUP_TIME       DATE,
  ACTUAL_PICKUP_TIME    DATE,
  EST_DELIVERY_TIME     DATE,
  ACTUAL_DELIVERY_TIME  DATE,
  NOTES                 VARCHAR2(500),
  CREATED_DATE          DATE              DEFAULT SYSDATE NOT NULL,
  UPDATED_DATE          DATE,
  -- Constraints
  CONSTRAINT PK_TBL_DEL_DELIVERIES PRIMARY KEY (DELIVERY_ID),
  CONSTRAINT UK_TBL_DEL_DELIVERIES_NUM UNIQUE (DELIVERY_NUMBER),
  CONSTRAINT FK_TBL_DEL_DELIVERIES_ORD FOREIGN KEY (ORDER_ID)
    REFERENCES TBL_ORD_ORDERS(ORDER_ID),
  CONSTRAINT FK_TBL_DEL_DELIVERIES_DRV FOREIGN KEY (DRIVER_ID)
    REFERENCES TBL_DEL_DRIVERS(DRIVER_ID),
  CONSTRAINT CK_TBL_DEL_DELIVERIES_STAT CHECK (
    STATUS IN ('PENDING', 'ASSIGNED', 'PICKED_UP', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED')
  ),
  CONSTRAINT CK_TBL_DEL_DELIVERIES_DIST CHECK (DISTANCE_KM >= 0),
  CONSTRAINT CK_TBL_DEL_DELIVERIES_FEE CHECK (DELIVERY_FEE >= 0)
);

COMMENT ON TABLE TBL_DEL_DELIVERIES IS 'Stores delivery information for orders';
COMMENT ON COLUMN TBL_DEL_DELIVERIES.DELIVERY_ID IS 'Primary key - unique delivery identifier';
COMMENT ON COLUMN TBL_DEL_DELIVERIES.DELIVERY_NUMBER IS 'Business key - delivery number (e.g., DEL-7001)';
COMMENT ON COLUMN TBL_DEL_DELIVERIES.ORDER_ID IS 'Foreign key to TBL_ORD_ORDERS';
COMMENT ON COLUMN TBL_DEL_DELIVERIES.DRIVER_ID IS 'Foreign key to TBL_DEL_DRIVERS (assigned driver)';
COMMENT ON COLUMN TBL_DEL_DELIVERIES.STATUS IS 'Current delivery status';

-- ============================================================================
-- Table: TBL_DEL_DELIVERY_TRACKING
-- Purpose: Store delivery tracking history
-- ============================================================================

PROMPT Creating TBL_DEL_DELIVERY_TRACKING...
CREATE TABLE TBL_DEL_DELIVERY_TRACKING (
  TRACKING_ID           NUMBER            NOT NULL,
  DELIVERY_ID           NUMBER            NOT NULL,
  STATUS                VARCHAR2(20)      NOT NULL,
  LOCATION_LAT          NUMBER(10,6),
  LOCATION_LONG         NUMBER(10,6),
  MESSAGE               VARCHAR2(500)     NOT NULL,
  TRACKING_DATE         DATE              DEFAULT SYSDATE NOT NULL,
  -- Constraints
  CONSTRAINT PK_TBL_DEL_TRACKING PRIMARY KEY (TRACKING_ID),
  CONSTRAINT FK_TBL_DEL_TRACKING_DEL FOREIGN KEY (DELIVERY_ID)
    REFERENCES TBL_DEL_DELIVERIES(DELIVERY_ID) ON DELETE CASCADE
);

COMMENT ON TABLE TBL_DEL_DELIVERY_TRACKING IS 'Stores tracking history for deliveries';
COMMENT ON COLUMN TBL_DEL_DELIVERY_TRACKING.TRACKING_ID IS 'Primary key - unique tracking identifier';
COMMENT ON COLUMN TBL_DEL_DELIVERY_TRACKING.DELIVERY_ID IS 'Foreign key to TBL_DEL_DELIVERIES';
COMMENT ON COLUMN TBL_DEL_DELIVERY_TRACKING.STATUS IS 'Status at time of tracking';
COMMENT ON COLUMN TBL_DEL_DELIVERY_TRACKING.MESSAGE IS 'Tracking message/description';

PROMPT DELIVERY tables created successfully!
PROMPT
