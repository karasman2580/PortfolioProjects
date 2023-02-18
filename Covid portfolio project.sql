-- selecting all columns from the table "CovidDeaths" and ordering the result set by columns 3 and 4.

Select *
From PortfolioProject..CovidDeaths$
Order by 3,4

--selecting all columns from the table "CovidVaccinations" and ordering the result set by columns 3 and 4.

Select *
From PortfolioProject..CovidVaccinations$
Order by 3,4


-- selecting specific columns from the "CovidDeaths" table and ordering the result set by location and date; providing information on the total cases, new cases, total deaths, and population for each location

Select Location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2


--locations that contain "eny" in their name, and calculates the death percentage by dividing total deaths by total cases
--Shows the likelyhood of succumbing to covid incase you contyared the virus in kenya

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths$
Where location like '%eny%'
Order by 1,2

--looking at the Total cases vs the population

Select Location,date,total_cases,population,(total_cases/population)*100 as Casepercentage
From PortfolioProject..CovidDeaths$
Where location like '%eny%'
Order by 1,2

--looking at the countries with highest infection rate compare to population

Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as percentPopulationInfected
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location,population
Order by percentPopulationInfected desc


--Continents with Highest Death Count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
Order by TotalDeathCount desc

--Continent with Highest Death Count per Population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Countries with Highest Death Count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location
Order by TotalDeathCount desc 


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
Order by 1,2

--select covid vaccinations data set

Select *
From PortfolioProject..CovidVaccinations$

--Looking at Total population vs Vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) 
  OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) 
  OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



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

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) 
  OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) 
  OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

SELECT * FROM percentPopulationVaccinated;