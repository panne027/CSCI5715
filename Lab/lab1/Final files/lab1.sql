/* CSCI 5715	Fall 2020 */
/* Lab 1	9/29/2020 */
/*
   Group 1: 	Matthew Eagon
                Harish Panneer Selvam 
*/

/*---------------------------------------------------------------------------*/

@country.sql;

/* Output Options */
set echo on
set trimspool on
set pagesize 24
set linesize 100

spool lab1_tutorial.txt

/* Part A: SQL/Oracle Tutorial */

/* Example Queries */
select tablespace_name, table_name from user_tables;
describe COUNTRY
select distinct name from country where region='South America';

/* Suggested Spool Queries*/
select distinct name from country where region='Africa';
select distinct name from country where region = 'Europe' and name like 'A%';

spool off

/*---------------------------------------------------------------------------*/

/* Part B: Simple SQL Queries */

spool lab1_out.txt

/* Part 1: Selection and Projection */

/* List all countries (without duplicates) in South America and Africa, sorted by population in year 2008 in descending order. */
select distinct co.name, co.population from country co where co.year=2008 and (co.region='South America' or co.region ='Africa') order by co.population desc;
/* List all European countries (without duplicates) with a population more than one million (2,500,500) in year 2006. */
select distinct co.name, co.population from country co where co.year=2006 and (co.region='South America' or co.region ='Africa') and co.population > 1000000 order by co.population desc;
/* List the regions (without duplicates) of all countries starts with the letter "a" or "i" (lowercase) in their names. */
select distinct co.region from country co where substr(lower(co.name), 1, 1)='a' or substr(lower(co.name), 1, 1)='i' order by co.region;
/* List the regions (without duplicates) of all countries whose name ends with the letter "a" or "i". */
select distinct co.region from country co where co.name like '%a' or co.name like '%i' order by co.region; 

/*---------------------------------------------------------------------------*/

/* Part 2: Summarization, Aggregation */

/* Find how many countries (without duplicates) there are in Asia and show their average GDP in year 2006. */
select distinct count(co.name) as numCountriesAsia_2006, avg(co.gdp) as regionGDPAsia_2006 from country co where co.year=2006 and region='Asia' group by co.region;
/* List all the regions (without duplicates) with at least 8 countries whose population is greater than 500,000 in year 2007. */
select distinct co.region from country co where co.year=2007 and co.population>=500000 group by co.region having count(co.name) >= 8 order by co.region asc;

/*---------------------------------------------------------------------------*/

/* Part 3: Insert, Update, and Delete */

/* Insert a new row with Country name = "MyNewCountry", with population = 1 and area = 5 (with any year and continent you want). */
insert into country (name,year,region,area,population,gdp) values ('MyNewCountry',2000,'North America',5,1,0.0);
/* Update the area to 95 for all the rows that have an area below 95. */
update country set area=95 where area<95;
/* Update the population value of countries that are zero or Null to the average population in that region. */
--select distinct co.region, avg(co.population), co.year as avgRegionPop from country co group by co.region,co.year;
--select distinct co.name, co.year, co.region, co.population from country co where co.population=0 or co.population is Null;
update country co set population=(select distinct avg(population) from country where region=co.region group by region) where population=0 or population is Null;
--update country co set co.population=(select distinct avg(co1.population) from country co1 where co1.region = co.region and co1.year=co.year group by co1.region, co1.year) where co.population=0 or co.population is Null;
--select distinct co.name, co.population, co.year from country co where co.region='Commonwealth of Independent States - Central Asian States' and co.year=1991; 
--select distinct co.name, co.region,co.population as avgRegionPop, co.year from country co where co.name='Uzbekistan' and co.year='1991'; /* Check if update worked. */

/* Delete all the rows that have null values for the gdp or population field. */
delete from country where population is Null or gdp is Null;


spool off

drop table country;
