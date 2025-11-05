/*==============================================================================
 * File: 01_sequences.sql
 * Purpose: Create all sequences for generating primary keys
 * Layer: Physical Layer
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating Sequences
PROMPT ========================================
PROMPT

-- ============================================================================
-- ORDERING Feature Sequences
-- ============================================================================

PROMPT Creating SEQ_ORD_ORDERS...
CREATE SEQUENCE SEQ_ORD_ORDERS
  START WITH 1001
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

PROMPT Creating SEQ_ORD_ORDER_ITEMS...
CREATE SEQUENCE SEQ_ORD_ORDER_ITEMS
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- ============================================================================
-- BILLING Feature Sequences
-- ============================================================================

PROMPT Creating SEQ_BIL_BILLS...
CREATE SEQUENCE SEQ_BIL_BILLS
  START WITH 5001
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

PROMPT Creating SEQ_BIL_PAYMENTS...
CREATE SEQUENCE SEQ_BIL_PAYMENTS
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- ============================================================================
-- DELIVERY Feature Sequences
-- ============================================================================

PROMPT Creating SEQ_DEL_DRIVERS...
CREATE SEQUENCE SEQ_DEL_DRIVERS
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

PROMPT Creating SEQ_DEL_DELIVERIES...
CREATE SEQUENCE SEQ_DEL_DELIVERIES
  START WITH 7001
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

PROMPT Creating SEQ_DEL_TRACKING...
CREATE SEQUENCE SEQ_DEL_TRACKING
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- ============================================================================
-- RESERVATIONS Feature Sequences
-- ============================================================================

PROMPT Creating SEQ_RES_TABLES...
CREATE SEQUENCE SEQ_RES_TABLES
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

PROMPT Creating SEQ_RES_RESERVATIONS...
CREATE SEQUENCE SEQ_RES_RESERVATIONS
  START WITH 3001
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

PROMPT
PROMPT Sequences created successfully!
PROMPT
