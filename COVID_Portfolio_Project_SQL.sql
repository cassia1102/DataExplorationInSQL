--Select * 
--From project.dbo.CovidDeath
--Where continent is not null
--order by 3, 4

--Select * 
--From project.dbo.CovidVaccinations
--Where continent is not null
--order by 3, 4


-- Select Data that we are going to be using

--Select Location, date, total_cases, new_cases, total_deaths, population
--Where continent is not null
--From project.dbo.CovidDeath
--order by 1, 2

-- Looking at Total Cases vs Total Deaths

--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--Where continent is not null
--From project.dbo.CovidDeath
--order by 1, 2


-- Looking at Total Cases vs Total Deaths in the United States
-- Shows likelihood of dying if one contract covid in United States


--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From project.dbo.CovidDeath
--Where location like '%states%'
--order by 1, 2


-- Looking at Total Cases vs Population in the United States
-- Shows likelihood of being infected by Covid in the United States


--Select Location, date, total_cases, population, (total_cases/population)*100 as InfectPercentage
--From project.dbo.CovidDeath
--Where location like '%states%'
----and continent is not null
--order by 1, 2


--Looking at Countries with Highest Infection Rate Compared to Population

--Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
--From project..CovidDeath
--Where continent is not null
--Group by Location, Population
--order by 1, 2


----Looking at Countries with Highest Death Count per Population
--Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
--From project..CovidDeath
--Where continent is not null
--Group by Location
--order by TotalDeathCount desc

--Looking at continent with Highest Death Count per Population
--Select location, Max(cast(total_deaths as int)) as TotalDeathCount
--From project..CovidDeath
--Where continent is null
--Group by location
--order by TotalDeathCount desc


-- Global numbers per day

--Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as InfectPercentage
--From project.dbo.CovidDeath
----Where location like '%states%'
--where continent is not null
--Group by date
--order by 1, 2

--Total Global numbers

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as InfectPercentage
--From project.dbo.CovidDeath
----Where location like '%states%'
--where continent is not null
----Group by date
--order by 1, 2

--Looking at Total population vs vaccinations


--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--From project.dbo.CovidDeath dea
--Join project.dbo.CovidVaccinations vac
--    On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From project..CovidDeath dea
--Join project..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..CovidDeath dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

--DROP Table if exists #PercentPopulationVaccinated
--Create Table #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--Insert into #PercentPopulationVaccinated
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From project..CovidDeath dea
--Join project..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
----where dea.continent is not null 
----order by 2,3

--Select *, (RollingPeopleVaccinated/Population)*100
--From #PercentPopulationVaccinated


--Creating view to store data for future visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project..CovidDeath dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

