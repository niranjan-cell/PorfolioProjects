SELECT * 
FROM PortfolioProject..coviddeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covidvaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..coviddeaths
WHERE continent is not null
ORDER BY 1,2

--Total cases vs Total death

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathpercentage 
FROM PortfolioProject..coviddeaths
WHERE location like '%ndia%'
AND continent is not null
ORDER BY 1,2

--Total cases vs population
-- percentage of papulation got in covid
--highest infected rate
SELECT Location,Population,max(total_cases) as max_infected ,max((total_cases/population))*100 AS total_case_percentage 
FROM PortfolioProject..coviddeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY total_case_percentage DESC

--population death
SELECT Location,max(CAST(total_deaths AS int)) AS deathCount
FROM PortfolioProject..coviddeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY Location
ORDER BY deathCount DESC

--Breaking thing up with continent

-- maximum death by continent


SELECT continent,max(CAST(total_deaths AS int)) AS deathCount
FROM PortfolioProject..coviddeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY continent
ORDER BY deathCount DESC

--Global number
SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deathpercentage 
FROM PortfolioProject..coviddeaths
--WHERE location like '%ndia%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Joining data
--looking at total population vs vaccination
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS RollingUpVaccination
FROM PortfolioProject..coviddeaths d
JOIN PortfolioProject..covidvaccinations v
	ON d.location=v.location
	AND d.date=v.date
WHERE d.continent is not null
ORDER BY 1,2,3

-- CREATING CTE(Common table expression)
WITH popVsVac (Continent,Location,Date,Population,New_vaccinations,RollingUpVaccination)
AS(
	SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
	SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS RollingUpVaccination
	FROM PortfolioProject..coviddeaths d
	JOIN PortfolioProject..covidvaccinations v
		ON d.location=v.location
		AND d.date=v.date
	WHERE d.continent is not null
	--ORDER BY 2,3
)
SELECT *,(RollingUpVaccination/Population)*100
FROM popVsVac

--TEMP TABLE

DROP TABLE IF EXISTS #percentagePopulationVaccinated

CREATE TABLE #percentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingUpVaccination numeric
)
INSERT INTO #percentagePopulationVaccinated
	SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
	SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS RollingUpVaccination
	FROM PortfolioProject..coviddeaths d
	JOIN PortfolioProject..covidvaccinations v
		ON d.location=v.location
		AND d.date=v.date
	--WHERE d.continent is not null
	--ORDER BY 2,3

SELECT *,(RollingUpVaccination/Population)*100
FROM #percentagePopulationVaccinated


--Creating View 
DROP View IF EXISTS percentagePopulationVaccinated 
CREATE VIEW percentagePopulationVaccinated AS
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS RollingUpVaccination
FROM PortfolioProject..coviddeaths d
JOIN PortfolioProject..covidvaccinations v
	ON d.location=v.location
	AND d.date=v.date
WHERE d.continent is not null
--ORDER BY 2,3


SELECT 
	*
FROM
	percentagePopulationVaccinated