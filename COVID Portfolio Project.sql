SELECT *
FROM [Porfolio Project]..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM [Porfolio Project]..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Porfolio Project]..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Totals Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Porfolio Project]..CovidDeaths
WHERE Location like '%states%'
AND continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_deaths/population)*100 AS DeathPercentage
FROM [Porfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
ORDER BY 1,2

--Looking at countries with highest inffection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM [Porfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From [Porfolio Project]..CovidDeaths
--Where location like'%states%'
WHERE continent is not NULL
Group by continent
order by TotalDeathCount desc

-- Showing countries with Highest Death Count per Population

Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From [Porfolio Project]..CovidDeaths
--Where location like'%states%'
WHERE continent is not NULL
Group by Location
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_deaths)*100 AS DeathPercentage
FROM [Porfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
--Group By date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    [Porfolio Project]..CovidDeaths dea
JOIN
    [Porfolio Project]..CovidVaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    2, 3;

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Porfolio Project]..CovidDeaths dea
Join [Porfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Porfolio Project]..CovidDeaths dea
Join [Porfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATE VIEW
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Porfolio Project]..CovidDeaths dea
Join [Porfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3

Select *
From PercentPopulationVaccinated


