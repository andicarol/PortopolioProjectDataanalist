


SELECT *
FROM PortpolioCovid19..CovidDeath
WHERE continent IS NOT NULL
order by 3,4 

--kita cek tipe data dari masing-masing coloumn

EXEC
SP_HELP CovidDeath;

--NAH KITA MAU GANTI NIH TYPE DATA TOTAL_CASES DAN TOTAL_DEATH DARI NVARCHAR MENJADI INT

ALTER TABLE CovidDeath
ALTER COLUMN total_cases FLOAT NULL

ALTER TABLE CovidDeath
ALTER COLUMN total_deaths FLOAT NULL


--
SELECT *
FROM PortpolioCovid19..CovidVaccination
order by 3,4

--SELECT DATA THAT THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortpolioCovid19..CovidDeath
ORDER BY 1,2

--LOOKING AT TOTAL CASE VS TOTAL DEATH
--MENAMPILKAN KEMUNGKINAN MENINGGAL JIKA ANDA TERJADI COVID DI NEGARA ANDA 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortpolioCovid19..CovidDeath
WHERE location LIKE '%INDONESIA%'
AND continent IS NOT NULL
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS POPULATION
-- MENAMPILKAN PERSENTASI DARI POPULASI YANG TERJANGKI DI NEGARA ANDA

SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM PortpolioCovid19..CovidDeath
WHERE location LIKE '%INDONESIA%'
AND continent IS NOT NULL
ORDER BY 1,2

--MELIHAT NEGARA DENGAN TINGKAT INFEKSI TERTINGGI DIBANDING PENDUDUK

SELECT location, population, MAX(total_cases) AS HighestInfactionCountries, MAX((total_cases/population))*100 as InfactionPercentage
FROM PortpolioCovid19..CovidDeath
--WHERE location LIKE '%INDONESIA%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfactionPercentage DESC

--MELIHAT NEGARA DENGAN TINGKAT KEMATIAN TERTINGGI DIBANDING PENDUDUK

SELECT location, population, MAX(total_deaths) AS HighestInfactionCountries, MAX((total_deaths/population))*100 as DeathPercentage
FROM PortpolioCovid19..CovidDeath
--WHERE location LIKE '%INDONESIA%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfactionCountries DESC

--KITA COBA MEMBAGI BERDASARKAN BENUA
--MENUNJUKKAN BENUA DENGAN JUMLAH KEMATIAN TERTINGGI PER PENDUDUK

SELECT continent, MAX(total_deaths) AS HighestDeathCountries, MAX((total_deaths/population))*100 as DeathPercentage
FROM PortpolioCovid19..CovidDeath
--WHERE location LIKE '%INDONESIA%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCountries DESC


--kita cari new_cases vs new_deaths 

SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM PortpolioCovid19..CovidDeath
--WHERE location LIKE '%INDONESIA%'
WHERE continent IS NOT NULL
--GROUP BY continent
ORDER BY 1,2


--melihat total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccination
FROM PortpolioCovid19..CovidDeath dea, 
PortpolioCovid19..CovidVaccination vac
	WHERE dea.location = vac.location 
	AND dea.date = vac.date
	AND dea.location LIKE '%INDONESIA%'
	AND dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, date, location,population, new_vaccinations, RollingPeopleVaccination)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccination
FROM PortpolioCovid19..CovidDeath dea, 
PortpolioCovid19..CovidVaccination vac
	WHERE dea.location = vac.location 
	AND dea.date = vac.date
	AND dea.location LIKE '%INDONESIA%'
	AND dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccination/population)*100 AS PeoplePercentage
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccination
CREATE TABLE #PercentPopulationVaccination
(
	Continent NVARCHAR(255),
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	RollingPeopleVaccination NUMERIC
)
INSERT INTO #PercentPopulationVaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccination
FROM PortpolioCovid19..CovidDeath dea, 
PortpolioCovid19..CovidVaccination vac
	WHERE dea.location = vac.location 
	AND dea.date = vac.date
	AND dea.location LIKE '%INDONESIA%'
	--AND dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*,(RollingPeopleVaccination/population)*100 AS PeoplePercentage
FROM #PercentPopulationVaccination


--MEMBUAT 'VIEW' KE DATA PENYIMPANAN UNTUK NANTI DI VISUALISASIKAN

CREATE VIEW PercentPopulationVaccination AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccination
FROM PortpolioCovid19..CovidDeath dea, 
PortpolioCovid19..CovidVaccination vac
	WHERE dea.location = vac.location 
	AND dea.date = vac.date
	AND dea.location LIKE '%INDONESIA%'
	AND dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccination