
--select * 
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4
--ALTER TABLE PortfolioProject.dbo.CovidDeaths
--ALTER COLUMN total_cases nvarchar(255)
--ALTER TABLE PortfolioProject.dbo.CovidDeaths
--ALTER COLUMN total_deaths nvarchar(255)
select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

select Location, date, total_cases,new_cases, total_deaths, population 
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
select Location, date, total_cases, total_deaths,(CAST(total_deaths as FLOAT)) / (CAST(total_cases as FLOAT))*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE 'Africa'
WHERE continent is not null
order by 1,2

--Looking at Total Cases vs population
--Shows what percentage of population got covid
select Location, date,Population, total_cases, (CAST(total_cases as FLOAT)) / (population)*100 as PercentOfPopulationInfected 
from PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE 'Africa'
WHERE continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
select continent,Location,Population, MAX(total_cases) as HighestInfectionCount, (CAST(MAX(total_cases) as FLOAT)) / (population)*100 
as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE 'Africa'
WHERE continent is not null
GROUP BY location, population, continent
order by PercentPopulationInfected desc

--Showing countries with higesht death count per population
SELECT continent,location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, continent
ORDER BY TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 1,2

SELECT * FROM 
PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND
dea.date = vac.date


--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND
dea.date = vac.date
where dea.continent is not null
order by 2,3 


--USE CTE
With popvsvac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND
dea.date = vac.date
where dea.continent is not null
)
SELECT * ,(RollingPeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
FROM popvsvac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND
dea.date = vac.date
where dea.continent is not null

SELECT * ,(RollingPeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
USE PortfolioProject
CREATE VIEW
 PercentPopulationVaccinated as
 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON
dea.location = vac.location AND
dea.date = vac.date
where dea.continent is not null

select * 
from  PercentPopulationVaccinated
