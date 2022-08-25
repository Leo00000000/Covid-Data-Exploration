select * from covid_death
order by 3 desc

select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From covid_death
where continent is not null
Group by Location
order by TotalDeathCount DESC


--Countintents with the highest death count per population

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From covid_death
where Total_deaths is not null
Group by location
order by TotalDeathCount DESC


-- Global Numbers
Select date, Sum(new_cases) as total_cases, sum(new_deaths) as total_new_deaths, Nullif(Sum(new_deaths),0)/Nullif(sum(new_cases),0)*100 as DeathPercentage
from covid_death
where continent is not null
group by date
order by 1, 2

-- Global Numbers death proportion
Select Sum(new_cases) as total_cases, sum(new_deaths) as total_new_deaths, Nullif(Sum(new_deaths),0)/Nullif(sum(new_cases),0)*100 as DeathPercentage
from covid_death
where continent is not null
order by 1, 2

--convine two tables
Select * 
from covid_death dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	

--Looking at Total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from covid_death dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and vac.new_vaccinations is not null
order by 1, 2, 3

--Looking at sum at day by day
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,

from covid_death dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and vac.new_vaccinations is not null
order by 1, 2, 3
	

-- USE CTE

with PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_death dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and vac.new_vaccinations is not null
--order by 1, 2, 3
	)
	
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP Table
Drop Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
contintent VARCHAR(255),
location VARCHAR(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_death dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and vac.new_vaccinations is not null
--order by 1, 2, 3
	
Select *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated1 as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_death dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> '' and vac.new_vaccinations is not null
--order by  2, 3



	