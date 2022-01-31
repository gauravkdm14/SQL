select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;


/*select *
from [CovidVaccination']
order by 3,4;*/

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2;

-- looking at total cases vs total deaths 
-- Shows the likelihood of dying in the country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location = 'india' and continent is not null
order by 1, 2;


-- looking at the total cases vs Population
-- shows the total number of pupulation got covid

select location, date, total_cases, population, (total_cases/population)*100 as population_percentage
from PortfolioProject..CovidDeaths
where location = 'india' and continent is not null
order by 1, 2;

--looking at the countries with the highest infection rates

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentage_of_infection
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by percentage_of_infection desc;

--looking at the countries with the highest death counts per population
--using cast() to change the data type from character to integer

select location, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by highest_death_count desc;

--let's break things down on the continent bases
--showing the continent with highest death counts

select continent, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is null
group by continent
order by highest_death_count desc;


--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2;

--looking at total population vs vaccination
--used bigint because of the arithmetic overflow 
--partition is useful when we have to perform a calculation on individual rows of a group using other rows of that group.

select da.continent, da.location, da.date, da.population, vc.new_vaccinations,
sum(convert(bigint,vc.new_vaccinations)) over (partition by da.location order by da.location, da.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
from PortfolioProject..[CovidDeaths] da
join PortfolioProject..[CovidVaccination'] vc
on da.location = vc.location
and da.date = vc.date
where da.continent is not null
order by 2, 3

--use cte

with popvsvac(continent, location, date, population, new_vaccination, rolling_people_vaccinated)
as
(
select da.continent, da.location, da.date, da.population, vc.new_vaccinations,
sum(convert(bigint,vc.new_vaccinations)) over (partition by da.location order by da.location, da.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
from PortfolioProject..[CovidDeaths] da
join PortfolioProject..[CovidVaccination'] vc
on da.location = vc.location
and da.date = vc.date
where da.continent is not null
--order by 2, 3
)
select * ,(rolling_people_vaccinated/population)*100
from popvsvac

--tem table
--using drop table if exists for any alterations
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
insert into #percentagepopulationvaccinated
select da.continent, da.location, da.date, da.population, vc.new_vaccinations,
sum(convert(bigint,vc.new_vaccinations)) over (partition by da.location order by da.location, da.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
from PortfolioProject..[CovidDeaths] da
join PortfolioProject..[CovidVaccination'] vc
on da.location = vc.location
and da.date = vc.date
--where da.continent is not null
--order by 2, 3

select * ,(rolling_people_vaccinated/population)*100
from #percentagepopulationvaccinated



--createing view to store data for later visulations 

create view percentagepopulationvaccinated as
select da.continent, da.location, da.date, da.population, vc.new_vaccinations,
sum(convert(bigint,vc.new_vaccinations)) over (partition by da.location order by da.location, da.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
from PortfolioProject..[CovidDeaths] da
join PortfolioProject..[CovidVaccination'] vc
on da.location = vc.location
and da.date = vc.date
where da.continent is not null
--order by 2, 3

select *
from percentagepopulationvaccinated;