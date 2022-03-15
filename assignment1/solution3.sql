clear screen;
SPOOL solution3
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 300
SET PAGESIZE 5000

----(1)----
EXPLAIN PLAN FOR
    SELECT product_name
    FROM ORDER_DETAIL
    ORDER BY unit_price, discount
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

CREATE INDEX curr_index
ON ORDER_DETAIL(product_name, unit_price, discount)
;

EXPLAIN PLAN FOR
    SELECT product_name
    FROM ORDER_DETAIL
    ORDER BY unit_price, discount
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

DROP INDEX curr_index
;

----(2)----
EXPLAIN PLAN FOR
    SELECT product_name, supplier_name
    FROM PRODUCT
    WHERE category_name IN ('Beverages','Condiments','Produce')
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

CREATE INDEX curr_index
ON PRODUCT(product_name, supplier_name, category_name)
;

EXPLAIN PLAN FOR
    SELECT product_name, supplier_name
    FROM PRODUCT
    WHERE category_name IN ('Beverages','Condiments','Produce')
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

DROP INDEX curr_index
;

----(3)----
EXPLAIN PLAN FOR
    SELECT company_name, contact_name
    FROM CUSTOMER
    WHERE (city= 'Marseille' or city='Madrid') AND (country = 'France' OR country = 'Spain')
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

CREATE INDEX curr_index
ON CUSTOMER(company_name, contact_name, city, country)
;

EXPLAIN PLAN FOR
    SELECT company_name, contact_name
    FROM CUSTOMER
    WHERE (city= 'Marseille' or city='Madrid') AND (country = 'France' OR country = 'Spain')
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

DROP INDEX curr_index
;


----(4)----
EXPLAIN PLAN FOR
    SELECT customer_code
    FROM ORDERS
    WHERE order_date >= '01-JAN-2010'
    MINUS
    SELECT customer_code
    FROM ORDERS
    WHERE ship_city NOT IN ('Rio de Janeiro','Anchorage')
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

CREATE INDEX curr_index
ON ORDERS(order_date)
;

EXPLAIN PLAN FOR
    SELECT customer_code
    FROM ORDERS
    WHERE order_date >= '01-JAN-2010'
    MINUS
    SELECT customer_code
    FROM ORDERS
    WHERE ship_city NOT IN ('Rio de Janeiro','Anchorage')
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

DROP INDEX curr_index
;

----(5)----
EXPLAIN PLAN FOR
    SELECT city, count(*)
    FROM SUPPLIER
    GROUP BY city
    HAVING count(*) > 3
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

CREATE INDEX curr_index
ON SUPPLIER(city)
;

EXPLAIN PLAN FOR
    SELECT city, count(*)
    FROM SUPPLIER
    GROUP BY city
    HAVING count(*) > 3
;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY)
;

DROP INDEX curr_index
;

SPOOL OFF