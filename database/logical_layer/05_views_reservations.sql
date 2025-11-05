/*==============================================================================
 * File: 05_views_reservations.sql
 * Purpose: Create views for RESERVATIONS feature
 * Layer: Logical Layer
 * Feature: RESERVATIONS (RES)
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *============================================================================*/

PROMPT
PROMPT ========================================
PROMPT Creating RESERVATIONS Feature Views
PROMPT ========================================
PROMPT

-- ============================================================================
-- View: VW_RES_RESERVATIONS_SUMMARY
-- Purpose: Summary view of all reservations
-- ============================================================================

PROMPT Creating VW_RES_RESERVATIONS_SUMMARY...
CREATE OR REPLACE VIEW VW_RES_RESERVATIONS_SUMMARY AS
SELECT
  r.RESERVATION_ID,
  r.RESERVATION_NUMBER,
  r.CUSTOMER_NAME,
  r.CUSTOMER_PHONE,
  r.CUSTOMER_EMAIL,
  r.TABLE_ID,
  t.TABLE_NUMBER,
  t.CAPACITY AS TABLE_CAPACITY,
  r.PARTY_SIZE,
  r.RESERVATION_DATE,
  r.RESERVATION_TIME,
  r.DURATION_MINUTES,
  r.STATUS,
  r.SPECIAL_REQUESTS,
  r.OCCASION,
  r.CREATED_DATE,
  r.SEATED_TIME,
  r.COMPLETED_TIME
FROM TBL_RES_RESERVATIONS r
LEFT JOIN TBL_RES_TABLES t ON r.TABLE_ID = t.TABLE_ID;

COMMENT ON TABLE VW_RES_RESERVATIONS_SUMMARY IS 'Summary view of reservations with table details';

-- ============================================================================
-- View: VW_RES_UPCOMING_RESERVATIONS
-- Purpose: View of upcoming reservations
-- ============================================================================

PROMPT Creating VW_RES_UPCOMING_RESERVATIONS...
CREATE OR REPLACE VIEW VW_RES_UPCOMING_RESERVATIONS AS
SELECT
  r.RESERVATION_ID,
  r.RESERVATION_NUMBER,
  r.CUSTOMER_NAME,
  r.CUSTOMER_PHONE,
  t.TABLE_NUMBER,
  r.PARTY_SIZE,
  r.RESERVATION_DATE,
  r.RESERVATION_TIME,
  r.STATUS,
  r.SPECIAL_REQUESTS,
  r.OCCASION,
  ROUND((r.RESERVATION_DATE - TRUNC(SYSDATE)) * 24, 0) AS HOURS_UNTIL_RESERVATION
FROM TBL_RES_RESERVATIONS r
LEFT JOIN TBL_RES_TABLES t ON r.TABLE_ID = t.TABLE_ID
WHERE r.RESERVATION_DATE >= TRUNC(SYSDATE)
  AND r.STATUS IN ('PENDING', 'CONFIRMED')
ORDER BY r.RESERVATION_DATE, r.RESERVATION_TIME;

COMMENT ON TABLE VW_RES_UPCOMING_RESERVATIONS IS 'View of upcoming reservations';

-- ============================================================================
-- View: VW_RES_TODAYS_RESERVATIONS
-- Purpose: View of today's reservations
-- ============================================================================

PROMPT Creating VW_RES_TODAYS_RESERVATIONS...
CREATE OR REPLACE VIEW VW_RES_TODAYS_RESERVATIONS AS
SELECT
  r.RESERVATION_ID,
  r.RESERVATION_NUMBER,
  r.CUSTOMER_NAME,
  r.CUSTOMER_PHONE,
  t.TABLE_NUMBER,
  r.PARTY_SIZE,
  r.RESERVATION_TIME,
  r.STATUS,
  r.SPECIAL_REQUESTS,
  CASE
    WHEN r.STATUS = 'SEATED' THEN 'CURRENTLY DINING'
    WHEN r.STATUS = 'CONFIRMED' THEN 'AWAITING ARRIVAL'
    WHEN r.STATUS = 'PENDING' THEN 'PENDING CONFIRMATION'
    WHEN r.STATUS = 'COMPLETED' THEN 'COMPLETED'
    ELSE r.STATUS
  END AS DISPLAY_STATUS
FROM TBL_RES_RESERVATIONS r
LEFT JOIN TBL_RES_TABLES t ON r.TABLE_ID = t.TABLE_ID
WHERE TRUNC(r.RESERVATION_DATE) = TRUNC(SYSDATE)
ORDER BY r.RESERVATION_TIME;

COMMENT ON TABLE VW_RES_TODAYS_RESERVATIONS IS 'View of today''s reservations with friendly status';

-- ============================================================================
-- View: VW_RES_TABLE_AVAILABILITY
-- Purpose: Current table availability status
-- ============================================================================

PROMPT Creating VW_RES_TABLE_AVAILABILITY...
CREATE OR REPLACE VIEW VW_RES_TABLE_AVAILABILITY AS
SELECT
  t.TABLE_ID,
  t.TABLE_NUMBER,
  t.CAPACITY,
  t.LOCATION,
  t.STATUS AS TABLE_STATUS,
  r.RESERVATION_ID,
  r.RESERVATION_NUMBER,
  r.CUSTOMER_NAME,
  r.PARTY_SIZE,
  r.RESERVATION_TIME,
  r.STATUS AS RESERVATION_STATUS
FROM TBL_RES_TABLES t
LEFT JOIN TBL_RES_RESERVATIONS r
  ON t.TABLE_ID = r.TABLE_ID
  AND TRUNC(r.RESERVATION_DATE) = TRUNC(SYSDATE)
  AND r.STATUS IN ('CONFIRMED', 'SEATED')
ORDER BY t.TABLE_NUMBER;

COMMENT ON TABLE VW_RES_TABLE_AVAILABILITY IS 'Current table availability with active reservations';

-- ============================================================================
-- View: VW_RES_AVAILABLE_TABLES
-- Purpose: Currently available tables
-- ============================================================================

PROMPT Creating VW_RES_AVAILABLE_TABLES...
CREATE OR REPLACE VIEW VW_RES_AVAILABLE_TABLES AS
SELECT
  TABLE_ID,
  TABLE_NUMBER,
  CAPACITY,
  LOCATION,
  FEATURES
FROM TBL_RES_TABLES
WHERE STATUS = 'AVAILABLE'
ORDER BY TABLE_NUMBER;

COMMENT ON TABLE VW_RES_AVAILABLE_TABLES IS 'View of currently available tables';

-- ============================================================================
-- View: VW_RES_DAILY_STATS
-- Purpose: Daily reservation statistics
-- ============================================================================

PROMPT Creating VW_RES_DAILY_STATS...
CREATE OR REPLACE VIEW VW_RES_DAILY_STATS AS
SELECT
  TRUNC(r.RESERVATION_DATE) AS RESERVATION_DATE,
  r.STATUS,
  COUNT(*) AS RESERVATION_COUNT,
  SUM(r.PARTY_SIZE) AS TOTAL_GUESTS,
  AVG(r.PARTY_SIZE) AS AVG_PARTY_SIZE,
  MIN(r.PARTY_SIZE) AS MIN_PARTY_SIZE,
  MAX(r.PARTY_SIZE) AS MAX_PARTY_SIZE
FROM TBL_RES_RESERVATIONS r
GROUP BY TRUNC(r.RESERVATION_DATE), r.STATUS
ORDER BY RESERVATION_DATE DESC, r.STATUS;

COMMENT ON TABLE VW_RES_DAILY_STATS IS 'Daily reservation statistics grouped by status';

-- ============================================================================
-- View: VW_RES_NO_SHOWS
-- Purpose: Track no-show reservations
-- ============================================================================

PROMPT Creating VW_RES_NO_SHOWS...
CREATE OR REPLACE VIEW VW_RES_NO_SHOWS AS
SELECT
  r.RESERVATION_ID,
  r.RESERVATION_NUMBER,
  r.CUSTOMER_NAME,
  r.CUSTOMER_PHONE,
  r.CUSTOMER_EMAIL,
  t.TABLE_NUMBER,
  r.PARTY_SIZE,
  r.RESERVATION_DATE,
  r.RESERVATION_TIME,
  r.SPECIAL_REQUESTS,
  r.CREATED_DATE
FROM TBL_RES_RESERVATIONS r
LEFT JOIN TBL_RES_TABLES t ON r.TABLE_ID = t.TABLE_ID
WHERE r.STATUS = 'NO_SHOW'
ORDER BY r.RESERVATION_DATE DESC;

COMMENT ON TABLE VW_RES_NO_SHOWS IS 'Track no-show reservations for analysis';

-- ============================================================================
-- View: VW_RES_TABLE_UTILIZATION
-- Purpose: Table utilization statistics
-- ============================================================================

PROMPT Creating VW_RES_TABLE_UTILIZATION...
CREATE OR REPLACE VIEW VW_RES_TABLE_UTILIZATION AS
SELECT
  t.TABLE_ID,
  t.TABLE_NUMBER,
  t.CAPACITY,
  t.LOCATION,
  COUNT(r.RESERVATION_ID) AS TOTAL_RESERVATIONS,
  SUM(CASE WHEN r.STATUS = 'COMPLETED' THEN 1 ELSE 0 END) AS COMPLETED_RESERVATIONS,
  SUM(CASE WHEN r.STATUS = 'NO_SHOW' THEN 1 ELSE 0 END) AS NO_SHOWS,
  SUM(CASE WHEN r.STATUS = 'CANCELLED' THEN 1 ELSE 0 END) AS CANCELLATIONS,
  ROUND(AVG(r.PARTY_SIZE), 2) AS AVG_PARTY_SIZE,
  ROUND((SUM(CASE WHEN r.STATUS = 'COMPLETED' THEN 1 ELSE 0 END) /
         NULLIF(COUNT(r.RESERVATION_ID), 0)) * 100, 2) AS COMPLETION_RATE_PCT
FROM TBL_RES_TABLES t
LEFT JOIN TBL_RES_RESERVATIONS r ON t.TABLE_ID = r.TABLE_ID
GROUP BY t.TABLE_ID, t.TABLE_NUMBER, t.CAPACITY, t.LOCATION
ORDER BY TOTAL_RESERVATIONS DESC;

COMMENT ON TABLE VW_RES_TABLE_UTILIZATION IS 'Table utilization statistics and completion rates';

PROMPT RESERVATIONS views created successfully!
PROMPT
