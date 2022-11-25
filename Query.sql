select * from PortfolioProject..CovidDeaths where continent is not null order by 3,4 


--select * from PortfolioProject..CovidVaccinations order by 3,4

--Select data we are going to use

select Location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..CovidDeaths where continent is not null order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths where continent is not null order by 1,2

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths where Location like '%India%' order by 1,2

--Looking at Total Cases vs Population

select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected from PortfolioProject..CovidDeaths where Location like '%India%' order by 1,2

--Looking at Countries with highest Infection rate compared to Population

select Location,Population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected from PortfolioProject..CovidDeaths group by location,population order by 1,2

select Location,Population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected from PortfolioProject..CovidDeaths group by location,population order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count
select Location,Population,max(total_deaths) as HighestDeathCount from PortfolioProject..CovidDeaths group by location,population order by HighestDeathCount desc

select Location,Population,max(cast(total_deaths as int)) as HighestDeathCount from PortfolioProject..CovidDeaths where continent is not null group by location,population order by HighestDeathCount desc

select Location,max(total_deaths) as HighestDeathCount from PortfolioProject..CovidDeaths group by location order by HighestDeathCount desc
--as total_deaths is varchar so we need to cast it to int 


select Location,max(cast(total_deaths as int)) as HighestDeathCount from PortfolioProject..CovidDeaths where continent is not null group by location order by HighestDeathCount desc
--where continent is not null => now the output dont have asia africa european union etc continents

--Lets Break things by Continent  
select continent,max(cast(total_deaths as int)) as HighestDeathCount from PortfolioProject..CovidDeaths where continent is null group by continent order by HighestDeathCount desc

select location,max(cast(total_deaths as int)) as HighestDeathCount from PortfolioProject..CovidDeaths where continent is null group by location order by HighestDeathCount desc

select continent,max(cast(total_deaths as int)) as HighestDeathCount from PortfolioProject..CovidDeaths where continent is not null group by continent order by HighestDeathCount desc


--Showing Continents with highest death count per population 

select continent,max(cast(total_deaths as int)) as HighestDeathCount from PortfolioProject..CovidDeaths where continent is not null group by continent order by HighestDeathCount desc


--Global Numbers 
Select date,total_cases,(total_deaths/total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2 

Select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as ToatalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2 

Select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as ToatalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2 







select * from PortfolioProject..CovidVaccinations order by 3,4


--Join both tables 

Select * from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
	on dea.location=vax.location
	and dea.date=vax.date

--Looking at Total Populations vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
order by 2,3


Select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations,
sum(convert(int,vax.new_vaccinations)) over (Partition by dea.Location) as XYZ from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
order by 2,3

--cast & convert do the same thing

Select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations,
sum(convert(int,vax.new_vaccinations)) over (Partition by dea.Location order by dea.Location,dea.date) as PeopleVaccinated from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
order by 2,3


Select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations,
sum(convert(int,vax.new_vaccinations)) over (Partition by dea.Location order by dea.Location,dea.date) as PeopleVaccinated
--(PeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent,Location,date,population,new_vaccinations,PeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations,
sum(convert(int,vax.new_vaccinations)) over (Partition by dea.Location order by dea.Location,dea.date) as PeopleVaccinated
--(PeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
--order by 2,3
)
Select *,(PeopleVaccinated/population)*100 from PopvsVac




--Using Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations,
sum(convert(int,vax.new_vaccinations)) over (Partition by dea.Location order by dea.date) as PeopleVaccinated
--(PeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
--order by 2,3

Select *,(PeopleVaccinated/population)*100 from #PercentPopulationVaccinated

--if you want to alter table then drop it then make alterations



--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations,
sum(convert(int,vax.new_vaccinations)) over (Partition by dea.Location order by dea.date) as PeopleVaccinated
--(PeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
	on dea.location=vax.location
	and dea.date=vax.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated
 


















































































