
Select *
from PortfolioProject..CovidDeaths$
order by 3,4




--Select data that I am going to be using

Select Location,date, total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases vs deaths
--shows the likelihood of dying if you contract covid in your country

Select Location,date, total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%stan%'
order by 1,2


--looking at Total cases vs population
--shows what percentage of population got covid

Select Location,date, total_cases,population,(total_cases/population)*100 as CasesPerPopulation
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population


Select Location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as CasesPerPopulation
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by location, population
order by CasesPerPopulation desc




--showing Countries with highest death count per population
--since the figures weren't adding up, I had to check the new_death column and cast the nvarchar to int

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%states%'
Group by location
order by TotalDeathCount desc




--Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%states%'
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%states%'
Group by date 
order by 1,2




Select *
from PortfolioProject..CovidVaccinations$
order by 3,4



--JOin tables
--looking at Total Population vs Vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location, dea.date)

from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--Use CTE

--with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as 
--(
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

--from PortfolioProject..CovidDeaths$ dea
--join PortfolioProject..CovidVaccinations$ vac
--on dea.location=vac.location
--and dea.date = vac.date
--where dea.continent is not null

--)
--select *, (Rolling/Population)*100
--from PopsVac

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location , dea.date)
 as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

