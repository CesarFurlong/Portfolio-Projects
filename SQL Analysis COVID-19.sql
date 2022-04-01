---- Seleccionaremos las columnas con las que vamos a realizar nuestro analisis.
SELECT date, continent, location, total_cases, new_cases, total_deaths, new_deaths, total_tests, new_tests, population
FROM covid_data
WHERE continent is not null
ORDER BY date, location

---- Relación entre las muertes por casos totales.
---- Muestra el porcentaje de mortalidad por COVID-19.
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM covid_data
WHERE continent is not null
ORDER BY location

----- Relación entre los casos totales y la población.
----- Este calculo representa el porcentaje de contraer COVID-19.
SELECT location, total_cases, population, (total_cases/population)*100 AS PopulationInfect_rate
FROM covid_data
WHERE continent is not null
--AND location = 'Mexico'
ORDER BY location

----- Mayor numero de infección comparado con su población.
SELECT date, location, population, MAX(total_cases) AS HighestInfection_Rate, MAX((total_cases/population)*100) AS PopulationInfection_Rate
FROM covid_data
WHERE continent is not null
GROUP BY date, location, population
ORDER BY location, PopulationInfection_Rate DESC;

----- Mortalidad más alta comparada con su población.
SELECT location, population, MAX(total_deaths) AS HighestDeath_Rate, MAX((total_deaths/population)*100) AS PopulationDeath_Rate
FROM covid_data
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeath_Rate DESC; 

----- Numeros totales por continente
SELECT continent, MAX(total_deaths) AS HighestDeath_Rate, MAX((total_deaths/population)*100) AS PopulationDeath_Rate
FROM covid_data
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeath_Rate DESC; 

----- Numeros globales 
SELECT SUM(new_cases) AS total_global_cases, SUM(new_deaths) AS total_global_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS global_death_perc
FROM covid_data

----- Explorando la relacion population vs vaccinations
SELECT date, continent, location, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date, location) AS peoplevaccinated
FROM covid_data
WHERE continent is not null
AND new_vaccinations is not null 
AND location = 'Australia'
ORDER BY continent;

----- Creamos una tabla temporal 

DROP TABLE IF EXISTS covid_analysis

CREATE TEMP TABLE covid_analysis (
date datetime,
continent text,
location text,
total_cases real, 
total_deaths real,
population real,
new_vaccinations real, 
peoplevaccinated real)

INSERT INTO covid_analysis
SELECT date, continent, location, total_cases, total_deaths, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date, location) AS peoplevaccinated
FROM covid_data
WHERE continent is not null
---AND new_vaccinations is not null 
ORDER BY location

-------- Confirmamos los datos en la nueva tabla con una consulta 

SELECT * FROM covid_analysis

-------- Calculo del porcentaje de la población vacunada.

SELECT date, continent, location, population, peoplevaccinated, round((CAST(peoplevaccinated AS FLOAT) /population) * 100,3) AS percent_populationvaccinated
FROM covid_analysis
WHERE date = '2022-03-24'
AND location = 'Mexico'

------ Creando VIEW

CREATE VIEW percent_populationvaccinated AS 
SELECT date, continent, location, total_cases, total_deaths, population, people_vaccinated, percent_populationvaccinated
FROM covid_analysis
