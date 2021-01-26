/* CSCI 5715	Fall 2020 */
/* Lab 3	11/16/2020 */
/*
   Group 1: 	Matthew Eagon
                Harish Panneer Selvam 
*/

/*---------------------------------------------------------------------------*/

/* Output Options */
set echo on
set trimspool on
set pagesize 24
set linesize 100

/* Part A: Preliminaries */

/* Load Tables */
--exec SDO_NET.DROP_NETWORK('airport');
/*
exec SDO_NET.CREATE_SDO_NETWORK('airport',1,TRUE,FALSE);
describe airport_node$;
describe airport_link$;
@airport_node.sql;
@airport_link.sql;
@airport_list.sql;
describe airport_list;
*/

spool lab3_partA.txt

/* Part A Queries*/
-- How many links are in the network?
select SDO_NET.GET_NO_OF_LINKS('airport') from DUAL;
-- How many nodes are in the network?
select SDO_NET.GET_NO_OF_NODES('airport') from DUAL;
-- What is the degree of node "San Francisco, CA"?
select distinct SDO_NET.GET_NODE_DEGREE('airport', AIRPORT_ID) from airport_list where airport_name = 'San Francisco, CA';
-- What is the average out degree of all nodes in the network?
select avg(SDO_NET.GET_NODE_OUT_DEGREE('airport', airport_ID)) from airport_list;

spool off

