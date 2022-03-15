SPOOL solution1
SET SERVEROUTPUT ON
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 400

/* (1) First, the script modifies the structures of a sample database such it is possible to store information about 
       the manufacturers of the products listed in the database. A manufacturer is described by a unique name, country, 
       and city where it is located. Assume, that a manufacturer can manufacture many products and a product can be 
       manufacturer by many manufacturers.                                                                                          */

CREATE TABLE MANUFACTURER
(
    MANUFACTURER_NAME   VARCHAR(40)     NOT NULL,
    COUNTRY             VARCHAR(15)     NOT NULL,
    CITY                VARCHAR(15)     NOT NULL,
    CONSTRAINT PK_MANUFACTURER PRIMARY KEY (MANUFACTURER_NAME)
);

CREATE TABLE MANUFACTURING_DETAIL
(
    MANUFACTURER_NAME        VARCHAR(40)     NOT NULL,
    PRODUCT_NAME             VARCHAR(40)     NOT NULL,
    CONSTRAINT PK_DETAIL PRIMARY KEY (MANUFACTURER_NAME, PRODUCT_NAME),
    CONSTRAINT FK_MANUFACTURER FOREIGN KEY (MANUFACTURER_NAME) REFERENCES MANUFACTURER(MANUFACTURER_NAME),
    CONSTRAINT FK_PRODUCT FOREIGN KEY (PRODUCT_NAME) REFERENCES PRODUCT(PRODUCT_NAME)
);

/* (2) Next, the script inserts into a database information about 3 manufacturers and make the insertions permanent.                */

INSERT INTO MANUFACTURER(MANUFACTURER_NAME, COUNTRY, CITY)
VALUES('Nestle', 'Switzerland', 'Vevey');

INSERT INTO MANUFACTURER(MANUFACTURER_NAME, COUNTRY, CITY)
VALUES('Volkswagen Group', 'Germany', 'Wolfsburg');

INSERT INTO MANUFACTURER(MANUFACTURER_NAME, COUNTRY, CITY)
VALUES('Samsung Electronics', 'South Korea', 'Suwon-si');

COMMIT;

/* (3) Next, the script stores in a data dictionary PL/SQL procedure that links the manufacturers with the products.      
       The procedure must enforce the following consistency constraint.                                                    

       No more than two manufacturers are allowed to manufacture the same product.

       The procedure must display an error when the consistency constraint is violated and it must not insert a link 
       between a manufacturer and a product. Otherwise, the procedure must insert a link into a database and make 
       the link permanent.

       Remember to put / in the next line after CREATE OR REPLACE PROCEDURE statement and a line show errors in the next line.      */
       
CREATE OR REPLACE TRIGGER CheckManufacturing
BEFORE INSERT 
    ON MANUFACTURING_DETAIL FOR EACH ROW
DECLARE
    product_manufacturers MANUFACTURING_DETAIL.MANUFACTURER_NAME%type;
BEGIN
    SELECT COUNT(*)
    INTO product_manufacturers
    FROM MANUFACTURING_DETAIL
    WHERE PRODUCT_NAME = :NEW.PRODUCT_NAME;
    
    IF product_manufacturers >= 2 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No more than two manufacturers are allowed to manufacture ' || :NEW.PRODUCT_NAME);
    END IF;
END;
/

/* (4) Next, the script performs the comprehensive testing of the stored procedure implemented in the previous step. 
       The testing must refuse at least one time to link a manufacturer with a product due to the violated consistency
        constraint.                                .                                                                               */

INSERT INTO MANUFACTURING_DETAIL(MANUFACTURER_NAME, PRODUCT_NAME)
VALUES('Nestle', 'Chai');

INSERT INTO MANUFACTURING_DETAIL(MANUFACTURER_NAME, PRODUCT_NAME)
VALUES('Volkswagen Group', 'Chai');

INSERT INTO MANUFACTURING_DETAIL(MANUFACTURER_NAME, PRODUCT_NAME)
VALUES('Samsung Electronics', 'Northwoods Cranberry Sauce');

INSERT INTO MANUFACTURING_DETAIL(MANUFACTURER_NAME, PRODUCT_NAME)
VALUES('Nestle', 'Chang');

INSERT INTO MANUFACTURING_DETAIL(MANUFACTURER_NAME, PRODUCT_NAME)
VALUES('Nestle', 'Aniseed Syrup');

INSERT INTO MANUFACTURING_DETAIL(MANUFACTURER_NAME, PRODUCT_NAME)
VALUES('Volkswagen Group', 'Aniseed Syrup');

INSERT INTO MANUFACTURING_DETAIL(MANUFACTURER_NAME, PRODUCT_NAME)
VALUES('Samsung Electronics', 'Chang');

INSERT INTO MANUFACTURING_DETAIL(MANUFACTURER_NAME, PRODUCT_NAME)
VALUES('Samsung Electronics', 'Chai');

/* (5) Finally, the script lists all information about the manufacturers and the names of product manufactured by each 
       manufacturer.                                                                                                               */

SELECT MANUFACTURER.MANUFACTURER_NAME, COUNTRY, CITY, PRODUCT_NAME
FROM MANUFACTURER
LEFT JOIN MANUFACTURING_DETAIL ON MANUFACTURER.MANUFACTURER_NAME = MANUFACTURING_DETAIL.MANUFACTURER_NAME;

SPOOL OFF
