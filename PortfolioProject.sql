select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- total cases vs total deaths
 
 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location = 'Philippines'
order by 1,2

--total cases vs population

 Select location, date, population, total_cases, (total_deaths/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Where location = 'Philippines'
order by 1,2


--country with highest infection 

 Select location, population, MAX(total_cases) as Highest_Infection , MAX((total_cases/population))*100 as InfectionPercentagePopulation
From PortfolioProject..CovidDeaths$
Group by location, population
order by InfectionPercentagePopulation desc

--country with highest death count per population
 Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

--per continent
 Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc


-- global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

---vaccine table

Select *
FROM PortfolioProject..CovidVaccinations$




Select *
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
         ON dea.location = vac.location
		 AND dea.date = vac.date

		 ---total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
         ON dea.location = vac.location
		 AND dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- -- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
         ON dea.location = vac.location
		 AND dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- using CTE

With PopvsVac (continent, location, date, population, new_vaccinatinos, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
         ON dea.location = vac.location
		 AND dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--  Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * 
From PercentPopulationVaccinated