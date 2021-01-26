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
