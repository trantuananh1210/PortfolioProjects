--ALTER TABLE CovidProject.dbo.CovidDeaths
--DROP COLUMN column1;
--> Drop column name "column1"

select *
from CovidProject.dbo.CovidDeaths
ORDER by 3,4

select *
from CovidProject.dbo.CovidDeaths
where continent is not NULL
ORDER by 3,4

select *
from CovidProject.dbo.CovidVaccinations
where continent is not NULL
ORDER by 3,4

-- Select Data that we are going to be using
select [location], [date], total_cases, new_cases, total_deaths, population
from CovidProject.dbo.CovidDeaths
where continent is not NULL
ORDER by 1,2

-- Looking at Total Cases and Total Deaths
select [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject.dbo.CovidDeaths
where continent is not NULL
ORDER by 1,2

-- Show likelihood of dying if you contract covid in your country
select [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject.dbo.CovidDeaths
where [location] like '%State%'
and continent is not NULL
ORDER by 1,2

-- Looking at Total Cases and Population
-- Show what percentage of population got Covid
select [location], [date], total_cases, population, (total_cases/population)*100 as DeathPercentage
from CovidProject.dbo.CovidDeaths
where [location] like '%State%'
and continent is not NULL
ORDER by 1,2
-- Select all location
select [location], [date], total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidProject.dbo.CovidDeaths
where continent is not NULL
ORDER by 1,2

-- Looking at Countries with Highest Infection Rate compared to population
select [location], population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidProject.dbo.CovidDeaths
where continent is not NULL
GROUP by [location], population
ORDER by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
select [location], MAX(total_deaths) as TotalDeathCount
from CovidProject.dbo.CovidDeaths
where continent is not NULL
GROUP by [location]
ORDER by TotalDeathCount desc
--> Convert Total Death to int
select [location], MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidProject.dbo.CovidDeaths
where continent is not NULL
GROUP by [location]
ORDER by TotalDeathCount desc

-- LET BREAK THINGS DOWN BY CONTINENT
select [continent], MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidProject.dbo.CovidDeaths
where continent is not NULL
GROUP by [continent]
ORDER by TotalDeathCount desc
-- Try again
select [location], MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidProject.dbo.CovidDeaths
where continent is NULL
GROUP by [location]
ORDER by TotalDeathCount desc

--  GLOBAL NUMBERS
select date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, 100*(sum(new_deaths)/SUM(new_cases)) as DeathPercentage
from CovidProject.dbo.CovidDeaths
where continent is not NULL
group by [date]
ORDER by [date]


-- Looking at total Population vs Vaccinations
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
FROM CovidProject.dbo.CovidDeaths as dea
JOIN CovidProject.dbo.CovidVaccinations as vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.continent is not NULL
ORDER by 2,3

SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
sum(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION by dea.[location] ORDER by dea.[location],dea.[date]) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths as dea
JOIN CovidProject.dbo.CovidVaccinations as vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.continent is not NULL
ORDER by 2,3

-- Use CTE
WITH PopvsVac (continent, LOCATION, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
sum(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION by dea.[location] ORDER by dea.[location],dea.[date]) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths as dea
JOIN CovidProject.dbo.CovidVaccinations as vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
FROM PopvsVac

-- TEMP TABLE
DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.[location] ORDER by dea.[location],dea.[date]) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths as dea
JOIN CovidProject.dbo.CovidVaccinations as vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date]

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.[location] ORDER by dea.[location],dea.[date]) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths as dea
JOIN CovidProject.dbo.CovidVaccinations as vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date]
where dea.continent is not NULL