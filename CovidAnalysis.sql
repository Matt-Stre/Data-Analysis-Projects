SELECT *
FROM	CovidProject1.dbo.CovidDeaths
ORDER BY 1, 2

--United States Death Percentage
SELECT location, Date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS DeathsPercentage
FROM	CovidProject1.dbo.CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2

--Total Cases vs Population
SELECT location, Date, population, total_cases, total_deaths, (total_cases/population)*100 AS InfectedPercentage
FROM	CovidProject1.dbo.CovidDeaths
--WHERE location = 'United States'
ORDER BY 1, 2

-- Countries with the highest % of people who have had Covid
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS InfectedPercentage
FROM	CovidProject1.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY InfectedPercentage Desc

--Countries with the Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM	CovidProject1.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount Desc


--CONTINENT NUMBERS

--Deaths by Continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM	CovidProject1.dbo.CovidDeaths
WHERE continent is null 
	AND location != 'High income'
	AND location != 'Upper middle income'
	AND location != 'Lower middle income'
	AND location != 'Low income'
GROUP BY location
ORDER BY TotalDeathCount Desc


--Continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM	CovidProject1.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc


--GLOBAL NUMBERS

--Global daily cases, deaths and percentage of deaths
SELECT  date, SUM(new_cases) as CaseCount, SUM(cast(new_deaths as int)) as DeathCount, (SUM(cast(New_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM	CovidProject1.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


--Merging Vaccination Data
--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) AS TotalVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER by 1,2,3

--Percentage of Global Populations Vaccinated
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) AS TotalVaccinated
FROM CovidProject1.dbo.CovidDeaths dea
JOIN CovidProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (TotalVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac


--View for Tableau

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) AS TotalVaccinated
FROM CovidProject1.dbo.CovidDeaths dea
JOIN CovidProject1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null