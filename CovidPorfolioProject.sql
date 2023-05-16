select *
from PorfolioProject..CovidDeaths
order by 3,4

--select *
--from PorfolioProject..CovidVaccinations
--order by 3,4

--Data Using
select location,date,total_cases,new_cases,total_deaths, population
from PorfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2
--Total Cases vs Total Deaths
SELECT
  location,
  date,
  total_deaths,
  total_cases,
  CAST(total_deaths AS float) / CAST(total_cases AS float)*100 AS DeathPercentage
FROM
  PorfolioProject..CovidDeaths
where location like '%states'
and continent is not null
ORDER BY
  location,
  date
  --Total Cases vs Population, percentage got Covid
  SELECT
 location,
  date,
  population,
  total_cases,
  CAST(total_cases AS float)/ CAST(population AS float)*100 AS PercentagePopulationInfected
FROM
  PorfolioProject..CovidDeaths
--where location like '%states'
Where continent is not NULL
ORDER BY
  location,
  date 
  --Countries with highest infections rate compared to population
    SELECT
 location,
  population,
  MAX(total_cases) AS HighestInfectionCount,
  MAX((CAST(total_cases AS float)/ CAST(population AS float))*100) AS PercentagePopulationInfected
FROM
  PorfolioProject..CovidDeaths
--where location like '%states'
Group By population, location
ORDER BY PercentagePopulationInfected desc

--Countries with highest death count per Population
    SELECT
 location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
  FROM
  PorfolioProject..CovidDeaths
Where continent is not NULL
Group by location
ORDER BY TotalDeathCount desc

--Breakdown by continents 
--Continents with the highest death counts
  SELECT
 continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
  FROM
  PorfolioProject..CovidDeaths
Where continent is not NULL
Group by continent
ORDER BY TotalDeathCount desc

--Global numbers
--Total Cases vs Total Deaths of world
SELECT
date,
  SUM(new_cases) as TotalCases,
  SUM(new_deaths) as TotalDeaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE SUM(new_deaths)/(SUM(new_cases)*100)
  END as DeathPercentage
FROM
  PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3

--USE CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopVsVac

--Total World DeathPercentage

SELECT
  SUM(new_cases) as TotalCases,
  SUM(new_deaths) as TotalDeaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE SUM(new_deaths)/(SUM(new_cases)*100)
  END as DeathPercentage
FROM
  PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

--Create View to store data visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

Select *
From PercentPopulationVaccinated





