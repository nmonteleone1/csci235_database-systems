spool dbdrop

set echo on
set feedback on
set linesize 300
set pagesize 100


DROP TABLE ORDER_DETAIL PURGE;
DROP TABLE ORDERS PURGE;
--DROP TABLE PRODUCT PURGE;
--DROP TABLE SUPPLIER PURGE;
--DROP TABLE CATEGORY PURGE;
DROP TABLE CUSTOMER PURGE;
DROP TABLE EMPLOYEE PURGE;
DROP TABLE SHIPPER PURGE;
DROP TABLE COUNTRY_ORDERS PURGE;

spool off