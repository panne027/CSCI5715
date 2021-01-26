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

/*---------------------------------------------------------------------------*/

/* Part B: Recursive Queries */

spool lab3_partB.txt

-- List airports can be arrived from "Sun Valley/Hailey/Ketchum, ID" (AIRPORT_ID: 15041) with at most one stop?
with arrivals_from_SunValleyID (start_node_id, end_node_id, search_depth) as (
    select start_node_id, end_node_id, 0 search_depth from airport_link$ where start_node_id = 15041
    union all select lnk.start_node_id, lnk.end_node_id, arv.search_depth+1 
    from arrivals_from_SunValleyID arv, airport_link$ lnk 
    where arv.end_node_id = lnk.start_node_id and arv.search_depth = 0)
select distinct lst.airport_name, lst.airport_id from arrivals_from_SunValleyID arv, airport_list lst
where search_depth <= 1 and arv.end_node_id = lst.airport_id;
-- List the least number of stops is needed flying from "Honolulu, HI" (AIRPORT_ID: 12173) to "New York, NY" (AIRPORT_ID: 12953)
-- Note: Limits depth of search to 2 for now to avoid cycles and reduce computation time.
with HonaluluHI_to_NewYorkNY (start_node_id, end_node_id, num_stops) as (
    select start_node_id, end_node_id, 0 num_stops from airport_link$ where start_node_id = 12173
    union all select lnk.start_node_id, lnk.end_node_id, hny.num_stops+1
    from HonaluluHI_to_NewYorkNY hny, airport_link$ lnk
    where hny.end_node_id = lnk.start_node_id and hny.start_node_id <> lnk.start_node_id and hny.num_stops <= 2)
select min(num_stops) as min_stops_Honalulu_to_NewYork from HonaluluHI_to_NewYorkNY where end_node_id = 12953;

spool off

/*---------------------------------------------------------------------------*/

/* Part C: Spatial Indexes and Joins */

--drop table COUNTRY2020;
--drop table RIVER2020;
/*
@lab3_create.sql;

describe COUNTRY2020;
describe RIVER2020;
insert into COUNTRY2020 select * from csci5715.COUNTRIES;
insert into RIVER2020 select * from csci5715.RIVERS;
CREATE INDEX COUNTRY2020_IDX ON COUNTRY2020(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;
CREATE INDEX RIVER2020_IDX ON RIVER2020(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;
*/

spool lab3_partC1.txt

/* Part 1: Spatial Indexes */
-- List names of 5 nearest countries to "Iran (Islamic Republic of)".
select co1.name from COUNTRY2020 co1, COUNTRY2020 co2 where SDO_NN(co1.geom, co2.geom, 'sdo_num_res=6')='TRUE'
and co2.name = 'Iran (Islamic Republic of)' and co1.name <> 'Iran (Islamic Republic of)';
-- List names of all countries crossed by the river of Amazon (Amazonas in RiVER2020 dataset)
--select distinct co.name from COUNTRY2020 co, RIVER2020 ri where ri.name = 'Amazonas' and SDO_OVERLAPS(co.geom, ri.geom)='TRUE';
select distinct co.name from COUNTRY2020 co, RIVER2020 ri where ri.name = 'Amazonas' and SDO_GEOM.SDO_INTERSECTION(co.geom, ri.geom) is not Null;
-- List names of all neighboring countries of "Iran (Islamic Republic of)".
select distinct co2.name from COUNTRY2020 co1, COUNTRY2020 co2 where SDO_TOUCH(co1.geom, co2.geom)='TRUE' 
and co1.name = 'Iran (Islamic Republic of)' and co2.name <> 'Iran (Islamic Republic of)';

spool off

spool lab3_partC2.txt

/* Part 2: Query Response Time */
set timing on;
-- List names of all country pairs that are within 1 unit distance (using SDO_GEOM.WITHIN_DISTANCE).
-- Takes too long to execute (over 2 hours)
/*
select co1.name, co2.name from COUNTRY2020 co1, COUNTRY2020 co2, user_sdo_geom_metadata m
where m.table_name='COUNTRY2020' and co1.name <> co2.name
and SDO_GEOM.WITHIN_DISTANCE(co1.geom, m.diminfo, 1, co2.geom, m.diminfo)='TRUE';
*/
-- List names of all country pairs that are within 1 unit distance (using SDO_WITHIN_DISTANCE).
/* Takes less than 1 minute to execute */
select co1.name, co2.name from COUNTRY2020 co1, COUNTRY2020 co2 where co1.name <> co2.name
and SDO_WITHIN_DISTANCE(co1.geom, co2.geom, 'distance=1')='TRUE';

spool off

/*---------------------------------------------------------------------------*/

/* Part D: Spatial Hotspot Detection - Using SatScan */
