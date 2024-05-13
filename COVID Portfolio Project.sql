SELECT * 
FROM [Portfolio Proyect 1]..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM [Portfolio Proyect 1]..CovidVaccinations
--ORDER BY 3,4

-- Select Data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [Portfolio Proyect 1]..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in Mexico
SELECT 
location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM [Portfolio Proyect 1]..CovidDeaths
WHERE location like 'Mexico'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what porcentage of population got covid

SELECT 
location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as PercentagePopulationInfected
FROM [Portfolio Proyect 1]..CovidDeaths
--WHERE location like 'Mexico'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT
location, population, MAX(total_cases) as HighestInfectionCount, 
MAX(CAST(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
FROM [Portfolio Proyect 1]..CovidDeaths
--WHERE location like 'Mexico'
group by location,population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT
location, max(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Proyect 1]..CovidDeaths
--WHERE location like 'Mexico'
where continent is not null
group by location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, max(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Proyect 1]..CovidDeaths
--WHERE location like 'Mexico'
where continent is not null
group by continent
ORDER BY TotalDeathCount desc


-- Showing the continents with the highest death count per population

SELECT continent, max(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Proyect 1]..CovidDeaths
--WHERE location like 'Mexico'
where continent is not null
group by continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Proyect 1]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Looking at Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Proyect 1]..CovidDeaths dea
Join [Portfolio Proyect 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- TEMPT TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM [Portfolio Proyect 1]..CovidDeaths dea
JOIN [Portfolio Proyect 1]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;


SELECT *,
    (CAST(RollingPeopleVaccinated AS FLOAT) / Population) * 100 AS PercentVaccinated
FROM #PercentPopulationVaccinated;


-- Drop the existing view if it already exists
IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;

-- Create the new view
CREATE view dbo.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM [Portfolio Proyect 1]..CovidDeaths dea
JOIN [Portfolio Proyect 1]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


