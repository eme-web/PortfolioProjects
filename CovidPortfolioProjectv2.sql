SELECT *
FROM PortfolioProject ..CovidDeaths$
order by 3,4


--SELECT *
--FROM PortfolioProject ..CovidVaccinations$
--order by 3,4

SELECT location,date, total_cases,new_cases, total_deaths,population
FROM PortfolioProject ..CovidDeaths$
order by 1,2

-- Total Cases Vs Total Deaths
--shows the likelihood of dying if you contract covid in your country.
SELECT location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject ..CovidDeaths$
WHERE location LIKE '%ca%'
order by 1,2

--Total cases Vs Population
--shows what percentage of population got covid

SELECT location,date,population, total_cases, (total_deaths/population)*100 as PercentagePopulationinfected
FROM PortfolioProject ..CovidDeaths$
WHERE location LIKE '%ca%'
order by 1,2

--Countries with Highest Infection Rate Compared to Population

SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationinfected
FROM PortfolioProject ..CovidDeaths$
--WHERE location LIKE '%ca%'
Group by location,population
order by PercentagePopulationinfected desc

--showing countries with Highest Deaths count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject ..CovidDeaths$
--WHERE location LIKE '%ca%'
WHERE continent IS NOT NULL
Group by location
order by TotalDeathCount desc

--BREAKING DOWN BY CONTINENT

--showwing continents with the highest deaths count per population


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject ..CovidDeaths$
--WHERE location LIKE '%ca%'
WHERE continent IS NOT NULL
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject ..CovidDeaths$
--WHERE location LIKE '%ca%'
WHERE continent IS NOT NULL
Group by date
order by 1,2


SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject ..CovidDeaths$
--WHERE location LIKE '%ca%'
WHERE continent IS NOT NULL
--Group by date
order by 1,2


--Total Population Vs Vacinations

SELECT dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject ..CovidDeaths$ dea
JOIN PortfolioProject ..CovidVaccinations$ vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3

--Use CTE

with PopvsVac (continent, location,date,population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject ..CovidDeaths$ dea
JOIN PortfolioProject ..CovidVaccinations$ vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp Table

DROP Table if exists #PercentagePopulationVaccinated
CREATE TABLE  #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date  datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject ..CovidDeaths$ dea
JOIN PortfolioProject ..CovidVaccinations$ vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT * ,(RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated


--Creating views to store data for later visualizations

CREATE view PercentagePopulationVaccinated as
SELECT dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject ..CovidDeaths$ dea
JOIN PortfolioProject ..CovidVaccinations$ vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT *
FROM PercentagePopulationVaccinated






