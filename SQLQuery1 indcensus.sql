select * from dbo.data1
select * from dbo.data2

--- number of rows in the datasets
select count(*) from indcensus..data1
select count(*) from indcensus..data2

---Records for jharkhand and bihar
select * from data1
where State in ('Jharkhand' ,'Bihar')

---total population in india
select sum(Population) as India_population from data2

---avg Growth of population by state in india
select State,AVG(growth)*100 as avg_groth from data1 group by State

---average sex ratio 
select State,round(AVG(Sex_Ratio),0) as avg_sex_ratio from data1 group by State order by State desc

---average literacy rate
select State,round(AVG(Literacy),0) as avg_literacy_ratio from data1 
group by State
having AVG(Literacy) > 90

---top 3 states in growth rate
select top 3 State,round(AVG(growth)*100,1) as avg_growth from data1 group by State order by avg_growth desc

---bottom 3 states in growth rate
select top 3 State,round(AVG(growth)*100,1) as avg_growth from data1 group by State order by avg_growth 

---top and bottom 3 states in literacy rates
drop table if exists #topstates
create table #topstates
(
state nvarchar(255),
topstates float
)

insert into #topstates
select top 3 State,round(AVG(Literacy),1) as avg_literacy from data1 group by State order by avg_literacy desc

create table #bottomstates
(
state nvarchar(255),
bottomstates float
)

insert into #bottomstates
select top 3 State,round(AVG(Literacy),1) as avg_literacy from data1 group by State order by avg_literacy

---union operator
select * from (select top 3 * from #topstates order by #topstates.topstates desc) a
union 
select * from (select top 3 * from #bottomstates order by #bottomstates.bottomstates desc) b

---states names starting with a or b
select distinct(state) from data1 where state like 'a%'or state like 'b%'
select distinct(state) from data1 where state like '__a%'or state like '%d'

---total males and female
select d.district,sum(d.males) as total_male,sum(females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males,round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.State,a.sex_ratio/1000 as sex_ratio,b.population from indcensus..data1 a
join indcensus..data2 b on a.district = b.district)c)d
group by d.district

---total literacy rate

select c.state,sum(c.literate_people) literate_people,sum(c.illeterate_people) as illeterate_people from
(select d.District,d.State,round(d.literacy_ratio*d.population,0) literate_people,round((1-d.literacy_ratio)*d.population,0) illeterate_people from
(select a.District,a.State,a.Literacy/1000 literacy_ratio,b.population from data1 a
join data2 b on a.District=b.District)d)c
group by c.State

---population by previous census vs current census

select sum( m.prevv_population) as prevv_population,sum(m.crnt_population) as crnt_population from
(select e.state,sum( e.prevv_population) as prevv_population,sum(e.crnt_population) as crnt_population from
(select d.district,d.state,round(d.population/(1+d.growth),0)as prevv_population,d.population as crnt_population from  
(select a.district,a.state,a.growth,b.population from data1 a join data2 b on a.District=b.District)d)e
group by e.state)m

---top 3 states in literacy
select r.* from 
(select district,state,Literacy,
rank() over(partition by state order by Literacy desc) as rnk
from indcensus..data1)r
where r.rnk in(1,2,3) order by state

