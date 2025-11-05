/*==============================================================================
 * File: 05_tables_reservations.sql
 * Purpose: Create tables for RESERVATIONS feature
 * Layer: Physical Layer
 * Feature: RESERVATIONS (RES)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating RESERVATIONS Feature Tables
PROMPT ========================================
PROMPT

-- ============================================================================
-- Table: TBL_RES_TABLES
-- Purpose: Store restaurant table information
-- ============================================================================

PROMPT Creating TBL_RES_TABLES...
CREATE TABLE TBL_RES_TABLES (
  TABLE_ID              NUMBER            NOT NULL,
  TABLE_NUMBER          NUMBER            NOT NULL,
  CAPACITY              NUMBER            NOT NULL,
  LOCATION              VARCHAR2(50),
  FEATURES              VARCHAR2(500),
  STATUS                VARCHAR2(20)      DEFAULT 'AVAILABLE' NOT NULL,
  CREATED_DATE          DATE              DEFAULT SYSDATE NOT NULL,
  UPDATED_DATE          DATE,
  -- Constraints
  CONSTRAINT PK_TBL_RES_TABLES PRIMARY KEY (TABLE_ID),
  CONSTRAINT UK_TBL_RES_TABLES_NUMBER UNIQUE (TABLE_NUMBER),
  CONSTRAINT CK_TBL_RES_TABLES_STATUS CHECK (
    STATUS IN ('AVAILABLE', 'OCCUPIED', 'RESERVED', 'CLEANING')
  ),
  CONSTRAINT CK_TBL_RES_TABLES_CAPACITY CHECK (CAPACITY > 0)
);

COMMENT ON TABLE TBL_RES_TABLES IS 'Stores restaurant table information';
COMMENT ON COLUMN TBL_RES_TABLES.TABLE_ID IS 'Primary key - unique table identifier';
COMMENT ON COLUMN TBL_RES_TABLES.TABLE_NUMBER IS 'Business key - table number (visible to customers)';
COMMENT ON COLUMN TBL_RES_TABLES.CAPACITY IS 'Maximum number of guests for this table';
COMMENT ON COLUMN TBL_RES_TABLES.LOCATION IS 'Table location (e.g., window, patio, indoor)';
COMMENT ON COLUMN TBL_RES_TABLES.FEATURES IS 'Special features (e.g., wheelchair accessible)';
COMMENT ON COLUMN TBL_RES_TABLES.STATUS IS 'Current table status';

-- ============================================================================
-- Table: TBL_RES_RESERVATIONS
-- Purpose: Store customer reservations
-- ============================================================================

PROMPT Creating TBL_RES_RESERVATIONS...
CREATE TABLE TBL_RES_RESERVATIONS (
  RESERVATION_ID        NUMBER            NOT NULL,
  RESERVATION_NUMBER    VARCHAR2(50)      NOT NULL,
  CUSTOMER_NAME         VARCHAR2(200)     NOT NULL,
  CUSTOMER_EMAIL        VARCHAR2(200),
  CUSTOMER_PHONE        VARCHAR2(50)      NOT NULL,
  TABLE_ID              NUMBER,
  PARTY_SIZE            NUMBER            NOT NULL,
  RESERVATION_DATE      DATE              NOT NULL,
  RESERVATION_TIME      VARCHAR2(5)       NOT NULL,
  DURATION_MINUTES      NUMBER            DEFAULT 90 NOT NULL,
  STATUS                VARCHAR2(20)      DEFAULT 'PENDING' NOT NULL,
  SPECIAL_REQUESTS      VARCHAR2(500),
  OCCASION              VARCHAR2(100),
  ARRIVAL_TIME          DATE,
  SEATED_TIME           DATE,
  COMPLETED_TIME        DATE,
  NOTES                 VARCHAR2(500),
  CREATED_BY            VARCHAR2(100)     DEFAULT USER,
  CREATED_DATE          DATE              DEFAULT SYSDATE NOT NULL,
  UPDATED_BY            VARCHAR2(100),
  UPDATED_DATE          DATE,
  -- Constraints
  CONSTRAINT PK_TBL_RES_RESERVATIONS PRIMARY KEY (RESERVATION_ID),
  CONSTRAINT UK_TBL_RES_RESERV_NUMBER UNIQUE (RESERVATION_NUMBER),
  CONSTRAINT FK_TBL_RES_RESERV_TABLE FOREIGN KEY (TABLE_ID)
    REFERENCES TBL_RES_TABLES(TABLE_ID),
  CONSTRAINT CK_TBL_RES_RESERV_STATUS CHECK (
    STATUS IN ('PENDING', 'CONFIRMED', 'SEATED', 'COMPLETED', 'CANCELLED', 'NO_SHOW')
  ),
  CONSTRAINT CK_TBL_RES_RESERV_PARTY CHECK (PARTY_SIZE > 0),
  CONSTRAINT CK_TBL_RES_RESERV_DURATION CHECK (DURATION_MINUTES > 0),
  CONSTRAINT CK_TBL_RES_RESERV_TIME CHECK (
    REGEXP_LIKE(RESERVATION_TIME, '^([01][0-9]|2[0-3]):[0-5][0-9]$')
  )
);

COMMENT ON TABLE TBL_RES_RESERVATIONS IS 'Stores customer table reservations';
COMMENT ON COLUMN TBL_RES_RESERVATIONS.RESERVATION_ID IS 'Primary key - unique reservation identifier';
COMMENT ON COLUMN TBL_RES_RESERVATIONS.RESERVATION_NUMBER IS 'Business key - reservation number (e.g., RES-3001)';
COMMENT ON COLUMN TBL_RES_RESERVATIONS.TABLE_ID IS 'Foreign key to TBL_RES_TABLES (assigned table)';
COMMENT ON COLUMN TBL_RES_RESERVATIONS.PARTY_SIZE IS 'Number of guests in party';
COMMENT ON COLUMN TBL_RES_RESERVATIONS.RESERVATION_TIME IS 'Time in HH24:MI format (e.g., 19:30)';
COMMENT ON COLUMN TBL_RES_RESERVATIONS.DURATION_MINUTES IS 'Expected duration in minutes';
COMMENT ON COLUMN TBL_RES_RESERVATIONS.STATUS IS 'Current reservation status';

PROMPT RESERVATIONS tables created successfully!
PROMPT
