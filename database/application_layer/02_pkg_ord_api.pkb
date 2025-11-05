/*==============================================================================
 * Package Body: PKG_ORD_API
 * Purpose: Implementation of ORDERING feature API
 * Layer: Application Layer
 * Feature: ORDERING (ORD)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

CREATE OR REPLACE PACKAGE BODY PKG_ORD_API AS

  -- ========================================================================
  -- Private Variables
  -- ========================================================================
  g_package_name CONSTANT VARCHAR2(30) := 'PKG_ORD_API';

  -- ========================================================================
  -- Private Procedures/Functions
  -- ========================================================================

  /*============================================================================
   * Private Function: FNC_CALCULATE_SUBTOTAL
   * Purpose: Calculate subtotal from items collection
   *===========================================================================*/
  FUNCTION FNC_CALCULATE_SUBTOTAL(
    p_items IN TYP_ORD_ITEMS_TAB
  ) RETURN NUMBER IS
    v_subtotal NUMBER := 0;
  BEGIN
    IF p_items IS NOT NULL AND p_items.COUNT > 0 THEN
      FOR i IN p_items.FIRST .. p_items.LAST LOOP
        v_subtotal := v_subtotal + (p_items(i).QUANTITY * p_items(i).UNIT_PRICE);
      END LOOP;
    END IF;

    RETURN ROUND(v_subtotal, 2);
  END FNC_CALCULATE_SUBTOTAL;

  /*============================================================================
   * Private Procedure: PRC_VALIDATE_ORDER_TYPE
   * Purpose: Validate order type
   *===========================================================================*/
  PROCEDURE PRC_VALIDATE_ORDER_TYPE(
    p_order_type IN VARCHAR2
  ) IS
  BEGIN
    IF p_order_type NOT IN (C_ORDER_TYPE_DINE_IN, C_ORDER_TYPE_TAKEOUT, C_ORDER_TYPE_DELIVERY) THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_INVALID_ORDER_TYPE,
        'Invalid order type. Must be DINE_IN, TAKEOUT, or DELIVERY'
      );
    END IF;
  END PRC_VALIDATE_ORDER_TYPE;

  /*============================================================================
   * Private Procedure: PRC_VALIDATE_ORDER_STATUS
   * Purpose: Validate order status
   *===========================================================================*/
  PROCEDURE PRC_VALIDATE_ORDER_STATUS(
    p_status IN VARCHAR2
  ) IS
  BEGIN
    IF p_status NOT IN (
      C_STATUS_PENDING,
      C_STATUS_CONFIRMED,
      C_STATUS_PREPARING,
      C_STATUS_READY,
      C_STATUS_COMPLETED,
      C_STATUS_CANCELLED
    ) THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_INVALID_STATUS,
        'Invalid order status'
      );
    END IF;
  END PRC_VALIDATE_ORDER_STATUS;

  /*============================================================================
   * Private Function: FNC_ORDER_EXISTS
   * Purpose: Check if order exists
   *===========================================================================*/
  FUNCTION FNC_ORDER_EXISTS(
    p_order_id IN NUMBER
  ) RETURN BOOLEAN IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM TBL_ORD_ORDERS
    WHERE ORDER_ID = p_order_id;

    RETURN v_count > 0;
  END FNC_ORDER_EXISTS;

  -- ========================================================================
  -- Public Procedure Implementations
  -- ========================================================================

  /*============================================================================
   * Procedure: PRC_CREATE_ORDER
   *===========================================================================*/
  PROCEDURE PRC_CREATE_ORDER(
    p_customer_name        IN  VARCHAR2,
    p_customer_phone       IN  VARCHAR2,
    p_customer_email       IN  VARCHAR2 DEFAULT NULL,
    p_customer_address     IN  VARCHAR2 DEFAULT NULL,
    p_order_type           IN  VARCHAR2,
    p_table_number         IN  NUMBER DEFAULT NULL,
    p_items                IN  TYP_ORD_ITEMS_TAB,
    p_special_instructions IN  VARCHAR2 DEFAULT NULL,
    p_order_id             OUT NUMBER,
    p_order_number         OUT VARCHAR2,
    p_total_amount         OUT NUMBER
  ) IS
    v_subtotal   NUMBER;
    v_tax        NUMBER;
    v_total      NUMBER;
  BEGIN
    -- Validate inputs
    IF p_customer_name IS NULL THEN
      RAISE_APPLICATION_ERROR(-20101, 'Customer name is required');
    END IF;

    IF p_customer_phone IS NULL THEN
      RAISE_APPLICATION_ERROR(-20101, 'Customer phone is required');
    END IF;

    IF p_items IS NULL OR p_items.COUNT = 0 THEN
      RAISE_APPLICATION_ERROR(C_ERR_NO_ITEMS, 'Order must contain at least one item');
    END IF;

    PRC_VALIDATE_ORDER_TYPE(p_order_type);

    -- Calculate totals
    v_subtotal := FNC_CALCULATE_SUBTOTAL(p_items);
    v_tax := ROUND(v_subtotal * C_TAX_RATE, 2);
    v_total := v_subtotal + v_tax;

    -- Insert order
    INSERT INTO TBL_ORD_ORDERS (
      CUSTOMER_NAME,
      CUSTOMER_PHONE,
      CUSTOMER_EMAIL,
      CUSTOMER_ADDRESS,
      ORDER_TYPE,
      TABLE_NUMBER,
      SUBTOTAL,
      TAX_AMOUNT,
      TOTAL_AMOUNT,
      STATUS,
      SPECIAL_INSTRUCTIONS
    ) VALUES (
      p_customer_name,
      p_customer_phone,
      p_customer_email,
      p_customer_address,
      p_order_type,
      p_table_number,
      v_subtotal,
      v_tax,
      v_total,
      C_STATUS_PENDING,
      p_special_instructions
    ) RETURNING ORDER_ID, ORDER_NUMBER INTO p_order_id, p_order_number;

    -- Insert order items
    IF p_items IS NOT NULL AND p_items.COUNT > 0 THEN
      FOR i IN p_items.FIRST .. p_items.LAST LOOP
        INSERT INTO TBL_ORD_ORDER_ITEMS (
          ORDER_ID,
          MENU_ITEM_ID,
          ITEM_NAME,
          QUANTITY,
          UNIT_PRICE,
          SUBTOTAL,
          SPECIAL_INSTRUCTIONS
        ) VALUES (
          p_order_id,
          p_items(i).MENU_ITEM_ID,
          p_items(i).ITEM_NAME,
          p_items(i).QUANTITY,
          p_items(i).UNIT_PRICE,
          ROUND(p_items(i).QUANTITY * p_items(i).UNIT_PRICE, 2),
          p_items(i).SPECIAL_INSTRUCTIONS
        );
      END LOOP;
    END IF;

    p_total_amount := v_total;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(
        -20001,
        'Error creating order: ' || SQLERRM
      );
  END PRC_CREATE_ORDER;

  /*============================================================================
   * Procedure: PRC_UPDATE_ORDER_STATUS
   *===========================================================================*/
  PROCEDURE PRC_UPDATE_ORDER_STATUS(
    p_order_id   IN NUMBER,
    p_new_status IN VARCHAR2,
    p_notes      IN VARCHAR2 DEFAULT NULL
  ) IS
    v_current_status VARCHAR2(20);
  BEGIN
    -- Validate status
    PRC_VALIDATE_ORDER_STATUS(p_new_status);

    -- Check if order exists
    IF NOT FNC_ORDER_EXISTS(p_order_id) THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_ORDER_NOT_FOUND,
        'Order not found: ' || p_order_id
      );
    END IF;

    -- Get current status
    SELECT STATUS
    INTO v_current_status
    FROM TBL_ORD_ORDERS
    WHERE ORDER_ID = p_order_id;

    -- Check if order is already cancelled
    IF v_current_status = C_STATUS_CANCELLED THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_ORDER_CANCELLED,
        'Cannot update status of cancelled order'
      );
    END IF;

    -- Check if order is already completed
    IF v_current_status = C_STATUS_COMPLETED AND p_new_status != C_STATUS_CANCELLED THEN
      RAISE_APPLICATION_ERROR(
        -20303,
        'Cannot update status of completed order'
      );
    END IF;

    -- Update status
    UPDATE TBL_ORD_ORDERS
    SET STATUS = p_new_status,
        UPDATED_BY = USER,
        UPDATED_DATE = SYSDATE
    WHERE ORDER_ID = p_order_id;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END PRC_UPDATE_ORDER_STATUS;

  /*============================================================================
   * Procedure: PRC_CANCEL_ORDER
   *===========================================================================*/
  PROCEDURE PRC_CANCEL_ORDER(
    p_order_id             IN NUMBER,
    p_cancellation_reason  IN VARCHAR2 DEFAULT NULL
  ) IS
    v_current_status VARCHAR2(20);
  BEGIN
    -- Check if order exists
    IF NOT FNC_ORDER_EXISTS(p_order_id) THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_ORDER_NOT_FOUND,
        'Order not found: ' || p_order_id
      );
    END IF;

    -- Get current status
    SELECT STATUS
    INTO v_current_status
    FROM TBL_ORD_ORDERS
    WHERE ORDER_ID = p_order_id;

    -- Check if already cancelled
    IF v_current_status = C_STATUS_CANCELLED THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_ORDER_CANCELLED,
        'Order is already cancelled'
      );
    END IF;

    -- Check if completed
    IF v_current_status = C_STATUS_COMPLETED THEN
      RAISE_APPLICATION_ERROR(
        -20303,
        'Cannot cancel completed order'
      );
    END IF;

    -- Cancel order
    UPDATE TBL_ORD_ORDERS
    SET STATUS = C_STATUS_CANCELLED,
        SPECIAL_INSTRUCTIONS = SPECIAL_INSTRUCTIONS ||
          CHR(10) || 'CANCELLED: ' || NVL(p_cancellation_reason, 'No reason provided'),
        UPDATED_BY = USER,
        UPDATED_DATE = SYSDATE
    WHERE ORDER_ID = p_order_id;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END PRC_CANCEL_ORDER;

  /*============================================================================
   * Procedure: PRC_ADD_ORDER_ITEM
   *===========================================================================*/
  PROCEDURE PRC_ADD_ORDER_ITEM(
    p_order_id             IN NUMBER,
    p_menu_item_id         IN VARCHAR2,
    p_item_name            IN VARCHAR2,
    p_quantity             IN NUMBER,
    p_unit_price           IN NUMBER,
    p_special_instructions IN VARCHAR2 DEFAULT NULL
  ) IS
    v_current_status VARCHAR2(20);
    v_subtotal NUMBER;
    v_new_order_total NUMBER;
  BEGIN
    -- Check if order exists
    IF NOT FNC_ORDER_EXISTS(p_order_id) THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_ORDER_NOT_FOUND,
        'Order not found: ' || p_order_id
      );
    END IF;

    -- Get current status
    SELECT STATUS
    INTO v_current_status
    FROM TBL_ORD_ORDERS
    WHERE ORDER_ID = p_order_id;

    -- Can only add items to pending or confirmed orders
    IF v_current_status NOT IN (C_STATUS_PENDING, C_STATUS_CONFIRMED) THEN
      RAISE_APPLICATION_ERROR(
        -20303,
        'Can only add items to PENDING or CONFIRMED orders'
      );
    END IF;

    -- Calculate item subtotal
    v_subtotal := ROUND(p_quantity * p_unit_price, 2);

    -- Insert item
    INSERT INTO TBL_ORD_ORDER_ITEMS (
      ORDER_ID,
      MENU_ITEM_ID,
      ITEM_NAME,
      QUANTITY,
      UNIT_PRICE,
      SUBTOTAL,
      SPECIAL_INSTRUCTIONS
    ) VALUES (
      p_order_id,
      p_menu_item_id,
      p_item_name,
      p_quantity,
      p_unit_price,
      v_subtotal,
      p_special_instructions
    );

    -- Recalculate order totals
    SELECT SUM(SUBTOTAL)
    INTO v_new_order_total
    FROM TBL_ORD_ORDER_ITEMS
    WHERE ORDER_ID = p_order_id;

    UPDATE TBL_ORD_ORDERS
    SET SUBTOTAL = v_new_order_total,
        TAX_AMOUNT = ROUND(v_new_order_total * C_TAX_RATE, 2),
        TOTAL_AMOUNT = ROUND(v_new_order_total * (1 + C_TAX_RATE), 2),
        UPDATED_BY = USER,
        UPDATED_DATE = SYSDATE
    WHERE ORDER_ID = p_order_id;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END PRC_ADD_ORDER_ITEM;

  -- ========================================================================
  -- Public Function Implementations
  -- ========================================================================

  /*============================================================================
   * Function: FNC_GET_ORDER_TOTAL
   *===========================================================================*/
  FUNCTION FNC_GET_ORDER_TOTAL(
    p_order_id IN NUMBER
  ) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT TOTAL_AMOUNT
    INTO v_total
    FROM TBL_ORD_ORDERS
    WHERE ORDER_ID = p_order_id;

    RETURN v_total;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_ORDER_NOT_FOUND,
        'Order not found: ' || p_order_id
      );
    WHEN OTHERS THEN
      RAISE;
  END FNC_GET_ORDER_TOTAL;

  /*============================================================================
   * Function: FNC_GET_ORDER_STATUS
   *===========================================================================*/
  FUNCTION FNC_GET_ORDER_STATUS(
    p_order_id IN NUMBER
  ) RETURN VARCHAR2 IS
    v_status VARCHAR2(20);
  BEGIN
    SELECT STATUS
    INTO v_status
    FROM TBL_ORD_ORDERS
    WHERE ORDER_ID = p_order_id;

    RETURN v_status;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_ORDER_NOT_FOUND,
        'Order not found: ' || p_order_id
      );
    WHEN OTHERS THEN
      RAISE;
  END FNC_GET_ORDER_STATUS;

  /*============================================================================
   * Function: FNC_GET_ACTIVE_ORDERS_COUNT
   *===========================================================================*/
  FUNCTION FNC_GET_ACTIVE_ORDERS_COUNT(
    p_order_type IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM TBL_ORD_ORDERS
    WHERE STATUS IN (C_STATUS_PENDING, C_STATUS_CONFIRMED, C_STATUS_PREPARING, C_STATUS_READY)
      AND (p_order_type IS NULL OR ORDER_TYPE = p_order_type);

    RETURN v_count;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END FNC_GET_ACTIVE_ORDERS_COUNT;

  /*============================================================================
   * Function: FNC_GET_ORDER_ITEMS
   *===========================================================================*/
  FUNCTION FNC_GET_ORDER_ITEMS(
    p_order_id IN NUMBER
  ) RETURN TYP_ORD_ITEMS_TAB IS
    v_items TYP_ORD_ITEMS_TAB := TYP_ORD_ITEMS_TAB();
  BEGIN
    -- Check if order exists
    IF NOT FNC_ORDER_EXISTS(p_order_id) THEN
      RAISE_APPLICATION_ERROR(
        C_ERR_ORDER_NOT_FOUND,
        'Order not found: ' || p_order_id
      );
    END IF;

    SELECT TYP_ORD_ITEM_REC(
      MENU_ITEM_ID,
      ITEM_NAME,
      QUANTITY,
      UNIT_PRICE,
      SPECIAL_INSTRUCTIONS
    )
    BULK COLLECT INTO v_items
    FROM TBL_ORD_ORDER_ITEMS
    WHERE ORDER_ID = p_order_id
    ORDER BY ITEM_ID;

    RETURN v_items;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END FNC_GET_ORDER_ITEMS;

END PKG_ORD_API;
/

SHOW ERRORS PACKAGE BODY PKG_ORD_API;
