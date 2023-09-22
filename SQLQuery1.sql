SELECT *
FROM [Portfolio Project]..CovidDeaths
ORDER BY 3,4

SELECT *
FROM [Portfolio Project]..CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in INDIA from 2020 - 2021

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%INDIA%'
and continent is not null 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%INDIA%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--Where location like '%INDIA%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
From [Portfolio Project]..CovidDeaths
--WHERE location like '%INDIA%'
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is  null 
GROUP BY location
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
wHERE dea.continent is not null 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
wHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopuVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

CREATE VIEW TotalDeaths AS

SELECT location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is  null 
GROUP BY location
--ORDER BY TotalDeathCount desc