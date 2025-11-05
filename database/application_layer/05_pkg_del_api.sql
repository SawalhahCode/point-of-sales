/*==============================================================================
 * Package: PKG_DEL_API - Delivery Feature API
 *============================================================================*/

-- Specification
CREATE OR REPLACE PACKAGE PKG_DEL_API AS
  PROCEDURE PRC_CREATE_DELIVERY(
    p_order_id IN NUMBER,
    p_delivery_address IN VARCHAR2,
    p_delivery_lat IN NUMBER DEFAULT NULL,
    p_delivery_long IN NUMBER DEFAULT NULL,
    p_delivery_id OUT NUMBER,
    p_delivery_number OUT VARCHAR2
  );

  PROCEDURE PRC_ASSIGN_DRIVER(
    p_delivery_id IN NUMBER,
    p_driver_id IN NUMBER
  );

  PROCEDURE PRC_UPDATE_DELIVERY_STATUS(
    p_delivery_id IN NUMBER,
    p_new_status IN VARCHAR2,
    p_location_lat IN NUMBER DEFAULT NULL,
    p_location_long IN NUMBER DEFAULT NULL
  );

  PROCEDURE PRC_CREATE_DRIVER(
    p_driver_name IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_vehicle_type IN VARCHAR2,
    p_vehicle_number IN VARCHAR2,
    p_driver_id OUT NUMBER
  );

  FUNCTION FNC_GET_AVAILABLE_DRIVERS RETURN TYP_DEL_DRIVERS_TAB;
END PKG_DEL_API;
/

-- Body
CREATE OR REPLACE PACKAGE BODY PKG_DEL_API AS
  C_BASE_FEE CONSTANT NUMBER := 5.00;
  C_PER_KM_RATE CONSTANT NUMBER := 1.50;

  PROCEDURE PRC_CREATE_DELIVERY(
    p_order_id IN NUMBER,
    p_delivery_address IN VARCHAR2,
    p_delivery_lat IN NUMBER DEFAULT NULL,
    p_delivery_long IN NUMBER DEFAULT NULL,
    p_delivery_id OUT NUMBER,
    p_delivery_number OUT VARCHAR2
  ) IS
    v_distance NUMBER := 5; -- Mock distance
    v_fee NUMBER;
  BEGIN
    v_fee := C_BASE_FEE + (v_distance * C_PER_KM_RATE);

    INSERT INTO TBL_DEL_DELIVERIES(
      ORDER_ID, PICKUP_ADDRESS, DELIVERY_ADDRESS, DELIVERY_LAT, DELIVERY_LONG,
      DISTANCE_KM, DELIVERY_FEE, STATUS, EST_DELIVERY_TIME
    ) VALUES (
      p_order_id, 'Restaurant Address', p_delivery_address, p_delivery_lat, p_delivery_long,
      v_distance, v_fee, 'PENDING', SYSDATE + (45/1440)
    ) RETURNING DELIVERY_ID, DELIVERY_NUMBER INTO p_delivery_id, p_delivery_number;
    COMMIT;
  END;

  PROCEDURE PRC_ASSIGN_DRIVER(
    p_delivery_id IN NUMBER,
    p_driver_id IN NUMBER
  ) IS
  BEGIN
    UPDATE TBL_DEL_DELIVERIES SET DRIVER_ID = p_driver_id, STATUS = 'ASSIGNED'
    WHERE DELIVERY_ID = p_delivery_id;
    UPDATE TBL_DEL_DRIVERS SET IS_AVAILABLE = 'N' WHERE DRIVER_ID = p_driver_id;
    COMMIT;
  END;

  PROCEDURE PRC_UPDATE_DELIVERY_STATUS(
    p_delivery_id IN NUMBER,
    p_new_status IN VARCHAR2,
    p_location_lat IN NUMBER DEFAULT NULL,
    p_location_long IN NUMBER DEFAULT NULL
  ) IS
  BEGIN
    UPDATE TBL_DEL_DELIVERIES SET STATUS = p_new_status WHERE DELIVERY_ID = p_delivery_id;

    INSERT INTO TBL_DEL_DELIVERY_TRACKING(DELIVERY_ID, STATUS, LOCATION_LAT, LOCATION_LONG, MESSAGE)
    VALUES (p_delivery_id, p_new_status, p_location_lat, p_location_long, 'Status: ' || p_new_status);

    IF p_new_status IN ('DELIVERED', 'CANCELLED') THEN
      UPDATE TBL_DEL_DRIVERS SET IS_AVAILABLE = 'Y'
      WHERE DRIVER_ID = (SELECT DRIVER_ID FROM TBL_DEL_DELIVERIES WHERE DELIVERY_ID = p_delivery_id);
    END IF;
    COMMIT;
  END;

  PROCEDURE PRC_CREATE_DRIVER(
    p_driver_name IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_vehicle_type IN VARCHAR2,
    p_vehicle_number IN VARCHAR2,
    p_driver_id OUT NUMBER
  ) IS
  BEGIN
    INSERT INTO TBL_DEL_DRIVERS(DRIVER_NAME, PHONE_NUMBER, VEHICLE_TYPE, VEHICLE_NUMBER, IS_AVAILABLE)
    VALUES (p_driver_name, p_phone_number, p_vehicle_type, p_vehicle_number, 'Y')
    RETURNING DRIVER_ID INTO p_driver_id;
    COMMIT;
  END;

  FUNCTION FNC_GET_AVAILABLE_DRIVERS RETURN TYP_DEL_DRIVERS_TAB IS
    v_drivers TYP_DEL_DRIVERS_TAB;
  BEGIN
    SELECT TYP_DEL_DRIVER_REC(DRIVER_ID, DRIVER_NAME, PHONE_NUMBER, VEHICLE_TYPE, IS_AVAILABLE)
    BULK COLLECT INTO v_drivers
    FROM TBL_DEL_DRIVERS WHERE IS_AVAILABLE = 'Y';
    RETURN v_drivers;
  END;
END PKG_DEL_API;
/
