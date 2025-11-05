/*==============================================================================
 * Package: PKG_ORD_API
 * Purpose: API for ORDERING feature - Public interface
 * Layer: Application Layer
 * Feature: ORDERING (ORD)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *
 * Description:
 *   This package provides the main API for managing customer orders including
 *   creating orders, updating status, cancelling orders, and retrieving order
 *   information.
 *
 * Public Procedures:
 *   - PRC_CREATE_ORDER: Create a new order
 *   - PRC_UPDATE_ORDER_STATUS: Update order status
 *   - PRC_CANCEL_ORDER: Cancel an order
 *   - PRC_ADD_ORDER_ITEM: Add item to existing order
 *
 * Public Functions:
 *   - FNC_GET_ORDER_TOTAL: Calculate order total
 *   - FNC_GET_ORDER_STATUS: Get current order status
 *   - FNC_GET_ACTIVE_ORDERS_COUNT: Count of active orders
 *
 *============================================================================*/

CREATE OR REPLACE PACKAGE PKG_ORD_API AS

  -- ========================================================================
  -- Constants
  -- ========================================================================

  -- Tax rate (8%)
  C_TAX_RATE CONSTANT NUMBER := 0.08;

  -- Order types
  C_ORDER_TYPE_DINE_IN   CONSTANT VARCHAR2(20) := 'DINE_IN';
  C_ORDER_TYPE_TAKEOUT   CONSTANT VARCHAR2(20) := 'TAKEOUT';
  C_ORDER_TYPE_DELIVERY  CONSTANT VARCHAR2(20) := 'DELIVERY';

  -- Order statuses
  C_STATUS_PENDING    CONSTANT VARCHAR2(20) := 'PENDING';
  C_STATUS_CONFIRMED  CONSTANT VARCHAR2(20) := 'CONFIRMED';
  C_STATUS_PREPARING  CONSTANT VARCHAR2(20) := 'PREPARING';
  C_STATUS_READY      CONSTANT VARCHAR2(20) := 'READY';
  C_STATUS_COMPLETED  CONSTANT VARCHAR2(20) := 'COMPLETED';
  C_STATUS_CANCELLED  CONSTANT VARCHAR2(20) := 'CANCELLED';

  -- Error codes
  C_ERR_ORDER_NOT_FOUND      CONSTANT NUMBER := -20301;
  C_ERR_ORDER_CANCELLED      CONSTANT NUMBER := -20302;
  C_ERR_INVALID_STATUS       CONSTANT NUMBER := -20303;
  C_ERR_NO_ITEMS             CONSTANT NUMBER := -20304;
  C_ERR_INVALID_ORDER_TYPE   CONSTANT NUMBER := -20305;

  -- ========================================================================
  -- Public Procedures
  -- ========================================================================

  /*============================================================================
   * Procedure: PRC_CREATE_ORDER
   * Purpose: Create a new customer order
   *
   * Parameters:
   *   p_customer_name     - Customer full name (required)
   *   p_customer_phone    - Customer phone number (required)
   *   p_customer_email    - Customer email address (optional)
   *   p_customer_address  - Customer address (optional)
   *   p_order_type        - Type: DINE_IN, TAKEOUT, or DELIVERY (required)
   *   p_table_number      - Table number (for dine-in)
   *   p_items             - Collection of order items (required)
   *   p_special_instructions - Special instructions (optional)
   *   p_order_id          - Output: Generated order ID
   *   p_order_number      - Output: Generated order number
   *   p_total_amount      - Output: Calculated total amount
   *
   * Example:
   *   DECLARE
   *     v_items TYP_ORD_ITEMS_TAB;
   *     v_order_id NUMBER;
   *     v_order_number VARCHAR2(50);
   *     v_total NUMBER;
   *   BEGIN
   *     v_items := TYP_ORD_ITEMS_TAB(
   *       TYP_ORD_ITEM_REC('BURGER-001', 'Classic Burger', 2, 12.99, NULL),
   *       TYP_ORD_ITEM_REC('FRIES-001', 'French Fries', 1, 4.99, 'Extra crispy')
   *     );
   *
   *     PKG_ORD_API.PRC_CREATE_ORDER(
   *       p_customer_name => 'John Doe',
   *       p_customer_phone => '555-1234',
   *       p_customer_email => 'john@example.com',
   *       p_order_type => 'DINE_IN',
   *       p_table_number => 5,
   *       p_items => v_items,
   *       p_order_id => v_order_id,
   *       p_order_number => v_order_number,
   *       p_total_amount => v_total
   *     );
   *   END;
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
  );

  /*============================================================================
   * Procedure: PRC_UPDATE_ORDER_STATUS
   * Purpose: Update the status of an existing order
   *
   * Parameters:
   *   p_order_id    - Order ID (required)
   *   p_new_status  - New status value (required)
   *   p_notes       - Optional notes about status change
   *
   * Valid status transitions:
   *   PENDING -> CONFIRMED -> PREPARING -> READY -> COMPLETED
   *   Any status -> CANCELLED
   *===========================================================================*/
  PROCEDURE PRC_UPDATE_ORDER_STATUS(
    p_order_id   IN NUMBER,
    p_new_status IN VARCHAR2,
    p_notes      IN VARCHAR2 DEFAULT NULL
  );

  /*============================================================================
   * Procedure: PRC_CANCEL_ORDER
   * Purpose: Cancel an order
   *
   * Parameters:
   *   p_order_id          - Order ID (required)
   *   p_cancellation_reason - Reason for cancellation (optional)
   *===========================================================================*/
  PROCEDURE PRC_CANCEL_ORDER(
    p_order_id             IN NUMBER,
    p_cancellation_reason  IN VARCHAR2 DEFAULT NULL
  );

  /*============================================================================
   * Procedure: PRC_ADD_ORDER_ITEM
   * Purpose: Add a new item to an existing order
   *
   * Parameters:
   *   p_order_id              - Order ID (required)
   *   p_menu_item_id          - Menu item ID (required)
   *   p_item_name             - Item name (required)
   *   p_quantity              - Quantity (required)
   *   p_unit_price            - Unit price (required)
   *   p_special_instructions  - Special instructions (optional)
   *===========================================================================*/
  PROCEDURE PRC_ADD_ORDER_ITEM(
    p_order_id             IN NUMBER,
    p_menu_item_id         IN VARCHAR2,
    p_item_name            IN VARCHAR2,
    p_quantity             IN NUMBER,
    p_unit_price           IN NUMBER,
    p_special_instructions IN VARCHAR2 DEFAULT NULL
  );

  -- ========================================================================
  -- Public Functions
  -- ========================================================================

  /*============================================================================
   * Function: FNC_GET_ORDER_TOTAL
   * Purpose: Calculate total amount for an order
   *
   * Parameters:
   *   p_order_id - Order ID
   *
   * Returns: Total amount (NUMBER)
   *===========================================================================*/
  FUNCTION FNC_GET_ORDER_TOTAL(
    p_order_id IN NUMBER
  ) RETURN NUMBER;

  /*============================================================================
   * Function: FNC_GET_ORDER_STATUS
   * Purpose: Get current status of an order
   *
   * Parameters:
   *   p_order_id - Order ID
   *
   * Returns: Order status (VARCHAR2)
   *===========================================================================*/
  FUNCTION FNC_GET_ORDER_STATUS(
    p_order_id IN NUMBER
  ) RETURN VARCHAR2;

  /*============================================================================
   * Function: FNC_GET_ACTIVE_ORDERS_COUNT
   * Purpose: Get count of active orders (not completed or cancelled)
   *
   * Parameters:
   *   p_order_type - Optional: filter by order type
   *
   * Returns: Count of active orders (NUMBER)
   *===========================================================================*/
  FUNCTION FNC_GET_ACTIVE_ORDERS_COUNT(
    p_order_type IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  /*============================================================================
   * Function: FNC_GET_ORDER_ITEMS
   * Purpose: Get all items for an order
   *
   * Parameters:
   *   p_order_id - Order ID
   *
   * Returns: Collection of order items
   *===========================================================================*/
  FUNCTION FNC_GET_ORDER_ITEMS(
    p_order_id IN NUMBER
  ) RETURN TYP_ORD_ITEMS_TAB;

END PKG_ORD_API;
/

SHOW ERRORS PACKAGE PKG_ORD_API;
