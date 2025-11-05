/*==============================================================================
 * File: 04_views_delivery.sql
 * Purpose: Create views for DELIVERY feature
 * Layer: Logical Layer
 * Feature: DELIVERY (DEL)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating DELIVERY Feature Views
PROMPT ========================================
PROMPT

-- ============================================================================
-- View: VW_DEL_DELIVERIES_SUMMARY
-- Purpose: Summary view of all deliveries
-- ============================================================================

PROMPT Creating VW_DEL_DELIVERIES_SUMMARY...
CREATE OR REPLACE VIEW VW_DEL_DELIVERIES_SUMMARY AS
SELECT
  d.DELIVERY_ID,
  d.DELIVERY_NUMBER,
  d.ORDER_ID,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  o.CUSTOMER_PHONE,
  d.DRIVER_ID,
  dr.DRIVER_NAME,
  dr.PHONE_NUMBER AS DRIVER_PHONE,
  d.DELIVERY_ADDRESS,
  d.DISTANCE_KM,
  d.DELIVERY_FEE,
  d.STATUS,
  d.EST_DELIVERY_TIME,
  d.ACTUAL_DELIVERY_TIME,
  d.CREATED_DATE,
  CASE
    WHEN d.STATUS = 'DELIVERED' AND d.ACTUAL_DELIVERY_TIME IS NOT NULL THEN
      ROUND((d.ACTUAL_DELIVERY_TIME - d.CREATED_DATE) * 24 * 60, 0)
    ELSE
      ROUND((SYSDATE - d.CREATED_DATE) * 24 * 60, 0)
  END AS ELAPSED_TIME_MINUTES
FROM TBL_DEL_DELIVERIES d
INNER JOIN TBL_ORD_ORDERS o ON d.ORDER_ID = o.ORDER_ID
LEFT JOIN TBL_DEL_DRIVERS dr ON d.DRIVER_ID = dr.DRIVER_ID;

COMMENT ON TABLE VW_DEL_DELIVERIES_SUMMARY IS 'Summary view of deliveries with order and driver details';

-- ============================================================================
-- View: VW_DEL_ACTIVE_DELIVERIES
-- Purpose: View of deliveries in progress
-- ============================================================================

PROMPT Creating VW_DEL_ACTIVE_DELIVERIES...
CREATE OR REPLACE VIEW VW_DEL_ACTIVE_DELIVERIES AS
SELECT
  d.DELIVERY_ID,
  d.DELIVERY_NUMBER,
  o.ORDER_NUMBER,
  o.CUSTOMER_NAME,
  o.CUSTOMER_PHONE,
  dr.DRIVER_NAME,
  dr.PHONE_NUMBER AS DRIVER_PHONE,
  dr.CURRENT_LAT AS DRIVER_LAT,
  dr.CURRENT_LONG AS DRIVER_LONG,
  d.DELIVERY_ADDRESS,
  d.DELIVERY_LAT,
  d.DELIVERY_LONG,
  d.STATUS,
  d.EST_DELIVERY_TIME,
  ROUND((SYSDATE - d.CREATED_DATE) * 24 * 60, 0) AS IN_PROGRESS_MINUTES
FROM TBL_DEL_DELIVERIES d
INNER JOIN TBL_ORD_ORDERS o ON d.ORDER_ID = o.ORDER_ID
LEFT JOIN TBL_DEL_DRIVERS dr ON d.DRIVER_ID = dr.DRIVER_ID
WHERE d.STATUS IN ('ASSIGNED', 'PICKED_UP', 'IN_TRANSIT')
ORDER BY d.CREATED_DATE;

COMMENT ON TABLE VW_DEL_ACTIVE_DELIVERIES IS 'View of deliveries currently in progress';

-- ============================================================================
-- View: VW_DEL_AVAILABLE_DRIVERS
-- Purpose: View of available drivers
-- ============================================================================

PROMPT Creating VW_DEL_AVAILABLE_DRIVERS...
CREATE OR REPLACE VIEW VW_DEL_AVAILABLE_DRIVERS AS
SELECT
  dr.DRIVER_ID,
  dr.DRIVER_NAME,
  dr.PHONE_NUMBER,
  dr.VEHICLE_TYPE,
  dr.VEHICLE_NUMBER,
  dr.CURRENT_LAT,
  dr.CURRENT_LONG,
  COUNT(d.DELIVERY_ID) AS COMPLETED_DELIVERIES_TODAY
FROM TBL_DEL_DRIVERS dr
LEFT JOIN TBL_DEL_DELIVERIES d
  ON dr.DRIVER_ID = d.DRIVER_ID
  AND TRUNC(d.CREATED_DATE) = TRUNC(SYSDATE)
  AND d.STATUS = 'DELIVERED'
WHERE dr.IS_AVAILABLE = 'Y'
GROUP BY
  dr.DRIVER_ID,
  dr.DRIVER_NAME,
  dr.PHONE_NUMBER,
  dr.VEHICLE_TYPE,
  dr.VEHICLE_NUMBER,
  dr.CURRENT_LAT,
  dr.CURRENT_LONG
ORDER BY COMPLETED_DELIVERIES_TODAY;

COMMENT ON TABLE VW_DEL_AVAILABLE_DRIVERS IS 'View of available drivers with today completed deliveries';

-- ============================================================================
-- View: VW_DEL_DRIVER_PERFORMANCE
-- Purpose: Driver performance statistics
-- ============================================================================

PROMPT Creating VW_DEL_DRIVER_PERFORMANCE...
CREATE OR REPLACE VIEW VW_DEL_DRIVER_PERFORMANCE AS
SELECT
  dr.DRIVER_ID,
  dr.DRIVER_NAME,
  COUNT(*) AS TOTAL_DELIVERIES,
  SUM(CASE WHEN d.STATUS = 'DELIVERED' THEN 1 ELSE 0 END) AS COMPLETED_DELIVERIES,
  SUM(CASE WHEN d.STATUS = 'CANCELLED' THEN 1 ELSE 0 END) AS CANCELLED_DELIVERIES,
  ROUND(AVG(CASE
    WHEN d.STATUS = 'DELIVERED' AND d.ACTUAL_DELIVERY_TIME IS NOT NULL
    THEN (d.ACTUAL_DELIVERY_TIME - d.CREATED_DATE) * 24 * 60
  END), 2) AS AVG_DELIVERY_TIME_MINUTES,
  SUM(d.DISTANCE_KM) AS TOTAL_DISTANCE_KM,
  SUM(d.DELIVERY_FEE) AS TOTAL_DELIVERY_FEES,
  MIN(d.CREATED_DATE) AS FIRST_DELIVERY_DATE,
  MAX(d.CREATED_DATE) AS LAST_DELIVERY_DATE
FROM TBL_DEL_DRIVERS dr
LEFT JOIN TBL_DEL_DELIVERIES d ON dr.DRIVER_ID = d.DRIVER_ID
GROUP BY dr.DRIVER_ID, dr.DRIVER_NAME
ORDER BY COMPLETED_DELIVERIES DESC;

COMMENT ON TABLE VW_DEL_DRIVER_PERFORMANCE IS 'Driver performance statistics';

-- ============================================================================
-- View: VW_DEL_DAILY_STATS
-- Purpose: Daily delivery statistics
-- ============================================================================

PROMPT Creating VW_DEL_DAILY_STATS...
CREATE OR REPLACE VIEW VW_DEL_DAILY_STATS AS
SELECT
  TRUNC(d.CREATED_DATE) AS DELIVERY_DATE,
  d.STATUS,
  COUNT(*) AS DELIVERY_COUNT,
  SUM(d.DISTANCE_KM) AS TOTAL_DISTANCE,
  AVG(d.DISTANCE_KM) AS AVG_DISTANCE,
  SUM(d.DELIVERY_FEE) AS TOTAL_FEES,
  AVG(d.DELIVERY_FEE) AS AVG_FEE,
  ROUND(AVG(CASE
    WHEN d.STATUS = 'DELIVERED' AND d.ACTUAL_DELIVERY_TIME IS NOT NULL
    THEN (d.ACTUAL_DELIVERY_TIME - d.CREATED_DATE) * 24 * 60
  END), 2) AS AVG_DELIVERY_TIME_MINUTES
FROM TBL_DEL_DELIVERIES d
GROUP BY TRUNC(d.CREATED_DATE), d.STATUS
ORDER BY DELIVERY_DATE DESC, d.STATUS;

COMMENT ON TABLE VW_DEL_DAILY_STATS IS 'Daily delivery statistics grouped by status';

PROMPT DELIVERY views created successfully!
PROMPT
