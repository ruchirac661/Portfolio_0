SELECT *
FROM Portfolio_1.dbo.Covid_deaths$
Order by 3,4

--SELECT *
--FROM Portfolio_1.dbo.Covid_vaccines$
--Order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population 
From Portfolio_1.dbo.Covid_deaths$
Order by 1,2

--Total cases vs total deaths metric 

--This field depicts the likelihood of dying from Covid, if contracted, in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
From Portfolio_1.dbo.Covid_deaths$
Where location = 'India'
Order by 1,2

--Looking at Total Cases vs Population

--Shows percentage of population that contracted Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentageInfected
From Portfolio_1.dbo.Covid_deaths$
Where location = 'India'
Order by 1,2

--Looking at Countries with highest infection rates

Select location, population, MAX(total_cases) as MaxInfectCount, MAX((total_cases/population)*100) as PercentageInfected
From Portfolio_1.dbo.Covid_deaths$
Group by location, population
Order by PercentageInfected DESC

--Showing Countries with highest death count

Select location, MAX(cast(total_deaths as int)) as Totaldeaths
From Portfolio_1.dbo.Covid_deaths$
Where continent is not null
Group by location
Order by Totaldeaths DESC


--Moving onto continents with corresponding death count

Select location, MAX(cast(total_deaths as int)) as Totaldeaths
From Portfolio_1.dbo.Covid_deaths$
Where continent is null
and location not like '%income%'
Group by location
Order by Totaldeaths DESC


--Global Numbers

Select SUM(new_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From Portfolio_1.dbo.Covid_deaths$
where continent is not null

--Global Numbers by date

Select date, SUM(new_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From Portfolio_1.dbo.Covid_deaths$
where continent is not null
--and location not like '%income%'
Group by date
Order by 1,2


Select *
From Portfolio_1..Covid_vaccines$

--Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations, 
SUM(Convert(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativeVaccinations
From Portfolio_1..Covid_deaths$ as Dea
Join Portfolio_1..Covid_vaccines$ as Vacc
	On Dea.location = Vacc.location
	and Dea.date = Vacc.date
Where Dea.continent is not null
Order by 2,3


--USING CTE

With PoplnvsVacc (Continent, Location, Date, Population, New_vaccinations, CummulativeVaccinations)
as
(Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations, 
SUM(Convert(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativeVaccinations
From Portfolio_1..Covid_deaths$ as Dea
Join Portfolio_1..Covid_vaccines$ as Vacc
	On Dea.location = Vacc.location
	and Dea.date = Vacc.date
Where Dea.continent is not null
--Order by 2,3
)
Select *, (CummulativeVaccinations/Population)*100 as PercentVaccinated
From PoplnvsVacc


--TEMP TABLE

Drop Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativeVaccinations numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations, 
SUM(Convert(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativeVaccinations
From Portfolio_1..Covid_deaths$ as Dea
Join Portfolio_1..Covid_vaccines$ as Vacc
	On Dea.location = Vacc.location
	and Dea.date = Vacc.date
Where Dea.continent is not null
Order by 2,3

Select *, (CummulativeVaccinations/Population)*100 as PercentVaccinated
From #PercentPeopleVaccinated


Create view PercentageVaccinated as
Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations, 
SUM(Convert(bigint, vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativeVaccinations
From Portfolio_1..Covid_deaths$ as Dea
Join Portfolio_1..Covid_vaccines$ as Vacc
	On Dea.location = Vacc.location
	and Dea.date = Vacc.date
Where Dea.continent is not null
