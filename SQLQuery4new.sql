--select data we use 

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1, 2;

-- percentage of total cases vs total deaths in Algeria.

select location, date, total_cases, total_deaths, round((total_deaths/total_cases) *100, 2) as percentage
from dbo.CovidDeaths$
where location like '%Algeria%' ;

-- total cases vs  population of Algeria.

select location, date, total_cases, population , round((total_cases/ population) *100, 2) as percentage
from dbo.CovidDeaths$
where location like '%Algeria%' 
order by 1, 2;

-- highest rates of reproduction rate
select location, population,  max(total_cases) as highest_infection, max((total_cases /population)*100 ) percentage_population_infected
from dbo.CovidDeaths
group by location, population
order by 4 desc;

-- continents  with highest death count 

select location, max (cast (total_deaths as int)) as total_deaths
from CovidDeaths
where continent is not null
group by location
order by 2 desc;

-- total deaths by continent

select continent , max(cast (total_deaths as int)) as total_deaths_per_continent
from coviddeaths 
where continent is not null
group by continent 
order by  total_deaths_per_continent desc;
  
  --showing the continents with highest death counts 

  select continent, max ((cast(total_deaths as int) / population)*	100) as highest_death_count_compared_to_population
  from dbo.CovidDeaths
  where continent is not null
  group by continent
  order by highest_death_count_compared_to_population desc;

  --Global numbers 

  -- number of new cases and deaths  everyday worldwide

  select date, sum(new_cases) as new_cases_worldwide, sum(cast (new_deaths as int)) as new_deaths_worldwide
  from CovidDeaths
  where continent is not  null
  group by date
  order by 2 desc ;  


  -- percentage  of deaths to new cases everyday worldwide

  select date, sum(cast (new_deaths as int)) as new_deaths , sum(new_cases) as new_cases, (sum(cast( new_deaths as int)) / sum(new_cases )) *100 as percentage_newcases_to_deaths
  from CovidDeaths
  where continent is not  null
  group by date
  order by  percentage_newcases_to_deaths;  

  -- joints: vaccination table and covid table.

  select B.continent, B.location,
  B.date, B.population, A.new_vaccinations, sum(convert (int, new_vaccinations)) over (partition by B.location order by B.location, B.date)
  as rolling people vaccinated

  from [Protfolio project].[dbo].[covidvaccination] as A 
  join [Protfolio project].[dbo].[CovidDeaths] as B
  on A.location = B.location 
  and A.date = B.date
  where B.continent is not null
  order by 2,3;

  -- using CTEs

  with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) 
  
  as 
( select B.continent, B.location,
  B.date, B.population, A.new_vaccinations, sum(convert (int, new_vaccinations)) over (partition by B.location order by B.location, B.date)
  as rollingpeoplevaccinated

  from [Protfolio project].[dbo].[covidvaccination] as A 
  join [Protfolio project].[dbo].[CovidDeaths] as B
  on A.location = B.location 
  and A.date = B.date
  where B.continent is not null
  --order by 2,3;
  )
  select * 
  from popvsvac;

  -- temp table 
  drop table if exists #percentpopulationvaccinated  
  create table #percentpopulationvaccinated (

  continent nvarchar(255),
  location nvarchar(255), 
  date datetime, 
  population numeric, 
  new_vaccinations numeric, 
  rollingpeoplevaccinated numeric

  )

  Insert into #percentpopulationvaccinated

  select B.continent, B.location,
  B.date, B.population, A.new_vaccinations, sum(convert (int, new_vaccinations)) over (partition by B.location order by B.location, B.date)
  as rollingpeoplevaccinated

  from [Protfolio project].[dbo].[covidvaccination] as A 
  join [Protfolio project].[dbo].[CovidDeaths] as B
  on A.location = B.location 
  and A.date = B.date
  where B.continent is not null
  --order by 2,3;

  select *, (rollingpeoplevaccinated / population)*100 
  from #percentpopulationvaccinated

  -- views

  create view percentpopulationvaccinated as 

   select B.continent, B.location,
  B.date, B.population, A.new_vaccinations, sum(convert (int, new_vaccinations)) over (partition by B.location order by B.location, B.date)
  as rollingpeoplevaccinated

  from [Protfolio project].[dbo].[covidvaccination] as A 
  join [Protfolio project].[dbo].[CovidDeaths] as B
  on A.location = B.location 
  and A.date = B.date
  where B.continent is not null
  --order by 2,3;

