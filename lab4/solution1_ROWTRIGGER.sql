@C:\Users\nick\Desktop\CSCI235\scripts\dbdrop.sql;
@C:\Users\nick\Desktop\CSCI235\scripts\dbcreate.sql;
@C:\Users\nick\Desktop\CSCI235\scripts\dbload.sql;

SPOOL solution1
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 400
SET SERVEROUTPUT ON

/* (1) First, the script creates the additional database structures to record information about the total number of orders submitted per
       country and year. For example, a sample database should contain information about the total number of orders submitted by
       the customers located in Germany in 1996, next, the total number of orders submitted by the customers located in Germany in 1995, …
       next total number if orders submitted by the customers located in France in 1996, next, the total number of orders submitted by
       the customers located in France in 1997, … and so on, and so on.                                                                     */

CREATE TABLE COUNTRY_ORDERS
(
    COUNTRY     VARCHAR(15)     NOT NULL,
    YEAR        VARCHAR(4)      NOT NULL,
    ORDER_COUNT NUMBER(9)       DEFAULT 0,
    
    CONSTRAINT PK_COUNTRY_YEAR PRIMARY KEY (COUNTRY, YEAR)
);

/* (2) Next, the script stores in a sample database information about the total number of orders submitted per country and year. 
       The information must be derived from the present contents of a sample database.                                                      */

INSERT INTO COUNTRY_ORDERS
SELECT SHIP_COUNTRY, EXTRACT(year FROM SHIPPED_DATE) "Year", COUNT(SHIPPED_DATE) "Total Orders"
FROM ORDERS
GROUP BY (SHIP_COUNTRY, EXTRACT(year FROM SHIPPED_DATE))
ORDER BY SHIP_COUNTRY
;

/* (3) Next, this script list information about the total number of orders submitted per country and year.                                  */

SELECT *
FROM COUNTRY_ORDERS
;

/* (4) Next, the script creates a statement trigger, that automatically updates information about the total number of orders submitted 
       per country and year whenever a new order is added or whenever an old order is deleted from a sample database.                       */

CREATE OR REPLACE TRIGGER UpdateOrderTotal AFTER INSERT OR DELETE ON ORDERS FOR EACH ROW
BEGIN  
    UPDATE COUNTRY_ORDERS
    SET order_count = order_count + 1
    WHERE :NEW.SHIP_COUNTRY = COUNTRY_ORDERS.COUNTRY AND EXTRACT(year FROM :NEW.SHIPPED_DATE) = COUNTRY_ORDERS.YEAR;
    
    UPDATE COUNTRY_ORDERS
    SET order_count = order_count - 1
    WHERE :OLD.SHIP_COUNTRY = COUNTRY_ORDERS.COUNTRY AND EXTRACT(year FROM :OLD.SHIPPED_DATE) = COUNTRY_ORDERS.YEAR;    
END;
/

/* (5) Next, the script comprehensively tests the trigger. A test must include at least one insertion of a new order and at least one 
       deletion of an old order. The script must list information about the total number of orders submitted per country and year after 
       insertion of a new order and after deletion of an older one.                                                                         */

INSERT INTO ORDERS
   (ORDER_ID, CUSTOMER_CODE, EMPLOYEE_ID, ORDER_DATE, REQUIRED_DATE, SHIPPED_DATE, SHIP_VIA, FREIGHT, SHIP_NAME, SHIP_ADDRESS, SHIP_CITY, SHIP_REGION, SHIP_POSTAL_CODE, SHIP_COUNTRY)
 VALUES
   (700,'SAVEA', 4, TO_DATE('02/10/1998', 'MM/DD/YYYY'), TO_DATE('03/10/1998', 'MM/DD/YYYY'), 
    TO_DATE('02/28/1998', 'MM/DD/YYYY'), 'United Package', 86.53, 'Old World Delicatessen', '187 Suffolk Ln.', 
    'Boise', 'ID', '83720', 'USA');
    
SELECT *
FROM COUNTRY_ORDERS
;

DELETE FROM ORDER_DETAIL WHERE ORDER_ID = 378;
DELETE FROM ORDERS WHERE ORDER_ID = 378;

SELECT *
FROM COUNTRY_ORDERS
;

/* (6) Finally, the script removes from a data dictionary a trigger created in a step (4).                                                  */

DROP TRIGGER UpdateOrderTotal;

SPOOL OFF




