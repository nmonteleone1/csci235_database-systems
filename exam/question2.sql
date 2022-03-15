CREATE OR REPLACE TRIGGER CheckProducts
BEFORE INSERT OR UPDATE
    ON PRODUCT
DECLARE
    categoryCount NUMBER;
BEGIN
    SELECT COUNT(CATEGORY_NAME) INTO categoryCount
    FROM PRODUCT
    GROUP BY SUPPLIER_NAME;
    
    IF categoryCount >= 4 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No more than three product categories per manufacturer.');
    END IF;
END;
/

DROP TRIGGER CheckProducts;