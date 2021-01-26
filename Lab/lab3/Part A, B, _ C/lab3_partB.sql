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

