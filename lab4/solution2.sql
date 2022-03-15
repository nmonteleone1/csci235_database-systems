@C:\Users\nick\Desktop\CSCI235\scripts\dbdrop.sql;
@C:\Users\nick\Desktop\CSCI235\scripts\dbcreate.sql;
@C:\Users\nick\Desktop\CSCI235\scripts\dbload.sql;

SPOOL solution2
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 100
SET PAGESIZE 200
SET SERVEROUTPUT ON

/* (1) First the script, adds a column to a relational table SUPPLIER that contains information about trusted suppliers.             */

ALTER TABLE SUPPLIER
ADD TRUST VARCHAR(9) DEFAULT 'UNTRUSTED';

/* (2) Next, the script updates a relational table SUPPLIER to make at least one supplier trusted.                                   */

UPDATE SUPPLIER
SET TRUST = CASE 
                WHEN COMPANY_NAME = 'Exotic Liquids' THEN 'TRUSTED'
                ELSE 'UNTRUSTED'
            END
;

/* (3) Next, the script creates a row trigger, that automatically verifies if information about a new product to be inserted into 
       a sample database is supplied by a trusted supplier. If a supplier is not trusted, then the insertion must fail and an error 
       message must be displayed. In this particular case it is the "good error" that DOES NOT cause deduction of any marks ï?Š.  
       If a supplier is trusted, then the trigger allows for insertion of information about a new product and no message is 
       displayed.                                                                                                                    */

CREATE OR REPLACE TRIGGER CheckSupplier BEFORE INSERT ON PRODUCT FOR EACH ROW
DECLARE
    trustStatus SUPPLIER.TRUST%type;
BEGIN  
    SELECT TRUST
    INTO trustStatus
    FROM SUPPLIER
    WHERE SUPPLIER.COMPANY_NAME = :NEW.SUPPLIER_NAME;

    IF trustStatus != 'TRUSTED' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Product supplier "' || :NEW.SUPPLIER_NAME || '" is not a trusted supplier.');
    END IF;

END;
/

/* (4) Next, the script comprehensively tests the trigger. A test must include at least one insertion of a of information about 
       a new product, that comes from a trusted supplier and one insertion of information about a new product, that comes from not 
       trusted supplier. If insertion is successful that the script must list a row inserted into PRODUCT relational table.          */

INSERT INTO PRODUCT (   PRODUCT_NAME, 
                        SUPPLIER_NAME, 
                        CATEGORY_NAME, 
                        QUANTITY_PER_UNIT, 
                        UNIT_PRICE, 
                        UNITS_IN_STOCK, 
                        UNITS_ON_ORDER, 
                        REORDER_LEVEL, 
                        DISCONTINUED
)
VALUES ('Extremely-Hot Hot-Sauce', 
        'Exotic Liquids', 
        'Condiments', 
        '12 boxes', 
        13, 
        32, 
        0, 
        15, 
        'N'
);

SELECT COMPANY_NAME, TRUST
FROM SUPPLIER;

INSERT INTO PRODUCT (   PRODUCT_NAME, 
                        SUPPLIER_NAME, 
                        CATEGORY_NAME, 
                        QUANTITY_PER_UNIT, 
                        UNIT_PRICE, 
                        UNITS_IN_STOCK, 
                        UNITS_ON_ORDER, 
                        REORDER_LEVEL, 
                        DISCONTINUED
)
VALUES ('Parmesan of Moderna', 
        'Formaggi Fortini s.r.l.', 
        'Diary Products', 
        '100g pkg', 
        45, 
        16, 
        0, 
        4, 
        'N'
);

/* (5) Finally, the script removes from a data dictionary a trigger created in a step (3).                                           */

DROP TRIGGER CheckSupplier;

SPOOL OFF

