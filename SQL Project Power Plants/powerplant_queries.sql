/* RENAMING COLUMNS */
sp_rename 'powerplantsd.country_long', 'country', 'COLUMN';

sp_rename 'powerplantsd.name_of_powerplant', 'powerplant_name', 'COLUMN';
sp_rename 'powerplantsd.capacity_in_MW', 'installed_capacity', 'COLUMN';
sp_rename 'powerplantsd.primary_fuel', 'energy_source', 'COLUMN';

/* QUERY ONE: To filter by only the thermal power plants in the world */ 
SELECT * FROM powerplantsd
	WHERE energy_source IN ('Gas', 'Coal', 'Oil');

/* QUERY TWO: To see the total installed capacity grouped by energy source for the world and
the average installed capacity grouped by energy source */
SELECT energy_source, ROUND(SUM(installed_capacity),2) AS total_installed_capacity FROM powerplantsd
	GROUP BY energy_source
	ORDER BY total_installed_capacity DESC;

SELECT energy_source, ROUND(AVG(installed_capacity),2) AS average_installed_capacity FROM powerplantsd
	GROUP BY energy_source
	ORDER BY average_installed_capacity DESC;

/*	QUERY THREE: To see the total installed capacity of each country */
SELECT country, SUM(installed_capacity) AS total_installed_capacity FROM powerplantsd
	GROUP BY country
	ORDER BY country;

/* QUERY FOUR: To see what countries have low carbon energy sources */
SELECT e.country, x.ic/SUM(e.installed_capacity) AS renewable_ratio
FROM powerplantsd e
JOIN
(SELECT country, SUM(installed_capacity) AS ic FROM powerplantsd
	WHERE energy_source IN ('Hydro', 'Wind', 'Solar', 'Geothermal', 'Biomass', 'Wave and Tidal')
	GROUP BY country	
	) x
ON e.country = x.country
GROUP BY e.country, x.ic
ORDER BY e.country;

/* QUERY FIVE: To see where nuclear power plants are located */
SELECT country, powerplant_name, installed_capacity FROM powerplantsd
	WHERE energy_source = 'Nuclear'

/* QUERY SIX: To see how the energy matrix is composed for each country */
SELECT country, SUM(installed_capacity) AS total_installed_capacity, energy_source FROM powerplantsd
	GROUP BY country, energy_source
	ORDER BY country;

/* QUERY SEVEN: To see how many clean energy power plants each country have */
SELECT country, COUNT(installed_capacity) AS installed_capacity, energy_source FROM powerplantsd
	GROUP BY country, energy_source
	HAVING energy_source IN ('Hydro', 'Wind', 'Solar', 'Geothermal', 'Biomass', 'Wave and Tidal')
	ORDER BY country;

/* QUERY EIGHT: To see what country in South America have the cleanest energy matrix */
SELECT e.country, x.ic/SUM(e.installed_capacity) AS renewable_ratio
FROM powerplantsd e
JOIN
(SELECT country, SUM(installed_capacity) AS ic FROM powerplantsd
	WHERE energy_source IN ('Hydro', 'Wind', 'Solar', 'Geothermal', 'Biomass', 'Wave and Tidal')
	GROUP BY country
	HAVING country IN ('Argentina','Bolivia','Brazil','Chile', 'Colombia', 'Guyana', 'Paraguay', 'Peru', 'Uruguay', 'Venezuela')
	) x
ON e.country = x.country
GROUP BY e.country, x.ic
ORDER BY e.country;

/* QUERY NINE: Which type of power plants are closer to generate electricity at maximum capacity */
ALTER TABLE powerplantsd
ADD capacity_factor FLOAT;

UPDATE powerplantsd
	SET capacity_factor = generation_gwh_2021 / (installed_capacity * 8.76);

SELECT energy_source, AVG(capacity_factor) AS AVGCAPACITY_FACTOR FROM powerplantsd
	GROUP BY energy_source
	ORDER BY AVGCAPACITY_FACTOR DESC;

/* QUERY TEN: To see the clean energy ratio among countries whose total installed capacity is higher than 60000kw */
SELECT d.country, ROUND((SUM(d.installed_capacity)/x.TOTAL_IC),4) AS RENEWABLE_RATIO 
FROM powerplantsd d
JOIN
	(SELECT country, SUM(installed_capacity) AS TOTAL_IC FROM powerplantsd
	GROUP BY country
	HAVING SUM(installed_capacity) > 60000) x
ON d.country = x.country
WHERE energy_source IN ('Hydro', 'Wind', 'Solar', 'Geothermal', 'Biomass', 'Wave and Tidal', 'Nuclear')
GROUP BY d.country, x.TOTAL_IC
ORDER BY RENEWABLE_RATIO DESC;
