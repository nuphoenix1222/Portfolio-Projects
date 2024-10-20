select *
from Portfolio1..CovidDeaths$
where continent is not null
order by 3,4;

--select *
--from Portfolio1..CovidVaccinations$
--order by 3,4;

--Confirms data by calling everything


-- Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio1..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at total cases vs population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as Pop_Infected
from Portfolio1..CovidDeaths$
where location like '%states%'
order by 1,2;

-- what countries has highest infection rates compared to population

select location, population, max(total_cases) as HighestInfectedCount, max((total_cases/population))*100 as Percent_Pop_Infected
from Portfolio1..CovidDeaths$
group by location, population
order by 4 desc;

-- shows countries with highest death count/population

select location, max(cast(total_deaths as int)) as totaldeathcount
from Portfolio1..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc


-- by continent

--write out drill down (one for each continent for proper tableau views)

-- showing continent w/ highest death count per population

 select continent, max(cast(total_deaths as int)) as totaldeathcount
from Portfolio1..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	Sum(cast(new_deaths as int))/Sum(new_cases)*100 as  GlobalDeathPercentage
from Portfolio1..CovidDeaths$
where continent is not null
-- group by date
order by 1,2


select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	Sum(cast(new_deaths as int))/Sum(new_cases)*100 as  GlobalDeathPercentage
from Portfolio1..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- summing new case will equal the total cases



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	as rolling_ppl_vac
from Portfolio1..CovidDeaths$ dea
join Portfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- use CTE

with popvsvac (continent, location, date, population, new_vaccinations, rolling_ppl_vac)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	as rolling_ppl_vac
from Portfolio1..CovidDeaths$ dea
join Portfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_ppl_vac/population)*100
from popvsvac


-- temp table
drop table if exists #percent_pop_vac
create table #percent_pop_vac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccionations numeric,
rolling_ppl_vac numeric)


insert into #percent_pop_vac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	as rolling_ppl_vac
from Portfolio1..CovidDeaths$ dea
join Portfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (rolling_ppl_vac/population)*100
from #percent_pop_vac



--create view to store data for later visualization
drop view percent_pop_vac;

create view percent_pop_vac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	as rolling_ppl_vac
from Portfolio1..CovidDeaths$ dea
join Portfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *
from percent_pop_vac;