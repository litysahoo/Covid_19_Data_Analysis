select*
from PortfolioProject..coviddeaths
where continent is not null
order by 3,4;

--select*
--from PortfolioProject..covidvaccinations
--order by 3,4;

--select data that we are going to be using

select location,date,total_cases,new_cases, total_deaths,population
from PortfolioProject..coviddeaths
order by 1,2;

--looking at total cases vs total deaths

ALTER TABLE coviddeaths
ALTER COLUMN total_deaths float;

select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
where location = 'India'
order by 1,2;

--looking at total cases vs total population

select location,date,total_cases,population,(total_cases/population)*100 as InfectionPercentage
from PortfolioProject..coviddeaths
where location = 'India'
order by 1,2;

--looking at maximum rate of covid cases as compared to population


select location,population, max(total_cases) as max_cases ,max((total_cases/population))*100 as maxInfectionPercentage
from PortfolioProject..coviddeaths
group by location,population
order by 4 desc;

--showing countries with highest death counts per population

select location,population, max(total_deaths) as max_deaths ,max((total_deaths/population))*100 as maxDeathPercentage
from PortfolioProject..coviddeaths
where continent is not null
group by location,population
order by 3 desc;

--LET'S BREAK THINGS UP BY CONTINENT

select location, max(total_deaths) as max_deaths 
from PortfolioProject..coviddeaths
where continent is null and location in (select distinct continent from PortfolioProject..coviddeaths)
group by location
order by 2 desc;

--GLOBAL NUMBERS

select date,sum(total_cases) as sum_total_cases, sum(total_deaths) as sum_total_deaths,(sum(total_deaths)/sum(total_cases))*100 as DeathPercentage
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2;

--total global cases combined

select sum(total_cases) as sum_total_cases, sum(total_deaths) as sum_total_deaths,(sum(total_deaths)/sum(total_cases))*100 as DeathPercentage
from PortfolioProject..coviddeaths
where continent is not null
--group by date
order by 1,2;

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination from 
PortfolioProject..covidvaccinations vac
join PortfolioProject..coviddeaths dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 2,3



--USING CTE(COMMON TABLE EXPRESSION)

with popvsvac(continent, location, date, population, new_vaccination, RollingPeopleVaccination)
as
(select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination from 
PortfolioProject..covidvaccinations vac
join PortfolioProject..coviddeaths dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
)

select *,(RollingPeopleVaccination/population)*100
from popvsvac



--TEMP TABLE
drop table if exists #percentPopulationVaccinated
Create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from 
PortfolioProject..covidvaccinations vac
join PortfolioProject..coviddeaths dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR FUTURE VISUALIZATION


create view percentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from 
PortfolioProject..covidvaccinations vac
join PortfolioProject..coviddeaths dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
