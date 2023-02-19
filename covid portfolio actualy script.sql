SELECT * FROM Covid19.coviddeaths19
order by 3,4;

-- select data that we are going to use 

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid19.coviddeaths19
    order by 1,2;
    
-- Looking at total cases vs Total deaths
-- shows likelihood of dying of covid in your country
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases)*100 as Deathpercentage
FROM
    covid19.coviddeaths19
    where location like '%south%'
 ORDER BY 1 , 2;
 
 -- total cases vs population 
 -- what percentage of population got covid 
 SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases/population)*100 as Deathpercentage
FROM
    covid19.coviddeaths19
    where location like '%south%'
 ORDER BY 1 , 2;
 
 -- country has the highest inffection rate compared to population 
 
 SELECT 
    location,
    population,
    max(total_cases) as Highestinfectioncount, max((total_cases/population))*100 as percentofpopulationinfected
FROM
    covid19.coviddeaths19
  group by location, population
 ORDER BY percentofpopulationinfected desc;
 
 -- showing countries with highest death rate per population 
  
SELECT 
    location, MAX(total_deaths) AS totaldeathcount
FROM
    covid19.coviddeaths19
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;
 
 
SELECT 
    *
FROM
    covid19.coviddeaths19
WHERE
    continent IS NOT NULL
ORDER BY 3 , 4;
 
 -- break things down by continent 
 
 SELECT 
    location, MAX(total_deaths) AS totaldeathcount
FROM
    covid19.coviddeaths19
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;

-- Global numbers 
 
 SELECT 
    date,
    sum(new_cases) as total_cases, 
    sum(new_deaths) as total_deaths,
    sum(new_cases)/sum(new_deaths)*100 as deathpercentage
    -- total_cases,
    -- total_deaths,
    -- (total_deaths / total_cases) * 100 AS Deathpercentage
FROM
    covid19.coviddeaths19
WHERE
    continent IS NOT NULL
    group by date
ORDER BY 1 , 2;


-- looking at total population vs vaccinations 
SELECT 
    dea.continent, dea.location,dea.date, dea.population, dea.new_vaccinations,
    sum(dea.new_vaccinations) over(partition by dea.location order by dea.location, dea.date)
    as rollingpeoplevaccinated
    -- (rollingpeoplevaccinated/population)*100
FROM
    covid19.coviddeaths19 dea
        JOIN
    covid19.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
	where dea.continent is not null
	order by 2,3;

-- use CTE

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as (
SELECT 
    dea.continent, dea.location,dea.date, dea.population, dea.new_vaccinations,
    sum(dea.new_vaccinations) over(partition by dea.location order by dea.location, dea.date)
    as rollingpeoplevaccinated
    -- (rollingpeoplevaccinated/population)*100
FROM
    covid19.coviddeaths19 dea
        JOIN
    covid19.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3
    )
    
    select *, (rollingpeoplevaccinated/population)*100
    from popvsvac;
    
 -- temp table 
 
create Table percentpopulationvaccinated
 (
 continent nvarchar(255),
 loaction nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )
 
 insert into percentpopulationvaccinated
 SELECT 
    dea.continent, dea.location,dea.date, dea.population, dea.new_vaccinations,
    sum(dea.new_vaccinations) over(partition by dea.location order by dea.location, dea.date)
    as rollingpeoplevaccinated
    -- (rollingpeoplevaccinated/population)*100
FROM
    covid19.coviddeaths19 dea
        JOIN
    covid19.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3
    
select *, (rollingpeoplevaccinated/population)*100
    from percentpopulationvaccinated;
    
 -- creating view to store data for later visualizations 
 
create view popvsvacs as 

SELECT 
    dea.continent, dea.location,dea.date, dea.population, dea.new_vaccinations,
    sum(dea.new_vaccinations) over(partition by dea.location order by dea.location, dea.date)
    as rollingpeoplevaccinated
    -- (rollingpeoplevaccinated/population)*100
FROM
    covid19.coviddeaths19 dea
        JOIN
    covid19.covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3;
    
 