
select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

-- Select Data that we are going to be using

--Select Location
--, date
--, total_cases
--, new_cases
--, total_deaths
--, population
--From PortfolioProject..CovidDeaths$
--order by 1,2

-- Looking at Total cases vs Total Deaths

select 
location 
, count(total_cases) as TotalCases
, count(total_deaths) as TotalDeaths
, count(total_deaths)/count(total_cases) as 'Mortality Rate %'
from CovidDeaths$
group by location
order by 'Mortality Rate %' desc 

-- Looking at the Total cases vs Population

select 
location 
, date
, total_cases
, population
, (total_cases/population)*100 as 'Infection Rate'
from CovidDeaths$
where location like '%kingdom%'
order by 'Infection Rate' desc

-- Countries with Highest Infection Rate

select 
location 
, Max(total_cases) as 'Highest Infection Count'
, population
, max((total_cases/population))*100 as 'Infection Rate'
from CovidDeaths$
where Population > 10000000
Group by Location, Population
order by 4 Desc

-- Showing the countries with the highest death rate

select 
location 
, max(cast(total_deaths as int)) as TotalDeaths
, population 
, max((cast(Total_Deaths as int)/population)*100) as 'Mortality Rate %'
from CovidDeaths$
where continent is not null
group by location, population
order by 2 desc

-- Showing the continents with the highest death rate

select 
continent 
, max(cast(total_deaths as int)) as TotalDeaths
 from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by 2 desc


-- Global Numbers

select 
date 
, sum(new_cases) as NewCases
, sum(cast(new_deaths as int)) as Deaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 as MortalityRate
from PortfolioProject..CovidDeaths$
where continent is not null 
group by date
order by date

-- Looking at total population vs vaccination

select dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as VacinationRunningTotal
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


With PopvsVac (continent, location, date, population, new_vaccinations, VacinationRunningTotal)
as
(
select dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as VacinationRunningTotal
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)

select * 
, (VacinationRunningTotal/population)*100
from PopvsVac
order by 2,3


-- Temp Table instead of CTE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255)
,location nvarchar(255)
,date datetime
,population numeric
,new_vaccinations numeric
,VaccinationRunningTotal numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as VacinationRunningTotal
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

select * 
, (VaccinationRunningTotal/population)*100
from #PercentPopulationVaccinated
order by 2,3

-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as VacinationRunningTotal
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated