SPOOL solution4;
SET SERVEROUTPUT ON;
SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 300;
SET PAGESIZE 400;

DECLARE
    currentOrder ORDER_DETAIL.ORDER_ID%type;
    totalValue ORDER_DETAIL.UNIT_PRICE%type;
    itemName ORDER_DETAIL.PRODUCT_NAME%type;
    CURSOR get_order IS
        SELECT ORDER_ID, SUM(UNIT_PRICE * QUANTITY)
        FROM ORDER_DETAIL
        GROUP BY ORDER_ID;
    CURSOR get_items IS
        SELECT PRODUCT_NAME
        FROM ORDER_DETAIL
        WHERE ORDER_ID = currentOrder;
BEGIN
    --Open first cursor to find all order details
    OPEN get_order;
    LOOP
        FETCH get_order INTO currentOrder, totalValue;
            EXIT WHEN get_order%notfound;
            dbms_output.put_line('Order id: ' || currentOrder);
            dbms_output.put_line('Total value: ' || totalValue);
            dbms_output.put_line('Names of products ordered:');
            
            --Open second cursor to get all items in this order
            OPEN get_items;
            LOOP
                FETCH get_items INTO itemName;
                    EXIT WHEN get_items%notfound;
                    dbms_output.put_line(itemName);
            END LOOP;
            CLOSE get_items;
            dbms_output.put_line('---------------------------------------------');
    END LOOP;
    CLOSE get_order;
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END;
/
SPOOL OFF;