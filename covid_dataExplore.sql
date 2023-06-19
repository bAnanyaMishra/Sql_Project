
--select * from dbo.CovidVaccinations order by 3,4;

--select * from portfolio_project.dbo.CovidDeaths where continent is not null order by 3,4 ;

--selecting specific columns 
select location,date,total_cases,new_cases,total_deaths,population
from portfolio_project.dbo.CovidDeaths where continent is not null order by 1,2;

--total cases vs total deaths
 
select location,date,total_cases,total_deaths,convert(decimal(10,4),(total_deaths/total_cases)*100) as death_percentage
from portfolio_project.dbo.CovidDeaths where location like '%india%' and continent is not null order by 1,2 ;

-- total cases vs population 

select location,date,total_cases,population,convert(decimal(10,4),(total_cases/population)*100) as case_percentage
from portfolio_project.dbo.CovidDeaths where location like '%india%' and continent is not null order by 1,2 ;

--highest infection rates


select location,max(total_cases) as max_infection_count,population,convert(decimal(10,4),max((total_cases/population))*100) as percent_infected
from portfolio_project.dbo.CovidDeaths where continent is not null group by location,population order by percent_infected desc  ;

-- highest death count

select location,max(cast(total_deaths as int)) as max_death_count,convert(decimal(10,4),max((total_deaths/population))*100) as percent_death
from portfolio_project.dbo.CovidDeaths where continent is not null group by location order by max_death_count desc;

--highest death count by continet
select continent,max(cast(total_deaths as int)) as max_death_count,convert(decimal(10,4),max((total_deaths/population))*100) as percent_death
from portfolio_project.dbo.CovidDeaths where continent is not null group by continent order by max_death_count desc

--

select * from portfolio_project.dbo.CovidDeaths where continent is null order by 3,4

--
select location,max(cast(total_deaths as int)) as max_death_count,convert(decimal(10,4),max((total_deaths/population))*100) as percent_death
from portfolio_project.dbo.CovidDeaths where continent is null group by location order by max_death_count desc;


-- global numbers each day
 
select location,date,total_cases,total_deaths,convert(decimal(10,4),(total_deaths/total_cases)*100) as death_percentage
from portfolio_project.dbo.CovidDeaths where continent is not null order by 1,2;

-- global numbers
select date, sum(new_cases) as new_cases , sum(cast(new_deaths as int)) as new_deaths, convert(decimal(10,4),sum(cast(new_deaths as int))/sum(new_cases)*100) as death_percentage
from portfolio_project.dbo.CovidDeaths where continent is not null group by date order by 1,2;

-- total death,cases, death%
select  sum(new_cases) as new_cases , sum(cast(new_deaths as int)) as new_deaths, convert(decimal(10,4),sum(cast(new_deaths as int))/sum(new_cases)*100) as death_percentage
from portfolio_project.dbo.CovidDeaths where continent is not null  order by 1,2;

-- covid vaccinations and covid deaths (bad query)

select * 
from portfolio_project.dbo.CovidVaccinations cv
join portfolio_project.dbo.CovidDeaths cd
on cv.location=cd.location;

-- total population vs vaccination

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as vaccinated_rolling
from portfolio_project.dbo.CovidVaccinations cv
join portfolio_project.dbo.CovidDeaths cd
on cv.location=cd.location
and	cv.date = cd.date
where cd.continent is not null 
order by 2,3;

-- CTE to show how many people got vaccinated by every location

with total_vaccinated (continent,location,date,population,new_vaccinations,vaccinated_rolling)as(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as vaccinated_rolling
from portfolio_project.dbo.CovidVaccinations cv
join portfolio_project.dbo.CovidDeaths cd
on cv.location=cd.location
and	cv.date = cd.date
where cd.continent is not null 
)
select location,max(convert(decimal(10,4),(vaccinated_rolling/population)*100))
from total_vaccinated group by location;


-- for india
with total_vaccinated (continent,location,date,population,new_vaccinations,vaccinated_rolling)as(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as vaccinated_rolling
from portfolio_project.dbo.CovidVaccinations cv
join portfolio_project.dbo.CovidDeaths cd
on cv.location=cd.location
and	cv.date = cd.date
where cd.continent is not null 
)
select location,max(convert(decimal(10,4),(vaccinated_rolling/population)*100))
from total_vaccinated where location like 'india' group by location;

-- temp table usage 
drop table if exists #people_vaccinated
create table #people_vaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations int,
vaccinated_rolling int)

insert into #people_vaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as vaccinated_rolling
from portfolio_project.dbo.CovidVaccinations cv
join portfolio_project.dbo.CovidDeaths cd
on cv.location=cd.location
and	cv.date = cd.date
where cd.continent is not null 

select location,max(convert(decimal(10,4),(vaccinated_rolling/population)*100))
from #people_vaccinated where location like 'india' group by location;

--temp table 
drop table if exists #global_vaccinated
create table #global_vaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations int,
vaccinated_rolling int
)
insert into #global_vaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as vaccinated_rolling
from portfolio_project.dbo.CovidVaccinations cv
join portfolio_project.dbo.CovidDeaths cd
on cv.location=cd.location
and	cv.date = cd.date
where cd.continent is not null 
select location,max(convert(decimal(10,4),(vaccinated_rolling/population)*100))
from #global_vaccinated group by location;

--view for %vaccinated

create view percent_vaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as vaccinated_rolling
from portfolio_project.dbo.CovidVaccinations cv
join portfolio_project.dbo.CovidDeaths cd
on cv.location=cd.location
and	cv.date = cd.date
where cd.continent is not null 

select * from percent_vaccinated;