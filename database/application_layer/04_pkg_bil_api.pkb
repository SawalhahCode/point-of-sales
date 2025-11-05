/*==============================================================================
 * Package Body: PKG_BIL_API
 * Purpose: Implementation of BILLING feature API
 *============================================================================*/

CREATE OR REPLACE PACKAGE BODY PKG_BIL_API AS

  PROCEDURE PRC_CREATE_BILL(
    p_order_id      IN  NUMBER,
    p_tip_amount    IN  NUMBER DEFAULT 0,
    p_bill_id       OUT NUMBER,
    p_bill_number   OUT VARCHAR2,
    p_total_amount  OUT NUMBER
  ) IS
    v_subtotal   NUMBER;
    v_tax        NUMBER;
    v_total      NUMBER;
    v_bill_count NUMBER;
  BEGIN
    -- Check if bill already exists for this order
    SELECT COUNT(*)
    INTO v_bill_count
    FROM TBL_BIL_BILLS
    WHERE ORDER_ID = p_order_id;

    IF v_bill_count > 0 THEN
      RAISE_APPLICATION_ERROR(-20400, 'Bill already exists for this order');
    END IF;

    -- Get order totals
    SELECT SUBTOTAL, TAX_AMOUNT, TOTAL_AMOUNT
    INTO v_subtotal, v_tax, v_total
    FROM TBL_ORD_ORDERS
    WHERE ORDER_ID = p_order_id;

    -- Add tip to total
    v_total := v_total + NVL(p_tip_amount, 0);

    -- Insert bill
    INSERT INTO TBL_BIL_BILLS (
      ORDER_ID,
      SUBTOTAL,
      TAX_AMOUNT,
      TIP_AMOUNT,
      TOTAL_AMOUNT,
      AMOUNT_PAID,
      AMOUNT_DUE,
      PAYMENT_STATUS
    ) VALUES (
      p_order_id,
      v_subtotal,
      v_tax,
      NVL(p_tip_amount, 0),
      v_total,
      0,
      v_total,
      C_STATUS_PENDING
    ) RETURNING BILL_ID, BILL_NUMBER INTO p_bill_id, p_bill_number;

    p_total_amount := v_total;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END PRC_CREATE_BILL;

  PROCEDURE PRC_ADD_PAYMENT(
    p_bill_id          IN NUMBER,
    p_payment_amount   IN NUMBER,
    p_payment_method   IN VARCHAR2,
    p_transaction_id   IN VARCHAR2 DEFAULT NULL,
    p_payment_id       OUT NUMBER
  ) IS
    v_amount_due NUMBER;
    v_new_amount_paid NUMBER;
    v_new_amount_due NUMBER;
    v_new_status VARCHAR2(20);
  BEGIN
    -- Get current amount due
    SELECT AMOUNT_DUE
    INTO v_amount_due
    FROM TBL_BIL_BILLS
    WHERE BILL_ID = p_bill_id
    FOR UPDATE;

    IF p_payment_amount > v_amount_due THEN
      RAISE_APPLICATION_ERROR(C_ERR_PAYMENT_EXCEEDS,
        'Payment amount exceeds amount due');
    END IF;

    -- Insert payment
    INSERT INTO TBL_BIL_PAYMENTS (
      BILL_ID,
      PAYMENT_AMOUNT,
      PAYMENT_METHOD,
      TRANSACTION_ID
    ) VALUES (
      p_bill_id,
      p_payment_amount,
      p_payment_method,
      p_transaction_id
    ) RETURNING PAYMENT_ID INTO p_payment_id;

    -- Update bill
    v_new_amount_paid := v_amount_due - (v_amount_due - p_payment_amount);
    v_new_amount_due := v_amount_due - p_payment_amount;

    IF v_new_amount_due = 0 THEN
      v_new_status := C_STATUS_PAID;
    ELSE
      v_new_status := C_STATUS_PARTIALLY_PAID;
    END IF;

    UPDATE TBL_BIL_BILLS
    SET AMOUNT_PAID = AMOUNT_PAID + p_payment_amount,
        AMOUNT_DUE = v_new_amount_due,
        PAYMENT_STATUS = v_new_status
    WHERE BILL_ID = p_bill_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END PRC_ADD_PAYMENT;

  PROCEDURE PRC_APPLY_DISCOUNT(
    p_bill_id         IN NUMBER,
    p_discount_amount IN NUMBER,
    p_reason          IN VARCHAR2 DEFAULT NULL
  ) IS
    v_current_total NUMBER;
    v_new_total NUMBER;
  BEGIN
    SELECT TOTAL_AMOUNT
    INTO v_current_total
    FROM TBL_BIL_BILLS
    WHERE BILL_ID = p_bill_id;

    v_new_total := v_current_total - p_discount_amount;

    UPDATE TBL_BIL_BILLS
    SET DISCOUNT_AMOUNT = DISCOUNT_AMOUNT + p_discount_amount,
        TOTAL_AMOUNT = v_new_total,
        AMOUNT_DUE = v_new_total - AMOUNT_PAID,
        NOTES = NVL(NOTES, '') || ' | Discount: ' || NVL(p_reason, 'Not specified')
    WHERE BILL_ID = p_bill_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END PRC_APPLY_DISCOUNT;

  PROCEDURE PRC_REFUND_PAYMENT(
    p_payment_id IN NUMBER,
    p_reason     IN VARCHAR2 DEFAULT NULL
  ) IS
    v_bill_id NUMBER;
    v_payment_amount NUMBER;
  BEGIN
    SELECT BILL_ID, PAYMENT_AMOUNT
    INTO v_bill_id, v_payment_amount
    FROM TBL_BIL_PAYMENTS
    WHERE PAYMENT_ID = p_payment_id;

    DELETE FROM TBL_BIL_PAYMENTS
    WHERE PAYMENT_ID = p_payment_id;

    UPDATE TBL_BIL_BILLS
    SET AMOUNT_PAID = AMOUNT_PAID - v_payment_amount,
        AMOUNT_DUE = AMOUNT_DUE + v_payment_amount,
        PAYMENT_STATUS = CASE
          WHEN AMOUNT_PAID - v_payment_amount = 0 THEN C_STATUS_REFUNDED
          ELSE C_STATUS_PARTIALLY_PAID
        END,
        NOTES = NVL(NOTES, '') || ' | Refund: ' || NVL(p_reason, 'Not specified')
    WHERE BILL_ID = v_bill_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END PRC_REFUND_PAYMENT;

  FUNCTION FNC_GET_BILL_STATUS(
    p_bill_id IN NUMBER
  ) RETURN VARCHAR2 IS
    v_status VARCHAR2(20);
  BEGIN
    SELECT PAYMENT_STATUS
    INTO v_status
    FROM TBL_BIL_BILLS
    WHERE BILL_ID = p_bill_id;

    RETURN v_status;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(C_ERR_BILL_NOT_FOUND, 'Bill not found');
  END FNC_GET_BILL_STATUS;

  FUNCTION FNC_GET_BILL_BY_ORDER(
    p_order_id IN NUMBER
  ) RETURN NUMBER IS
    v_bill_id NUMBER;
  BEGIN
    SELECT BILL_ID
    INTO v_bill_id
    FROM TBL_BIL_BILLS
    WHERE ORDER_ID = p_order_id;

    RETURN v_bill_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END FNC_GET_BILL_BY_ORDER;

  FUNCTION FNC_GET_TOTAL_REVENUE(
    p_from_date IN DATE DEFAULT NULL,
    p_to_date   IN DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_revenue NUMBER;
  BEGIN
    SELECT NVL(SUM(TOTAL_AMOUNT), 0)
    INTO v_revenue
    FROM TBL_BIL_BILLS
    WHERE PAYMENT_STATUS = C_STATUS_PAID
      AND (p_from_date IS NULL OR CREATED_DATE >= p_from_date)
      AND (p_to_date IS NULL OR CREATED_DATE <= p_to_date);

    RETURN v_revenue;
  END FNC_GET_TOTAL_REVENUE;

END PKG_BIL_API;
/
