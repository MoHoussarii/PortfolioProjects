SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not Null
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data that im going to be using
-- Shows the likelihood of dying if you contract covid in country
SELECT Location, date, total_cases, New_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not Null
Order by 1,2

-- Looking at total cases versus total deaths
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths

Where location like '%states%'
Order by 1,2


-- looking at the total cases versus the population
SELECT location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'

Order By 1,2

--Looking at countries with highest infection rates compared to population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
Where continent is not Null
--Where location like '%states%'
Group By location, population
Order By PercentagePopulationInfected desc

-- looking at countries with the highest death count per pop
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not Null
--Where location like '%states%'
Group By location, population
Order By TotalDeathCount desc

-- Showing continents with highest deathcounts
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not Null
--Where location like '%states%'
Group By continent
Order By TotalDeathCount desc

-- Global numbers
Select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int)),
SUM(CONVERT(float,new_deaths))/SUM(new_cases)*100
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
Order by 1,2


--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	On DEA.location = VAC.location
	and DEA.date = vac.date
where dea.continent is null
order by 2,3

--CTE to use RollngPeopleVacc
With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	On DEA.location = VAC.location
	and DEA.date = vac.date
where dea.continent is null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--Temp TABLE
DROP Table if exists #PrecentagePopulationVaccinated
CREATE TABLE #PrecentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PrecentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	On DEA.location = VAC.location
	and DEA.date = vac.date
where dea.continent is null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PrecentagePopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VIZ
CREATE VIEW PrecentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	On DEA.location = VAC.location
	and DEA.date = vac.date
where dea.continent is null
--order by 2,3

CREATE VIEW ContitnentMaxDeath as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not Null
--Where location like '%states%'
Group By continent
--Order By TotalDeathCount desc