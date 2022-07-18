SELECT *
From PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

SELECT *
From PortfolioProject..CovidVaccinations
order by 3,4

Select Location , date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2
--Looking at Total Cases vs Total Deaths 
Select Location , date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2
--Total cases vs Population 
Select Location , date, total_cases, population, (total_cases/population)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with the highest infection rate vs population 
Select Location , MAX(total_cases) as HighestInfectionCount , population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc 


--Showing Countries with Highest Death Count Per Population 
Select Location , MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is not null 
Group by location
order by TotalDeathCount desc
 
 -- Let's break things down by contient 

 Select continent , MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population 
 Select continent , MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc



--Global Numbers
Select SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


--Total Population vs Vaccinations

Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinted,-- (RollingPeopleVaccinted/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE 
With popvsVac (Continet , Location , Date , Population , New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinted-- (RollingPeopleVaccinted/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac








--TEMP Table 

DROP Table if exists #PerecentPopulationVaccinated
Create Table #PerecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PerecentPopulationVaccinated 
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinted-- (RollingPeopleVaccinted/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PerecentPopulationVaccinated



--Creating view to store data for later viz.

Create View PerecentPopulationVaccinated as 
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinted-- (RollingPeopleVaccinted/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PerecentPopulationVaccinated
