SET WRAP OFF
SPOOL solution2
SET SERVEROUTPUT ON
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 100
SET PAGESIZE 400

/* (1) First, store in a data dictionary PL/SQL function, that returns a string that consists of the names of 
       products purchased by a customer with a given customer code.

       Make a customer code a formal parameter of the function. A name of a function is up to you.  A string 
       returned by the function must consists of the names of products separated with a comma (,). 

       If a customer purchased no products then the function must return an empty string.                         */

CREATE OR REPLACE FUNCTION listProducts( currentCustomerCode IN VARCHAR )
RETURN VARCHAR IS
    product_list VARCHAR(2000) := '';

    currentOrder ORDERS.ORDER_ID%type;
    itemName ORDER_DETAIL.PRODUCT_NAME%type;
    itemCounter NUMBER := 0;
    
    CURSOR customer_orders IS
        SELECT ORDER_ID
        FROM ORDERS
        WHERE CUSTOMER_CODE = currentCustomerCode;
        
    CURSOR get_product IS
        SELECT PRODUCT_NAME
        FROM ORDER_DETAIL
        WHERE ORDER_ID = currentOrder;
        
BEGIN    
    OPEN customer_orders;
    LOOP
        FETCH customer_orders INTO currentOrder;
            EXIT WHEN customer_orders%notfound;
            
            OPEN get_product;
            LOOP
                FETCH get_product INTO itemName;
                    EXIT WHEN get_product%notfound;
                    IF itemCounter = 0 THEN
                        product_list := itemName;
                        itemCounter := itemCounter + 1;
                    ELSE
                        product_list := product_list || ',' || itemName;
                        itemCounter := itemCounter + 1;
                    END IF;
            END LOOP;
            CLOSE get_product;
            
    END LOOP;
    CLOSE customer_orders;    
    
    RETURN product_list;
END;
/

/* (2) To test your function implement SELECT statement that lists codes of the customers together with the names 
       of product purchased by the customers. List the customers who purchased only 3 products. A sample 
       output may look like below.

       Code  Products                                                                                      
       ----------------------------------------------------------------------------------------------------
       VICTE Boston Crab Meat,Louisiana Fiery Hot Pepper Sauce,Scottish Longbreads                         
       QUEDE Steeleye Stout,Chocolade,Outback Lager                                                        
       DRACD Flotemysost,Sir Rodney's Scones,Tofu                                                          
             ...		   ...	                 ...                                                                       */

SELECT *
FROM (
    WITH CUSTOMERS AS (
        SELECT CUSTOMER_CODE
        FROM ORDERS
        GROUP BY CUSTOMER_CODE),
        
        PRODUCTS AS (
        SELECT listProducts(CUSTOMER_CODE)
        FROM CUSTOMERS)
        
        SELECT CUSTOMER_CODE AS Code, listProducts(CUSTOMER_CODE) AS Product
        FROM CUSTOMERS
)
WHERE (LENGTH(Product) - LENGTH(REPLACE(Product, ',', ''))) = 2;

SPOOL OFF
