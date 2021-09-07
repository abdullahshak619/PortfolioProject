select*
from portfolioproject..coviddeaths
where continent is not null
order by 3,4



--select*
--from portfolioproject..covidvaccination
--order by 3,4

--total cases vs total death
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
from portfolioproject..coviddeaths
where continent is not null
order by 1,2

--total cases vs total polpulation in india
select location,date,total_cases,population, (total_cases/population)*100 as casePrecentage
from portfolioproject..coviddeaths
where location like '%india%'
and continent is not null
order by 1,2

--Country with highest cases according to Population
select location,max(total_cases) as total_cases,population, max((total_cases/population))*100 as casePrecentage
from portfolioproject..coviddeaths
where continent is not null
group by location,population
order by casePrecentage desc

--Country with highest death according to population
select location,max(cast(total_deaths as int)) as total_deaths,population, max((total_deaths/population))*100 as deathPrecentage
from portfolioproject..coviddeaths
where continent is not null
group by location,population
order by total_deaths desc

--Continent with highest Deaths
select continent,max(cast(total_deaths as int)) as total_deaths, max((total_deaths/population))*100 as deathPrecentage
from portfolioproject..coviddeaths
where continent is not null
group by continent
order by total_deaths desc

--Total numbers by date
select date,sum(total_cases) as total_cases, sum(cast(total_deaths as int)) as total_death, sum(cast(total_deaths as int))/sum(total_cases) as Deathpercentage
from portfolioproject..coviddeaths
where continent is not null
group by date
order by date--order by 1,2

--total number by date(another method)
select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases) as Deathpercentage
from portfolioproject..coviddeaths
where continent is not null
group by date
order by date--order by 1,2


--Joining both the tables
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 2,3

--Using partition by to get total number of vaccination of a country
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location)
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 2,3


--Using partition by to get rolling total number of vaccination of a country(method-2)
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingvac
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 2,3

--Using CTE(or you can us temp table) to use rollingvac number to know vaccinationpercentage
WITH vaccinper (continent,location,date,population,new_vaccinations,rollingvac)
as
(
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingvac
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
--order by 2,3(cant be in subqueries ,common table)
)
 select * ,(rollingvac/population)*100
 from vaccinper
 ORDER BY 2,3


 --Using TEMP table
 DROP TABLE if exists percentagevaccinated
 CREATE TABLE percentagevaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population float,
 new_vaccinations int,
 rollingvac int
 )
INSERT INTO percentagevaccinated
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingvac
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
--order by 2,3(cant be in subqueries ,common table)
select * ,(rollingvac/population)*100
 from percentagevaccinated
 ORDER BY 2,3



 --View in Data Visualization
 CREATE VIEW pervaccinated 
 as
 select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingvac
from portfolioproject..coviddeaths as dea
join portfolioproject..covidvaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
--ORDER BY 2,3

select *
from pervaccinated








