/*==============================================================================
 * File: 02_views_ordering.sql
 * Purpose: Create views for ORDERING feature
 * Layer: Logical Layer
 * Feature: ORDERING (ORD)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating ORDERING Feature Views
PROMPT ========================================
PROMPT

-- ============================================================================
-- View: VW_ORD_ORDERS_SUMMARY
-- Purpose: Summary view of all orders with calculated totals
-- ============================================================================

PROMPT Creating VW_ORD_ORDERS_SUMMARY...
CREATE OR REPLACE VIEW VW_ORD_ORDERS_SUMMARY AS
SELECT
  o.ORDER_ID,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  o.CUSTOMER_PHONE,
  o.CUSTOMER_EMAIL,
  o.ORDER_TYPE,
  o.TABLE_NUMBER,
  COUNT(oi.ITEM_ID) AS TOTAL_ITEMS,
  o.SUBTOTAL,
  o.TAX_AMOUNT,
  o.TOTAL_AMOUNT,
  o.STATUS,
  o.CREATED_DATE,
  o.COMPLETED_DATE,
  CASE
    WHEN o.STATUS = 'COMPLETED' THEN
      ROUND((o.COMPLETED_DATE - o.CREATED_DATE) * 24 * 60, 0) -- Minutes
    ELSE
      ROUND((SYSDATE - o.CREATED_DATE) * 24 * 60, 0)
  END AS PROCESSING_TIME_MINUTES
FROM TBL_ORD_ORDERS o
LEFT JOIN TBL_ORD_ORDER_ITEMS oi ON o.ORDER_ID = oi.ORDER_ID
GROUP BY
  o.ORDER_ID,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  o.CUSTOMER_PHONE,
  o.CUSTOMER_EMAIL,
  o.ORDER_TYPE,
  o.TABLE_NUMBER,
  o.SUBTOTAL,
  o.TAX_AMOUNT,
  o.TOTAL_AMOUNT,
  o.STATUS,
  o.CREATED_DATE,
  o.COMPLETED_DATE;

COMMENT ON TABLE VW_ORD_ORDERS_SUMMARY IS 'Summary view of orders with item counts and processing time';

-- ============================================================================
-- View: VW_ORD_ACTIVE_ORDERS
-- Purpose: View of active orders (not completed or cancelled)
-- ============================================================================

PROMPT Creating VW_ORD_ACTIVE_ORDERS...
CREATE OR REPLACE VIEW VW_ORD_ACTIVE_ORDERS AS
SELECT
  ORDER_ID,
  ORDER_NUMBER,
  CUSTOMER_NAME,
  CUSTOMER_PHONE,
  ORDER_TYPE,
  TABLE_NUMBER,
  TOTAL_AMOUNT,
  STATUS,
  CREATED_DATE,
  ROUND((SYSDATE - CREATED_DATE) * 24 * 60, 0) AS WAITING_TIME_MINUTES
FROM TBL_ORD_ORDERS
WHERE STATUS IN ('PENDING', 'CONFIRMED', 'PREPARING', 'READY')
ORDER BY CREATED_DATE;

COMMENT ON TABLE VW_ORD_ACTIVE_ORDERS IS 'View of active orders that are not completed or cancelled';

-- ============================================================================
-- View: VW_ORD_ORDER_DETAILS
-- Purpose: Detailed view of orders with all items
-- ============================================================================

PROMPT Creating VW_ORD_ORDER_DETAILS...
CREATE OR REPLACE VIEW VW_ORD_ORDER_DETAILS AS
SELECT
  o.ORDER_ID,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  o.CUSTOMER_PHONE,
  o.ORDER_TYPE,
  o.STATUS AS ORDER_STATUS,
  oi.ITEM_ID,
  oi.MENU_ITEM_ID,
  oi.ITEM_NAME,
  oi.QUANTITY,
  oi.UNIT_PRICE,
  oi.SUBTOTAL,
  oi.SPECIAL_INSTRUCTIONS,
  o.CREATED_DATE AS ORDER_DATE
FROM TBL_ORD_ORDERS o
INNER JOIN TBL_ORD_ORDER_ITEMS oi ON o.ORDER_ID = oi.ORDER_ID
ORDER BY o.ORDER_ID, oi.ITEM_ID;

COMMENT ON TABLE VW_ORD_ORDER_DETAILS IS 'Detailed view of orders with all line items';

-- ============================================================================
-- View: VW_ORD_DAILY_STATS
-- Purpose: Daily statistics for orders
-- ============================================================================

PROMPT Creating VW_ORD_DAILY_STATS...
CREATE OR REPLACE VIEW VW_ORD_DAILY_STATS AS
SELECT
  TRUNC(CREATED_DATE) AS ORDER_DATE,
  ORDER_TYPE,
  STATUS,
  COUNT(*) AS ORDER_COUNT,
  SUM(TOTAL_AMOUNT) AS TOTAL_REVENUE,
  AVG(TOTAL_AMOUNT) AS AVG_ORDER_VALUE,
  MIN(TOTAL_AMOUNT) AS MIN_ORDER_VALUE,
  MAX(TOTAL_AMOUNT) AS MAX_ORDER_VALUE
FROM TBL_ORD_ORDERS
GROUP BY TRUNC(CREATED_DATE), ORDER_TYPE, STATUS
ORDER BY ORDER_DATE DESC, ORDER_TYPE;

COMMENT ON TABLE VW_ORD_DAILY_STATS IS 'Daily statistics for orders grouped by type and status';

-- ============================================================================
-- View: VW_ORD_POPULAR_ITEMS
-- Purpose: Most popular menu items
-- ============================================================================

PROMPT Creating VW_ORD_POPULAR_ITEMS...
CREATE OR REPLACE VIEW VW_ORD_POPULAR_ITEMS AS
SELECT
  oi.MENU_ITEM_ID,
  oi.ITEM_NAME,
  COUNT(*) AS ORDER_COUNT,
  SUM(oi.QUANTITY) AS TOTAL_QUANTITY,
  SUM(oi.SUBTOTAL) AS TOTAL_REVENUE,
  AVG(oi.UNIT_PRICE) AS AVG_PRICE
FROM TBL_ORD_ORDER_ITEMS oi
INNER JOIN TBL_ORD_ORDERS o ON oi.ORDER_ID = o.ORDER_ID
WHERE o.STATUS != 'CANCELLED'
GROUP BY oi.MENU_ITEM_ID, oi.ITEM_NAME
ORDER BY TOTAL_QUANTITY DESC;

COMMENT ON TABLE VW_ORD_POPULAR_ITEMS IS 'Popular menu items by quantity ordered';

PROMPT ORDERING views created successfully!
PROMPT
