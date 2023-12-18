/*
India Census Data Exploration and insight generation

Skills used: Joins, Windows Functions, Aggregate Functions, Converting Data Types, Temp tables

*/

-------------------------------------------------------------------------------------------------------------------------------

select * 
from project.dbo.data1;

select * 
from project.dbo.data2;


-- Number of entries in ech dataset

select count(*) 
from project..data1
select count(*) 
from project..data2

 
-- All data for states of Jharkhand and Bihar

select * 
from project..data1 
where state in ('Jharkhand' ,'Bihar')

 
-- Total population of India

select sum(population) as Population 
from project..data2

 
-- Average growth rate

select state,avg(growth)*100 avg_growth 
from project..data1 
group by state;


-- Average sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio 
from project..data1 
group by state 
order by avg_sex_ratio desc;


-- Average literacy ratio
 
select state,round(avg(literacy),0) avg_literacy_ratio
from project..data1 
group by state 
having round(avg(literacy),0)>90 
order by avg_literacy_ratio desc ;


-- Top 3 states with highest growth ratio

select state,avg(growth)*100 avg_growth
from project..data1
group by state 
order by avg_growth desc limit 3;


-- Top 3 states showing lowest sex ratio

select top 3 state,round(avg(sex_ratio),0) avg_sex_ratio
from project..data1 
group by state 
order by avg_sex_ratio asc;


-- Combining top 3 states having highest literacy ratio and bottom 3 states having lowest literacy ratio (UNION OPERATOR) 

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio 
from project..data1 
group by state 
order by avg_literacy_ratio desc;

select top 3 * 
from #topstates 
order by #topstates.topstate desc;


drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio 
from project..data1 
group by state 
order by avg_literacy_ratio desc;

select top 3 * 
from #bottomstates 
order by #bottomstates.bottomstate asc;


select * 
from (
      select top 3 * 
      from #topstates 
      order by #topstates.topstate desc) top
union

select * 
from (
       select top 3 * 
       from #bottomstates 
       order by #bottomstates.bottomstate asc) bottom;


-- States starting with letter 'A' or 'B'

select distinct state 
from project..data1 
where lower(state) like 'a%' or lower(state) like 'b%'

 
-- States starting with letter 'A' and ending with letter 'M'
 
select distinct state
from project..data1 
where lower(state) like 'a%' and lower(state) like '%m'


-- Total number of Males and Females (Using mathematics logic)

select d.state,sum(d.males) total_males,sum(d.females) total_females 
from (
      select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females
      from (
            select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population 
            from project..data1 a 
            inner join project..data2 b 
            on a.district=b.district ) c
      ) d
group by d.state;


-- Total number of literate people and total number of illiterate people (Using mathematics logic)

select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop 
from (
      select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people, round((1-d.literacy_ratio)* d.population,0) illiterate_people 
      from (
            select a.district,a.state,a.literacy/100 literacy_ratio,b.population 
            from project..data1 a
            inner join project..data2 b on a.district=b.district) d
     ) c
 group by c.state

 
-- Total population in previous census (Using mathematics logic)

select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population 
from(
     select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population
     from (
           select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population 
           from (
                 select a.district,a.state,a.growth growth,b.population
                 from project..data1 a 
                 inner join project..data2 b on a.district=b.district) d
          ) e
group by e.state) m

 
-- Top 3 districts from each state with highest literacy rate (Window function)

select a.* 
from (
      select district,state,literacy,rank() over(partition by state order by literacy desc) rnk 
      from project..data1) a
where a.rnk in (1,2,3) 
order by state
