/*
	Data Exploration Using Covid 19 Dataset

	Using following Method/Function:- Joins, CTE, Temp Tables, Creating Views, Converting Data Types, Windows Functions, Aggregate Functions, 
*/


Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
where continent is not null
Order by 3,4




-- Looking at Total Case VS Total Death
-- This Show the likelihood of dying from covid if you caught it in your Country.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where location like 'Pakistan'
Order by 1,2



-- Looking at Total Cases Vs Population
-- Show %tage of the Population got covid

-- For Pakistan
Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where location like 'Pakistan'
Order by 1,2

-- For United States Of America
Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where location like '%states%'
Order by 1,2



-- Looking At Countries with highest Infection Rate Compared to Population

Select CD.location, population, 
	MAX(total_cases) As HighestInfectionCount, 
	MAX((total_cases/population))*100 as PercentagePopulationInfected 
From PortfolioProject..CovidDeaths CD
--Where location like '%states%'
where continent is null
Group by CD.location, population
Order by PercentagePopulationInfected desc



-- Looking At Countries with highest Death Count Per population
-- Total_Death is a big number so stores as varchar but max does not  count it 
-- so we changed it from varchar to int with 'cast'

Select CD.location, MAX(cast(total_deaths as int)) As HighestDeathCount
From PortfolioProject..CovidDeaths CD
--Where location like '%states%'
where continent is null 
Group by CD.location
Order by HighestDeathCount desc



-- Exploring Data By CONTINENT
-- Looking At data by continents with highest Death Count Per Population

Select continent, MAX(cast(total_deaths as int)) As HighestDeathCount
From PortfolioProject..CovidDeaths CD
--Where location like '%states%'
where continent is not null 
Group by continent
Order by HighestDeathCount desc

Select location, MAX(cast(total_deaths as int)) As HighestDeathCount
From PortfolioProject..CovidDeaths CD
--Where location like '%states%'
where continent is null 
Group by location
Order by HighestDeathCount desc



-- GLOBAL ANAYLSIS


-- Daily Total Number Of new Cases, New Deaths and Death Percentage

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage 
From PortfolioProject..CovidDeaths
--where location like 'Pakistan'
where continent is not Null and total_cases is not null and 
total_deaths is not null
group by date
Order by 1,2



-- Total World Numbers

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage 
From PortfolioProject..CovidDeaths
--where location like 'Pakistan'
where continent is not Null 
Order by 1,2



/* Vaccination */


-- New Vaccination Per day 

Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(convert(int,Vacc.new_vaccinations)) over (Partition by Death.Location Order by Death.location,
Death.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
	ON Death.location = Vacc.location 
	and Death.date = Vacc.date
where Death.continent is not null
Order by 2,3



-- Using CTE to Perform Calculations on 'Partition By' in Perivious Query

With PeopleVSVaccination (Continent, Location, 
Date, Population, New_Vaccinations, People_Vaccinated)
as 
(
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(convert(int,Vacc.new_vaccinations)) over (Partition by Death.location order by Death.location,
Death.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
	ON Death.location = Vacc.location 
	and Death.date = Vacc.date
where Death.continent is not null
--Order by 2,3

)
Select *, (PeopleVSVaccination.People_Vaccinated/PeopleVSVaccination.Population)*100
From PeopleVSVaccination
order by 2,3



-- Using Temp Tables to Perform Calculations on 'Partition By' in Perivious Query

-- Temp Table Creation
Drop Table IF EXISTS #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated 
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	PeopleVaccinated numeric
)

-- Inserting Data into Temp Table
Insert INTO #PercentPeopleVaccinated

Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(convert(int,Vacc.new_vaccinations)) over (Partition by Death.location order by Death.location,
Death.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
	ON Death.location = Vacc.location 
	and Death.date = Vacc.date
where Death.continent is not null
--Order by 2,3

-- Showing Temp Table Data 
Select *, (PeopleVaccinated/Population)*100
From #PercentPeopleVaccinated
order by 2,3



-- Creating View TO store data from later visualizations

Create View PercentPopulationVaccinated as

Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(convert(int,Vacc.new_vaccinations)) over (Partition by Death.location order by Death.location,
Death.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
	ON Death.location = Vacc.location 
	and Death.date = Vacc.date
where Death.continent is not null

Select * 
From PercentPopulationVaccinated
Order by 2,3
