--SELECT *
--FROM Projects..CovidDeaths$
--order by date DESC

--SELECT *
--FROM Projects..CovidVaccinations$

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM Projects..CovidDeaths$
ORDER BY location, date

--Looking at the Total Cases & Total Deaths in Nigeria
SELECT location, date, total_cases, total_deaths, CONVERT(float, (total_deaths)/ CONVERT(float,(total_cases))) * 100 AS DeathPercentage
FROM Projects..CovidDeaths$
WHERE location like '%Nigeria%'
ORDER BY location, date


-- Looking at the total cases & the population
-- Shows the percentage of the population that has contacted COVID-19
SELECT location, date, population, total_cases, CONVERT(float, (total_cases)/ CONVERT(float,(population))) * 100 AS PopulationDeathPercentage
FROM Projects..CovidDeaths$
WHERE location like '%Nigeria%'
ORDER BY location, date


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CONVERT(float, (total_cases)/ CONVERT(float,(population)))) * 100 AS PercentOfInfectedPopulation
FROM dbo.CovidDeaths$
GROUP BY location, population
ORDER BY PercentOfInfectedPopulation DESC


-- Looking at countries with highest death rate 

SELECT location, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
FROM dbo.CovidDeaths$
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Looking at continent with highest death rate 

SELECT continent, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
FROM dbo.CovidDeaths$
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Getting the Nigeria death percentage by dates

SELECT date, SUM(new_cases) AS TotalCases , SUM(new_deaths) AS TotalDeaths , CONVERT (float, SUM(new_deaths)/ NULLIF(SUM(new_cases), 0)) * 100 AS TotalDeathPercentage
FROM Projects..CovidDeaths$
WHERE location like '%Nigeria%'
GROUP BY date 
ORDER BY date, TotalDeathPercentage DESC



-- Getting Nigeria's Total Death vs the Population per date

WITH TotalDeathNGA(date, population, TotalCases , TotalDeaths)
AS
(
SELECT date, population, SUM(new_cases) AS TotalCases , SUM(new_deaths) AS TotalDeaths  
FROM Projects..CovidDeaths$
WHERE location like '%Nigeria%'
GROUP BY date, population
)

Select *, (TotalDeaths/population) * 100 TotalPercentage
FROM TotalDeathNGA


-- Getting the World death percentage by dates

SELECT date, SUM(new_cases) AS TotalCases , SUM(new_deaths) AS TotalDeaths , CONVERT (float, SUM(new_deaths)/ NULLIF(SUM(new_cases), 0)) * 100 AS TotalDeathPercentage
FROM Projects..CovidDeaths$
WHERE continent is not null
GROUP BY date 
ORDER BY date


-- Getting the World death general percentage as at 2023-04-07

SELECT SUM(new_cases) AS TotalCases , SUM(new_deaths) AS TotalDeaths , CONVERT (float, SUM(new_deaths)/ NULLIF(SUM(new_cases), 0)) * 100 AS TotalDeathPercentage
FROM Projects..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2


----
--Joining both tables
----

-- Total Population vs New Vaccination as at 2023-04-07

SELECT cvdeaths.continent, cvdeaths.location, cvdeaths.date, cvdeaths.population, cvvac.new_vaccinations
, SUM(cast(cvvac.new_vaccinations as bigint)) OVER (PARTITION BY cvdeaths.location ORDER BY cvdeaths.location, cvdeaths.date) AS VaccinationCount
FROM Projects.dbo.CovidDeaths$ cvdeaths
JOIN Projects.dbo.CovidVaccinations$ cvvac
	ON cvdeaths.date = cvvac.date
	AND cvdeaths.location = cvvac.location
WHERE cvdeaths.continent is not null
ORDER BY 2, 3


-- Getting the Total Percentage per country of vaccinated people using CTE (Common Table Expressions)

WITH VaccinatedPopulation  (continent, location, date, population, new_vaccinations, VaccinationCount)
AS (

SELECT cvdeaths.continent, cvdeaths.location, cvdeaths.date, cvdeaths.population, cvvac.new_vaccinations
, SUM(cast(cvvac.new_vaccinations as bigint)) OVER (PARTITION BY cvdeaths.location ORDER BY cvdeaths.location, cvdeaths.date) AS VaccinationCount
FROM Projects.dbo.CovidDeaths$ cvdeaths
JOIN Projects.dbo.CovidVaccinations$ cvvac
	ON cvdeaths.date = cvvac.date
	AND cvdeaths.location = cvvac.location
WHERE cvdeaths.continent is not null
)

SELECT *, (VaccinationCount/population) * 100 PercentageVaccinationCount
FROM VaccinatedPopulation



-- Total Population Nigeria vs New Vaccination as at 2023-04-07

SELECT cvdeaths.location, cvdeaths.date, cvdeaths.population, cvvac.new_vaccinations
, SUM(cast(cvvac.new_vaccinations as bigint)) OVER (PARTITION BY cvdeaths.location ORDER BY cvdeaths.location, cvdeaths.date) AS VaccinationCount
FROM Projects.dbo.CovidDeaths$ cvdeaths
JOIN Projects.dbo.CovidVaccinations$ cvvac
	ON cvdeaths.date = cvvac.date
	AND cvdeaths.location = cvvac.location
WHERE cvdeaths.location like '%Nigeria%'
ORDER BY 1, 2



-- Creating Views for later visualization in Tableau

CREATE VIEW TotalDeathPercentage AS

--Looking at the Total Cases & Total Deaths in Nigeria
SELECT location, date, total_cases, total_deaths, CONVERT(float, (total_deaths)/ CONVERT(float,(total_cases))) * 100 AS DeathPercentage
FROM Projects..CovidDeaths$
WHERE location like '%Nigeria%'


CREATE VIEW PercentageOfPeopleVaccinatedNigeria AS

SELECT cvdeaths.location, cvdeaths.date, cvdeaths.population, cvvac.new_vaccinations
, SUM(cast(cvvac.new_vaccinations as bigint)) OVER (PARTITION BY cvdeaths.location ORDER BY cvdeaths.location, cvdeaths.date) AS VaccinationCount
FROM Projects.dbo.CovidDeaths$ cvdeaths
JOIN Projects.dbo.CovidVaccinations$ cvvac
	ON cvdeaths.date = cvvac.date
	AND cvdeaths.location = cvvac.location
WHERE cvdeaths.location like '%Nigeria%'



CREATE VIEW PercentageOfPeopleVaccinatedWorld AS 

SELECT cvdeaths.continent, cvdeaths.location, cvdeaths.date, cvdeaths.population, cvvac.new_vaccinations
, SUM(cast(cvvac.new_vaccinations as bigint)) OVER (PARTITION BY cvdeaths.location ORDER BY cvdeaths.location, cvdeaths.date) AS VaccinationCount
FROM Projects.dbo.CovidDeaths$ cvdeaths
JOIN Projects.dbo.CovidVaccinations$ cvvac
	ON cvdeaths.date = cvvac.date
	AND cvdeaths.location = cvvac.location
WHERE cvdeaths.continent is not null


CREATE VIEW WorldDeathPercentage  AS

SELECT SUM(new_cases) AS TotalCases , SUM(new_deaths) AS TotalDeaths , CONVERT (float, SUM(new_deaths)/ NULLIF(SUM(new_cases), 0)) * 100 AS TotalDeathPercentage
FROM Projects..CovidDeaths$
WHERE continent is not null


CREATE VIEW TotalDeathsNGA

AS
-- Getting Nigeria's Total Death vs the Population per date
SELECT date, population, SUM(new_cases) AS TotalCases , SUM(new_deaths) AS TotalDeaths  
FROM Projects..CovidDeaths$
WHERE location like '%Nigeria%'
GROUP BY date, population


CREATE VIEW TotalDeathCountContinent
AS
SELECT continent, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
FROM dbo.CovidDeaths$
WHERE continent is not null 
GROUP BY continent