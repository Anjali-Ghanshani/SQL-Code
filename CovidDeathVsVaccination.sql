--selecting data that we are going to be using:

SELECT location, 
	date, 
	population, 
	total_cases, 
	total_deaths 
FROM `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
order by 1,2;

-- looking at Total cases vs Total deaths

SELECT 
	location, 
	population, 
	total_cases, 
	total_deaths 
FROM `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
order by 1,2;

-- looking at Total deaths vs Total death percentage per Location
-- likelihood of dying out of Corona Virus if you contract in a country

select Location,
	date,
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where Upper(Location) = 'AUSTRALIA'
group by 1,2,3,4 
order by 1,2,3,4;


-- looking at Total_cases vs Populations

select 
	LOcation,
	date,
	population,
	total_cases,  
	(total_cases/population)*100 as PercentageInfected
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where Upper(Location) = 'AUSTRALIA' 
order by 1,2;


-- looking at the countries with highest infection rates

select 
	Location, 
	(max(total_cases/population)*100) as MAxPercentageInfected
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where Upper(Location) = 'AUSTRALIA' 
group by 1
order by 1;


-- showing countries with Highest death count per population

select location, 
	max(total_deaths), 
	(max(total_deaths/population))*100 as HighestDeathRate
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where continent is not null 
group by 1
order by HighestDeathRate desc ;


-- Breaking things down by continent

-- SHowing Death counts per population for each continent

select 
	continent, 
	max(total_deaths), 
	(max(total_deaths/population))*100 as HighestDeathRate
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where continent is not null 
group by 1
order by HighestDeathRate desc ;


-- Showing death counts for each location 

select Location, 
	max(total_deaths) as TotalDeathCOunt
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where continent is null 
group by 1
order by TotalDeathCOunt desc ;


-- GLOBAL NUMBERS

-- showing Total new cases vs New deaths Each day:

select 
	date, 
	SUM(new_cases) as Total_cases, 
	Sum(new_deaths) as total_deaths, 
	(SUM(new_deaths)/Sum(New_cases))*100 as DeathPercentage
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where continent is not null 
group by 1
order by 1;

-- Showing total cases vs total deaths over all:

select  
	SUM(new_cases) as Total_cases, 
	Sum(new_deaths) as total_deaths, 
	(SUM(new_deaths)/Sum(New_cases))*100 as DeathPercentage
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where continent is not null 
--group by 1
order by 1;


-- Looking at total Vaccination vs Population


select 
       dea.continent, 
       dea.location, 
       dea.population,
       dea.date, 
       vac.new_vaccinations,
       Sum(new_vaccinations) over (PARTITION BY dea.location order by dea.location, dea.date) as totalVacByLoc,
       --(totalVacByLoc/dea.population)*100 as  PercentagetotalVacByLoc

from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths` dea
Join `analyzephase290621.Portfolio_CovidData_Sep2021.CovidVaccinations` vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- USE CTE (Common Table Expression) https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#simple_cte

With PopVsVAc 
As
(
    select 
       dea.continent, 
       dea.location, 
       dea.population,
       dea.date, 
       vac.new_vaccinations,
       Sum(new_vaccinations) over (PARTITION BY dea.location order by dea.location, dea.date) as totalVacByLoc
       --(totalVacByLoc/dea.population)*100 as  PercentagetotalVacByLoc

from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths` dea
Join `analyzephase290621.Portfolio_CovidData_Sep2021.CovidVaccinations` vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
and dea.Location like '%India%'
--order by 2,3;
)
select 
    continent, 
    Location, 
    Date, 
    Population,
    new_vaccinations, 
    totalVacByLoc, 
    (totalVacByLoc/population)*100 as  PercentagetotalVacByLoc
From
    PopVsVAc;


-- TEMP TABLE 

Create TEMP TABLE PopVsVAc_SESSION
(
    continent STRING,
    Location STRING,
    Population INTEGER,
    date DATE,
    new_vaccinations INTEGER,
    TotalVAcByLOc INTEGER,
    --PercentagetotalVacByLoc FLOAT
)
AS
    select 
       dea.continent, 
       dea.location, 
       dea.population,
       dea.date, 
       vac.new_vaccinations,
       Sum(new_vaccinations) over (PARTITION BY dea.location order by dea.location, dea.date) as totalVacByLoc
       --(totalVacByLoc/dea.population)*100 as  PercentagetotalVacByLoc

from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths` dea
Join `analyzephase290621.Portfolio_CovidData_Sep2021.CovidVaccinations` vac
on 
    dea.location = vac.location
and 
    dea.date = vac.date
where 
    dea.continent is not null 
and
    dea.Location like '%Australia%'
--order by 2,3
;

select 
    continent, 
    Location, 
    Population,
    Date,
    new_vaccinations, 
    totalVacByLoc, 
    (totalVacByLoc/population)*100 as  PercentagetotalVacByLoc
FROM 
    PopVsVAc_SESSION;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW IF NOT EXISTS `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths_View`
(
    Date, 
    Total_Cases,
    Total_deaths,
    DeathPercentage
)
 As
select date, SUM(new_cases) as Total_cases, Sum(new_deaths) as total_deaths, (SUM(new_deaths)/Sum(New_cases))*100 as DeathPercentage
from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths`
where continent is not null 
group by 1
order by 1;


select * from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths_View` ;

-- Creating View Using CTE

CREATE OR REPLACE VIEW `analyzephase290621.Portfolio_CovidData_Sep2021.DeathVsVacView`
(
    continent, 
    Location, 
    Date, 
    Population,
    new_vaccinations, 
    totalVacByLoc, 
    PercentagetotalVacByLoc
)
as
With PopVsVAc 
As
(
    select 
       dea.continent, 
       dea.location, 
       dea.population,
       dea.date, 
       vac.new_vaccinations,
       Sum(new_vaccinations) over (PARTITION BY dea.location order by dea.location, dea.date) as totalVacByLoc
       --(totalVacByLoc/dea.population)*100 as  PercentagetotalVacByLoc

from `analyzephase290621.Portfolio_CovidData_Sep2021.CovidDeaths` dea
Join `analyzephase290621.Portfolio_CovidData_Sep2021.CovidVaccinations` vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--and dea.Location like '%Albania%'
--order by 2,3;
)
select 
    continent, 
    Location, 
    Date, 
    Population,
    new_vaccinations, 
    totalVacByLoc, 
    (totalVacByLoc/population)*100 as  PercentagetotalVacByLoc
From
    PopVsVAc;


select * 
from `analyzephase290621.Portfolio_CovidData_Sep2021.DeathVsVacView`
Where 
    Location like '%India%' ;

