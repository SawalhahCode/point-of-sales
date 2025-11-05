/*==============================================================================
 * File: INSTALL_ALL.sql
 * Purpose: Master installation script for Restaurant POS System
 * Author: Restaurant POS System
 * Date: 2025-11-05
 *
 * Description:
 *   This script installs all database objects in the correct order:
 *   1. Physical Layer (Sequences, Tables, Indexes, Triggers)
 *   2. Logical Layer (Types, Views)
 *   3. Application Layer (Packages)
 *
 * Usage:
 *   SQL> @INSTALL_ALL.sql
 *
 * Prerequisites:
 *   - Oracle Database 12c or higher
 *   - User must have CREATE TABLE, CREATE SEQUENCE, CREATE VIEW,
 *     CREATE TYPE, CREATE PROCEDURE privileges
 *   - Sufficient tablespace quota
 *
 * Post-Installation:
 *   - Run TEST_INSTALL.sql to verify installation
 *   - Run SAMPLE_DATA.sql to load sample data (optional)
 *
 *============================================================================*/

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
SET TIMING ON

WHENEVER SQLERROR CONTINUE

PROMPT
PROMPT ========================================================================
PROMPT Restaurant POS System - Oracle Database Installation
PROMPT ========================================================================
PROMPT
PROMPT Installation started at:
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM DUAL;
PROMPT
PROMPT Current User:
SELECT USER FROM DUAL;
PROMPT
PROMPT ========================================================================
PROMPT

PAUSE Press ENTER to continue with installation (or CTRL+C to abort)...

-- ============================================================================
-- SECTION 1: PHYSICAL LAYER
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT SECTION 1: Installing Physical Layer
PROMPT ========================================================================
PROMPT

PROMPT Step 1.1: Creating Sequences...
@@database/physical_layer/01_sequences.sql

PROMPT Step 1.2: Creating ORDERING tables...
@@database/physical_layer/02_tables_ordering.sql

PROMPT Step 1.3: Creating BILLING tables...
@@database/physical_layer/03_tables_billing.sql

PROMPT Step 1.4: Creating DELIVERY tables...
@@database/physical_layer/04_tables_delivery.sql

PROMPT Step 1.5: Creating RESERVATIONS tables...
@@database/physical_layer/05_tables_reservations.sql

PROMPT Step 1.6: Creating Indexes...
@@database/physical_layer/06_indexes.sql

PROMPT Step 1.7: Creating Triggers...
@@database/physical_layer/07_triggers.sql

PROMPT
PROMPT Physical Layer installation completed!
PROMPT

-- ============================================================================
-- SECTION 2: LOGICAL LAYER
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT SECTION 2: Installing Logical Layer
PROMPT ========================================================================
PROMPT

PROMPT Step 2.1: Creating Object Types and Collections...
@@database/logical_layer/01_types.sql

PROMPT Step 2.2: Creating ORDERING views...
@@database/logical_layer/02_views_ordering.sql

PROMPT Step 2.3: Creating BILLING views...
@@database/logical_layer/03_views_billing.sql

PROMPT Step 2.4: Creating DELIVERY views...
@@database/logical_layer/04_views_delivery.sql

PROMPT Step 2.5: Creating RESERVATIONS views...
@@database/logical_layer/05_views_reservations.sql

PROMPT
PROMPT Logical Layer installation completed!
PROMPT

-- ============================================================================
-- SECTION 3: APPLICATION LAYER
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT SECTION 3: Installing Application Layer
PROMPT ========================================================================
PROMPT

PROMPT Step 3.1: Creating ORDERING API package specification...
@@database/application_layer/01_pkg_ord_api.pks

PROMPT Step 3.2: Creating ORDERING API package body...
@@database/application_layer/02_pkg_ord_api.pkb

PROMPT Step 3.3: Creating BILLING API package...
@@database/application_layer/03_pkg_bil_api.pks
@@database/application_layer/04_pkg_bil_api.pkb

PROMPT Step 3.5: Creating DELIVERY API package...
@@database/application_layer/05_pkg_del_api.sql

PROMPT Step 3.6: Creating RESERVATIONS API package...
@@database/application_layer/06_pkg_res_api.sql

PROMPT
PROMPT Application Layer installation completed!
PROMPT

-- ============================================================================
-- INSTALLATION VERIFICATION
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT Installation Verification
PROMPT ========================================================================
PROMPT

PROMPT Checking for invalid objects...
SELECT object_type, object_name, status
FROM user_objects
WHERE status != 'VALID'
ORDER BY object_type, object_name;

PROMPT
PROMPT Object count by type:
SELECT object_type, COUNT(*) as count
FROM user_objects
GROUP BY object_type
ORDER BY object_type;

PROMPT
PROMPT Installation Summary:
SELECT 'Total Objects' as metric, COUNT(*) as value FROM user_objects
UNION ALL
SELECT 'Valid Objects', COUNT(*) FROM user_objects WHERE status = 'VALID'
UNION ALL
SELECT 'Invalid Objects', COUNT(*) FROM user_objects WHERE status != 'VALID'
UNION ALL
SELECT 'Tables', COUNT(*) FROM user_tables
UNION ALL
SELECT 'Views', COUNT(*) FROM user_views
UNION ALL
SELECT 'Sequences', COUNT(*) FROM user_sequences
UNION ALL
SELECT 'Indexes', COUNT(*) FROM user_indexes WHERE index_name NOT LIKE 'SYS%'
UNION ALL
SELECT 'Triggers', COUNT(*) FROM user_triggers
UNION ALL
SELECT 'Packages', COUNT(*) FROM user_objects WHERE object_type = 'PACKAGE'
UNION ALL
SELECT 'Types', COUNT(*) FROM user_types;

PROMPT
PROMPT ========================================================================
PROMPT Installation Completed!
PROMPT ========================================================================
PROMPT
PROMPT Installation finished at:
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM DUAL;
PROMPT
PROMPT Next Steps:
PROMPT   1. Review any invalid objects above
PROMPT   2. Run TEST_INSTALL.sql to test the installation
PROMPT   3. Optionally run SAMPLE_DATA.sql to load test data
PROMPT   4. Grant EXECUTE privileges on packages to application users
PROMPT
PROMPT ========================================================================
PROMPT
