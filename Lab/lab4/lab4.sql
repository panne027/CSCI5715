/* CSCI 5715	Fall 2020  */
/* Lab 4	    12/01/2020 */
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

--spool lab4_partA.txt

/* Load and Edit Tables */
/*
exec SDO_NET.CREATE_SDO_NETWORK('hennepin',1,TRUE,FALSE);
describe hennepin_node$;
insert into hennepin_node$ select * from csci5715.hennepin_node$;
alter table hennepin_link$ add transit_id number;
describe hennepin_link$;
insert into hennepin_link$ select * from csci5715.hennepin_link$;
describe csci5715.hennepin_transit_time;
*/
--spool off

/*---------------------------------------------------------------------------*/

/* Part B: Using a Spatial Network */

spool lab4_partB.txt

-- How many links are in the network?
select SDO_NET.GET_NO_OF_LINKS('hennepin') from DUAL;
-- How many nodes are in the network?
select SDO_NET.GET_NO_OF_NODES('hennepin') from DUAL;
-- What is the degree of node 140776?
select distinct SDO_NET.GET_NODE_DEGREE('hennepin', 140776) from DUAL;
-- Find all nodes with an OUT degree of at most 1.
select node_id from hennepin_node$ where SDO_NET.GET_NODE_OUT_DEGREE('hennepin', node_id) <= 1;
-- What is the average IN degree of all nodes in the network?
select AVG(SDO_NET.GET_NODE_IN_DEGREE('hennepin',node_id)) as Avg_In_Degree from hennepin_node$;
-- Retrieve the travel times (TRANSIT_TIME) for link 300 with start time and end time occuring between 630 and 1020.
select tr.transit_time from csci5715.hennepin_transit_time tr, hennepin_link$ lnk where lnk.link_id = 300 and tr.start_time >= 630 and tr.end_time <= 1020 and tr.transit_id = lnk.transit_id;
-- Retrieve the travel times (TRANSIT_TIME) for link 300 with start time and end time occuring between 1230 and 1440.
select tr.transit_time from csci5715.hennepin_transit_time tr, hennepin_link$ lnk where lnk.link_id = 300 and tr.start_time >= 1230 and tr.end_time <= 1440 and tr.transit_id = lnk.transit_id;
-- What are the minimum and maximum travel times for link 1000?
select MIN(tr.transit_time) as Min_Transit_Time, MAX(tr.transit_time) as Max_Transit_Time from csci5715.hennepin_transit_time tr, hennepin_link$ lnk where lnk.link_id = 1000 and tr.transit_id = lnk.transit_id;

spool off
