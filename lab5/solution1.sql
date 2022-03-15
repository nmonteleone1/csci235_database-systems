SPOOL solution1
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 400

/* (1)	Create a database link from the "host server" to the "remote server".                                */

CREATE DATABASE LINK "DB.DATA-PC07" CONNECT TO nm824 IDENTIFIED BY zeb1b4 USING 'data-pc07.adeis.uow.edu.au:1521/db';

/* (2)	Create a synonym names of the empty relational tables located at the "remote server".                */

CREATE SYNONYM remoteCAT FOR CATEGORY@"DB.DATA-PC07";
CREATE SYNONYM remotePROD FOR PRODUCT@"DB.DATA-PC07";
CREATE SYNONYM remoteSUP FOR SUPPLIER@"DB.DATA-PC07";

/* (3)	Use the database links to move information about all categories of products, all suppliers located 
        in USA or in UK or in Australia and all products supplied by the suppliers located in USA or in UK 
        or in Australia from the "host server" to the "remote server".                                       

        "Move" means, that all information about suppliers and products copied from the "host server" to 
        the "remote server" must be later on removed from the "host server".                                 */

INSERT INTO remoteCAT
    SELECT *
    FROM CATEGORY
;

INSERT INTO remoteSUP
    SELECT *
    FROM SUPPLIER
    WHERE COUNTRY = 'USA' OR COUNTRY = 'UK' OR COUNTRY = 'Australia'
;

INSERT INTO remotePROD
    SELECT *
    FROM PRODUCT
    WHERE SUPPLIER_NAME IN (
        SELECT COMPANY_NAME
        FROM remoteSUP
        )
;

DELETE FROM PRODUCT
WHERE SUPPLIER_NAME IN (
        SELECT COMPANY_NAME
        FROM remoteSUP
        )
;

DELETE FROM SUPPLIER
WHERE  COUNTRY = 'USA' 
   OR  COUNTRY = 'UK' 
   OR  COUNTRY = 'Australia'
;

/* (4)	Implement a query that finds the total number of products supplied by each supplier. If a supplier 
        supplies no products then list a name of a supplier with a number zero.                              
        Order the results in the ascending order of the total number of supplied products.                   */
        
SELECT SUPPLIER_NAME, COUNT(SUPPLIER_NAME)-1
FROM (
    SELECT SUPPLIER_NAME, PRODUCT_NAME
    FROM PRODUCT 
    
    UNION 
    
    SELECT COMPANY_NAME AS SUPPLIER_NAME, ADDRESS
    FROM SUPPLIER
    
    UNION
    
    SELECT SUPPLIER_NAME, PRODUCT_NAME
    FROM remotePROD
    
    UNION
    
    SELECT COMPANY_NAME AS SUPPLIER_NAME, ADDRESS
    FROM remoteSUP)
GROUP BY SUPPLIER_NAME
ORDER BY SUPPLIER_NAME
;

/* (5)	List the names of relational tables located at the "remote server. To do so you have to access 
        a data dictionary view USER_TABLES at the "remote server".                                           */
        
SELECT TABLE_NAME
FROM USER_TABLES@"DB.DATA-PC07";

/* (6)	Drop the synonyms and a database link.                                                               */

DROP SYNONYM remoteCAT;
DROP SYNONYM remotePROD;
DROP SYNONYM remoteSUP;

DROP DATABASE LINK "DB.DATA-PC07";

SPOOL OFF