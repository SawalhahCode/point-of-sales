/*==============================================================================
 * Package: PKG_RES_API - Reservations Feature API
 *============================================================================*/

-- Specification
CREATE OR REPLACE PACKAGE PKG_RES_API AS
  PROCEDURE PRC_CREATE_RESERVATION(
    p_customer_name IN VARCHAR2,
    p_customer_phone IN VARCHAR2,
    p_party_size IN NUMBER,
    p_reservation_date IN DATE,
    p_reservation_time IN VARCHAR2,
    p_reservation_id OUT NUMBER,
    p_reservation_number OUT VARCHAR2
  );

  PROCEDURE PRC_ASSIGN_TABLE(
    p_reservation_id IN NUMBER,
    p_table_id IN NUMBER
  );

  PROCEDURE PRC_UPDATE_RESERVATION_STATUS(
    p_reservation_id IN NUMBER,
    p_new_status IN VARCHAR2
  );

  PROCEDURE PRC_CREATE_TABLE(
    p_table_number IN NUMBER,
    p_capacity IN NUMBER,
    p_location IN VARCHAR2 DEFAULT NULL,
    p_table_id OUT NUMBER
  );

  FUNCTION FNC_CHECK_AVAILABILITY(
    p_date IN DATE,
    p_time IN VARCHAR2,
    p_party_size IN NUMBER
  ) RETURN TYP_RES_TABLES_TAB;
END PKG_RES_API;
/

-- Body
CREATE OR REPLACE PACKAGE BODY PKG_RES_API AS
  PROCEDURE PRC_CREATE_RESERVATION(
    p_customer_name IN VARCHAR2,
    p_customer_phone IN VARCHAR2,
    p_party_size IN NUMBER,
    p_reservation_date IN DATE,
    p_reservation_time IN VARCHAR2,
    p_reservation_id OUT NUMBER,
    p_reservation_number OUT VARCHAR2
  ) IS
  BEGIN
    INSERT INTO TBL_RES_RESERVATIONS(
      CUSTOMER_NAME, CUSTOMER_PHONE, PARTY_SIZE,
      RESERVATION_DATE, RESERVATION_TIME, STATUS
    ) VALUES (
      p_customer_name, p_customer_phone, p_party_size,
      p_reservation_date, p_reservation_time, 'PENDING'
    ) RETURNING RESERVATION_ID, RESERVATION_NUMBER
    INTO p_reservation_id, p_reservation_number;
    COMMIT;
  END;

  PROCEDURE PRC_ASSIGN_TABLE(
    p_reservation_id IN NUMBER,
    p_table_id IN NUMBER
  ) IS
  BEGIN
    UPDATE TBL_RES_RESERVATIONS
    SET TABLE_ID = p_table_id, STATUS = 'CONFIRMED'
    WHERE RESERVATION_ID = p_reservation_id;

    UPDATE TBL_RES_TABLES SET STATUS = 'RESERVED' WHERE TABLE_ID = p_table_id;
    COMMIT;
  END;

  PROCEDURE PRC_UPDATE_RESERVATION_STATUS(
    p_reservation_id IN NUMBER,
    p_new_status IN VARCHAR2
  ) IS
    v_table_id NUMBER;
  BEGIN
    SELECT TABLE_ID INTO v_table_id FROM TBL_RES_RESERVATIONS WHERE RESERVATION_ID = p_reservation_id;

    UPDATE TBL_RES_RESERVATIONS SET STATUS = p_new_status WHERE RESERVATION_ID = p_reservation_id;

    IF p_new_status = 'SEATED' AND v_table_id IS NOT NULL THEN
      UPDATE TBL_RES_TABLES SET STATUS = 'OCCUPIED' WHERE TABLE_ID = v_table_id;
    ELSIF p_new_status = 'COMPLETED' AND v_table_id IS NOT NULL THEN
      UPDATE TBL_RES_TABLES SET STATUS = 'CLEANING' WHERE TABLE_ID = v_table_id;
    END IF;
    COMMIT;
  END;

  PROCEDURE PRC_CREATE_TABLE(
    p_table_number IN NUMBER,
    p_capacity IN NUMBER,
    p_location IN VARCHAR2 DEFAULT NULL,
    p_table_id OUT NUMBER
  ) IS
  BEGIN
    INSERT INTO TBL_RES_TABLES(TABLE_NUMBER, CAPACITY, LOCATION, STATUS)
    VALUES (p_table_number, p_capacity, p_location, 'AVAILABLE')
    RETURNING TABLE_ID INTO p_table_id;
    COMMIT;
  END;

  FUNCTION FNC_CHECK_AVAILABILITY(
    p_date IN DATE,
    p_time IN VARCHAR2,
    p_party_size IN NUMBER
  ) RETURN TYP_RES_TABLES_TAB IS
    v_tables TYP_RES_TABLES_TAB;
  BEGIN
    SELECT TYP_RES_TABLE_REC(TABLE_ID, TABLE_NUMBER, CAPACITY, LOCATION, STATUS)
    BULK COLLECT INTO v_tables
    FROM TBL_RES_TABLES
    WHERE CAPACITY >= p_party_size
      AND STATUS = 'AVAILABLE'
      AND TABLE_ID NOT IN (
        SELECT TABLE_ID FROM TBL_RES_RESERVATIONS
        WHERE TRUNC(RESERVATION_DATE) = TRUNC(p_date)
          AND RESERVATION_TIME = p_time
          AND STATUS IN ('CONFIRMED', 'SEATED')
      );
    RETURN v_tables;
  END;
END PKG_RES_API;
/
