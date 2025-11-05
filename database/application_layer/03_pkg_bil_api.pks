/*==============================================================================
 * Package: PKG_BIL_API
 * Purpose: API for BILLING feature - Public interface
 * Layer: Application Layer
 * Feature: BILLING (BIL)
 *============================================================================*/

CREATE OR REPLACE PACKAGE PKG_BIL_API AS

  -- Constants
  C_STATUS_PENDING        CONSTANT VARCHAR2(20) := 'PENDING';
  C_STATUS_PAID           CONSTANT VARCHAR2(20) := 'PAID';
  C_STATUS_PARTIALLY_PAID CONSTANT VARCHAR2(20) := 'PARTIALLY_PAID';
  C_STATUS_FAILED         CONSTANT VARCHAR2(20) := 'FAILED';
  C_STATUS_REFUNDED       CONSTANT VARCHAR2(20) := 'REFUNDED';

  -- Payment methods
  C_METHOD_CASH           CONSTANT VARCHAR2(20) := 'CASH';
  C_METHOD_CREDIT_CARD    CONSTANT VARCHAR2(20) := 'CREDIT_CARD';
  C_METHOD_DEBIT_CARD     CONSTANT VARCHAR2(20) := 'DEBIT_CARD';
  C_METHOD_MOBILE         CONSTANT VARCHAR2(20) := 'MOBILE_PAYMENT';

  -- Error codes
  C_ERR_BILL_NOT_FOUND    CONSTANT NUMBER := -20401;
  C_ERR_BILL_PAID         CONSTANT NUMBER := -20402;
  C_ERR_PAYMENT_EXCEEDS   CONSTANT NUMBER := -20403;

  -- Public Procedures
  PROCEDURE PRC_CREATE_BILL(
    p_order_id      IN  NUMBER,
    p_tip_amount    IN  NUMBER DEFAULT 0,
    p_bill_id       OUT NUMBER,
    p_bill_number   OUT VARCHAR2,
    p_total_amount  OUT NUMBER
  );

  PROCEDURE PRC_ADD_PAYMENT(
    p_bill_id          IN NUMBER,
    p_payment_amount   IN NUMBER,
    p_payment_method   IN VARCHAR2,
    p_transaction_id   IN VARCHAR2 DEFAULT NULL,
    p_payment_id       OUT NUMBER
  );

  PROCEDURE PRC_APPLY_DISCOUNT(
    p_bill_id         IN NUMBER,
    p_discount_amount IN NUMBER,
    p_reason          IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE PRC_REFUND_PAYMENT(
    p_payment_id IN NUMBER,
    p_reason     IN VARCHAR2 DEFAULT NULL
  );

  -- Public Functions
  FUNCTION FNC_GET_BILL_STATUS(
    p_bill_id IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION FNC_GET_BILL_BY_ORDER(
    p_order_id IN NUMBER
  ) RETURN NUMBER;

  FUNCTION FNC_GET_TOTAL_REVENUE(
    p_from_date IN DATE DEFAULT NULL,
    p_to_date   IN DATE DEFAULT NULL
  ) RETURN NUMBER;

END PKG_BIL_API;
/
