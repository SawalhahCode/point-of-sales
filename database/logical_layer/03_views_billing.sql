/*==============================================================================
 * File: 03_views_billing.sql
 * Purpose: Create views for BILLING feature
 * Layer: Logical Layer
 * Feature: BILLING (BIL)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating BILLING Feature Views
PROMPT ========================================
PROMPT

-- ============================================================================
-- View: VW_BIL_BILLS_SUMMARY
-- Purpose: Summary view of all bills with payment details
-- ============================================================================

PROMPT Creating VW_BIL_BILLS_SUMMARY...
CREATE OR REPLACE VIEW VW_BIL_BILLS_SUMMARY AS
SELECT
  b.BILL_ID,
  b.BILL_NUMBER,
  b.ORDER_ID,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  b.SUBTOTAL,
  b.TAX_AMOUNT,
  b.DISCOUNT_AMOUNT,
  b.TIP_AMOUNT,
  b.TOTAL_AMOUNT,
  b.AMOUNT_PAID,
  b.AMOUNT_DUE,
  b.PAYMENT_STATUS,
  COUNT(p.PAYMENT_ID) AS PAYMENT_COUNT,
  b.CREATED_DATE,
  b.PAID_DATE
FROM TBL_BIL_BILLS b
INNER JOIN TBL_ORD_ORDERS o ON b.ORDER_ID = o.ORDER_ID
LEFT JOIN TBL_BIL_PAYMENTS p ON b.BILL_ID = p.BILL_ID
GROUP BY
  b.BILL_ID,
  b.BILL_NUMBER,
  b.ORDER_ID,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  b.SUBTOTAL,
  b.TAX_AMOUNT,
  b.DISCOUNT_AMOUNT,
  b.TIP_AMOUNT,
  b.TOTAL_AMOUNT,
  b.AMOUNT_PAID,
  b.AMOUNT_DUE,
  b.PAYMENT_STATUS,
  b.CREATED_DATE,
  b.PAID_DATE;

COMMENT ON TABLE VW_BIL_BILLS_SUMMARY IS 'Summary view of bills with payment information';

-- ============================================================================
-- View: VW_BIL_PENDING_BILLS
-- Purpose: View of bills awaiting payment
-- ============================================================================

PROMPT Creating VW_BIL_PENDING_BILLS...
CREATE OR REPLACE VIEW VW_BIL_PENDING_BILLS AS
SELECT
  b.BILL_ID,
  b.BILL_NUMBER,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  o.CUSTOMER_PHONE,
  b.TOTAL_AMOUNT,
  b.AMOUNT_PAID,
  b.AMOUNT_DUE,
  b.PAYMENT_STATUS,
  b.CREATED_DATE,
  ROUND((SYSDATE - b.CREATED_DATE) * 24 * 60, 0) AS PENDING_MINUTES
FROM TBL_BIL_BILLS b
INNER JOIN TBL_ORD_ORDERS o ON b.ORDER_ID = o.ORDER_ID
WHERE b.PAYMENT_STATUS IN ('PENDING', 'PARTIALLY_PAID')
ORDER BY b.CREATED_DATE;

COMMENT ON TABLE VW_BIL_PENDING_BILLS IS 'View of bills awaiting payment';

-- ============================================================================
-- View: VW_BIL_PAYMENT_HISTORY
-- Purpose: Complete payment history with bill details
-- ============================================================================

PROMPT Creating VW_BIL_PAYMENT_HISTORY...
CREATE OR REPLACE VIEW VW_BIL_PAYMENT_HISTORY AS
SELECT
  p.PAYMENT_ID,
  b.BILL_NUMBER,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  p.PAYMENT_AMOUNT,
  p.PAYMENT_METHOD,
  p.TRANSACTION_ID,
  p.PAYMENT_DATE,
  p.PROCESSED_BY
FROM TBL_BIL_PAYMENTS p
INNER JOIN TBL_BIL_BILLS b ON p.BILL_ID = b.BILL_ID
INNER JOIN TBL_ORD_ORDERS o ON b.ORDER_ID = o.ORDER_ID
ORDER BY p.PAYMENT_DATE DESC;

COMMENT ON TABLE VW_BIL_PAYMENT_HISTORY IS 'Complete payment history with bill and order details';

-- ============================================================================
-- View: VW_BIL_DAILY_REVENUE
-- Purpose: Daily revenue summary
-- ============================================================================

PROMPT Creating VW_BIL_DAILY_REVENUE...
CREATE OR REPLACE VIEW VW_BIL_DAILY_REVENUE AS
SELECT
  TRUNC(b.CREATED_DATE) AS REVENUE_DATE,
  COUNT(DISTINCT b.BILL_ID) AS TOTAL_BILLS,
  SUM(b.SUBTOTAL) AS GROSS_REVENUE,
  SUM(b.TAX_AMOUNT) AS TOTAL_TAX,
  SUM(b.DISCOUNT_AMOUNT) AS TOTAL_DISCOUNTS,
  SUM(b.TIP_AMOUNT) AS TOTAL_TIPS,
  SUM(b.TOTAL_AMOUNT) AS NET_REVENUE,
  SUM(CASE WHEN b.PAYMENT_STATUS = 'PAID' THEN b.TOTAL_AMOUNT ELSE 0 END) AS COLLECTED_REVENUE,
  SUM(CASE WHEN b.PAYMENT_STATUS IN ('PENDING', 'PARTIALLY_PAID') THEN b.AMOUNT_DUE ELSE 0 END) AS OUTSTANDING_AMOUNT
FROM TBL_BIL_BILLS b
GROUP BY TRUNC(b.CREATED_DATE)
ORDER BY REVENUE_DATE DESC;

COMMENT ON TABLE VW_BIL_DAILY_REVENUE IS 'Daily revenue summary with breakdowns';

-- ============================================================================
-- View: VW_BIL_PAYMENT_METHOD_STATS
-- Purpose: Statistics by payment method
-- ============================================================================

PROMPT Creating VW_BIL_PAYMENT_METHOD_STATS...
CREATE OR REPLACE VIEW VW_BIL_PAYMENT_METHOD_STATS AS
SELECT
  p.PAYMENT_METHOD,
  COUNT(*) AS TRANSACTION_COUNT,
  SUM(p.PAYMENT_AMOUNT) AS TOTAL_AMOUNT,
  AVG(p.PAYMENT_AMOUNT) AS AVG_AMOUNT,
  MIN(p.PAYMENT_AMOUNT) AS MIN_AMOUNT,
  MAX(p.PAYMENT_AMOUNT) AS MAX_AMOUNT,
  TRUNC(MIN(p.PAYMENT_DATE)) AS FIRST_USED,
  TRUNC(MAX(p.PAYMENT_DATE)) AS LAST_USED
FROM TBL_BIL_PAYMENTS p
GROUP BY p.PAYMENT_METHOD
ORDER BY TOTAL_AMOUNT DESC;

COMMENT ON TABLE VW_BIL_PAYMENT_METHOD_STATS IS 'Statistics grouped by payment method';

PROMPT BILLING views created successfully!
PROMPT
