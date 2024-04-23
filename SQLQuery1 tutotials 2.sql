select *
From PortfolioProject..CovidDeaths
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country 
select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%ghana%'
order by 1,2

--Looking at Total Cases vs Population 
Shows what percentage of population has covid
select Location, date, total_cases, population,(total_cases/population)*100 PopulationPercentage
from PortfolioProject..CovidDeaths
where location like '%ghana%'
order by 1,2


--Looking at countries with highest infection rate compared to population 
--Shows what percentage of population has covid

select Location,population, Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%ghana%'
Group by Location, population
order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per Population

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%ghana%'
where continent is not null	
Group by Location
order by TotalDeathCount desc

--Let's break things down by continent
--showing continents with the highest death count per population	
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%ghana%'
where continent is not null	
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS 
select  Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/Sum(new_cases) *100 DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%ghana%'
where continent is not null	
--Group by date
order by 1,2



select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.Location, dea. date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null	
order by 2,3


--USE CTE 

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated )
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.Location, dea. date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null	
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE 
Drop Table If exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.Location, dea. date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null	
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating view to store data for later visualization

Create View PercentagePopulationVaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.Location, dea. date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null	
--order by 2,3

select *
From PercentagePopulationVaccinated