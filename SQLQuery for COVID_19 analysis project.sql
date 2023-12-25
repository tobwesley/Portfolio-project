

--Key Questions to Explore:

--1. What are the overall trends in new infections and total deaths over time?

SELECT DATENAME(YEAR, date) as trend_year, SUM(CAST(new_cases as float)) AS total_new_case, SUM(CAST(total_deaths AS float)) AS total_new_deaths,
SUM(CAST(new_cases as float))/SUM(CAST(total_deaths AS float))*100 AS Death_Rate
FROM [dbo].[CovidDeaths$]
GROUP BY DATENAME(YEAR, date)
ORDER BY trend_year

--From the result, we can see a sharp drop in the death rate overtime. Year 2020 obviously had the highest death rate (34.3%) hence this trended downward with 2023 having the lowest of 1.79%.

--2. How does the full vaccination correlate with the decline in new infections?
SELECT DATENAME(YEAR, dea.date) AS trend_year, SUM(CAST(dea.new_cases AS float)) as total_new_cases, SUM(CAST(vac.people_fully_vaccinated AS float)) as full_vaccinated,
SUM(CAST(dea.new_cases AS float))/SUM(CAST(vac.people_fully_vaccinated AS float))*100 AS new_infection_rate_post_vac
FROM [dbo].[CovidDeaths$] dea
JOIN [dbo].[CovidVaccinations$] vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE people_fully_vaccinated IS NOT NULL
GROUP BY DATENAME(YEAR, dea.date)
ORDER BY trend_year

--The insight generated from this shows a continious drop in new infection rate from 2020 through 2023. Increased availability of vaccine and improved awareness/campaign about COVID could be some of the factors responsible for that gtrend.  


--3.  what is the likelihood of dying if you contract covid in your country

SELECT location, SUM(CAST(total_cases AS float)) AS total_cases_sum, SUM(CAST(total_deaths AS float)) AS total_deaths_sum, SUM(CAST(total_deaths AS float))/SUM(CAST(total_cases AS float))*100 as DeathPercentage
FROM [dbo].[CovidDeaths$]
WHERE location like '%Nigeria%'
and continent is not null 
GROUP BY location

--The likelihood of dying if contracted with COVID in Nigeria is about 1/100 (1%).

--4. What is the figures while comparing the Total Population vs Vaccinations.

SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CummuPeopleVaccinated
FROM [dbo].[CovidDeaths$] dea
Join [dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3