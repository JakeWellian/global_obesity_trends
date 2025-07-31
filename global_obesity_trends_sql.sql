/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               BMI Project
-----------------------------------------------------------------------------------------------------------------------------------

Business Context: How has Body Mass Index (BMI) been changing over the last decades? It is common knowledge that global BMI is rising, but by how much? How quickly? 
And which countries are most suscptible to these rising trends? The World Health Organistation (WHO) lists a high BMI as a major risk factor for heart disease, stroke,
bone and joint problems, and a number of cancers, including breast, colon and endometrial cancer. It is also known that a healthy BMI increases your odds of a longer and 
healthier life. As a result analysing BMI data acts as a strong basis for learning about the global health situation and because it is a single measure, the data is easy to 
comprend and easy to collect.

Objective: Using data from the NCD Risk Factor Collaboration (NCD-RisC), the goal is to put a spotlight on the current BMI trends globally and to perform an in-depth analysis
of the situation using analytical and visual tools to highlight key trends. The data is based on the BMI of 200 countries from 1975 - 2016, a 41 year period. This dataset will
be extended once additional data is supplied by NCD-RisC.

Summary:
-- The average BMI globally has increase by 15%. It now stands at 25.9 which classes the globe as "overweight". Overweight is a BMI between 25.0 - 29.9.
-- In 2016, American Samoa had the largest average BMI with 32.5. This classes them as "Obese" (30.0 and above). Eight other countries are also classed a obese.
-- The Pacific region is the most susceptible to high BMI with an average of 29.3 in 2016.
-- In 1975 74.5% of countries were classed as "healthy weight". In 2016 this number dropeed to 34.0% and the number of overweight countries has gone from 12.5% to 61.0%.
-- In 1975 10.5% of countries were "underweight". Since 1987, all of these countries have moved up to "healthy weight".
-- 4% of countries have an average BMI of "obese" compared to 0.5% in 1975. 

Python & Tableau:
-- Full report + BMI calculator comparing your score with your country's average + global average. See more at https://github.com/JakeWellian/Python_projects/blob/main/BMI_python.ipynb 
-- Created dynamic visualizations of global obesity trends with Tableau. See more at https://public.tableau.com/app/profile/jake.wellian/viz/GlobalBMItrends/Story

-----------------------------------------------------------------------------------------------------------------------------------

											Database Creation
                                               
-----------------------------------------------------------------------------------------------------------------------------------
*/

DROP DATABASE IF EXISTS BMI;
CREATE DATABASE BMI;

USE BMI;

/*-----------------------------------------------------------------------------------------------------------------------------------

                                               Tables Creation
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/

-- Creating the tables:

-- Creating the strucutre for the main Database + a temporary database, and multiple related tables

-- To drop the table if already exists
DROP TABLE IF EXISTS BMI_t;       
CREATE TABLE BMI_t ( # Main Database
	 id INTEGER,
	 country VARCHAR(40),
     year_num YEAR,
     sex VARCHAR(6),
     mean_body_mass_index DECIMAL(18,16),
     standard_error DECIMAL(18,16),
     lower_95_uncertainty_interval DECIMAL(18,16),
     upper_95_uncertainty_interval DECIMAL(18,16),
     age_group VARCHAR(7),
     PRIMARY KEY (id)
);                                      
 


/*-----------------------------------------------------------------------------------------------------------------------------------

                                               Data Ingestion
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/

-- Importing the data. 
SET GLOBAL local_infile=1;

truncate BMI_t;
LOAD DATA LOCAL INFILE "C:/Users/Jake Wellian/Documents/Data analytics/Projects/Obesity forecasting/BMI_data_per_country_SQL.csv"
INTO TABLE BMI_t
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


/*-----------------------------------------------------------------------------------------------------------------------------------

                                               NEW COLUMNS/ CLEANING DATA
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/

-- We wish to analyse BMI per region for a more in depth analysis. We will therefore create a new column called region

ALTER TABLE BMI_t
ADD COLUMN region VARCHAR(255) NOT NULL;

UPDATE BMI_t
SET region = CASE
	WHEN country IN ('Afghanistan','Bangladesh','Bhutan','Brunei Darussalam','Cambodia','China','China (Hong Kong SAR)','South Korea','India','Indonesia','Iran',
    'Iraq','Japan','Kazakhstan','Kyrgyzstan','Lao PDR','Malaysia','Maldives','Mongolia','Myanmar','Nepal','North Korea','Pakistan','Philippines','Singapore','Sri Lanka',
    'Taiwan','Tajikistan','Thailand','Timor-Leste','Turkmenistan','Uzbekistan','Viet Nam') THEN 'Asia'
	WHEN country IN ('Albania','Andorra','Armenia','Austria','Azerbaijan','Belarus','Belgium','Bosnia and Herzegovina','Bulgaria','Croatia','Cyprus','Czech Republic',
    'Denmark','Estonia','Finland','France','Georgia','Germany','Greece','Hungary','Iceland','Ireland','Italy','Latvia','Lithuania','Luxembourg','Macedonia (TFYR)',
    'Malta','Moldova','Montenegro','Netherlands','Norway','Poland','Portugal','Romania','Russian Federation','Serbia','Slovakia','Slovenia','Spain','Sweden','Switzerland',
    'Turkey','Ukraine','United Kingdom') THEN 'Europe'
	WHEN country IN ('Algeria','Bahrain','Egypt','Israel','Jordan','Kuwait','Lebanon','Libya','Mauritania','Morocco','Oman','Occupied Palestinian Territory','Qatar',
    'Saudi Arabia','Sudan','Syrian Arab Republic','Tunisia','United Arab Emirates','Yemen') THEN 'Middle East and North Africa'
	WHEN country IN ('American Samoa','Australia','Cook Islands','Fiji','French Polynesia','Kiribati','Marshall Islands','Micronesia (Federated States of)','Nauru',
    'New Zealand','Niue','Palau','Papua New Guinea','Samoa','Solomon Islands','Tokelau','Tonga','Tuvalu','Vanuatu') THEN 'Pacific'
	WHEN country IN ('Angola','Benin','Botswana','Burkina Faso','Burundi','Cabo Verde','Cameroon','Central African Republic','Chad','Comoros','Congo',
    "Cote d'Ivoire",'DR Congo','Djibouti','Equatorial Guinea','Eritrea','Swaziland','Ethiopia','Gabon','Gambia','Ghana','Guinea','Guinea Bissau','Kenya','Lesotho',
    'Liberia','Madagascar','Malawi','Mali','Mauritius','Mozambique','Namibia','Niger','Nigeria','Rwanda','Sao Tome and Principe','Senegal','Seychelles','Sierra Leone',
    'Somalia','South Africa','Tanzania','Togo','Uganda','Zambia','Zimbabwe') THEN 'Sub-Saharan Africa'
	WHEN country IN ('Antigua and Barbuda','Argentina','Bahamas','Barbados','Belize','Bermuda','Bolivia','Brazil','Chile','Colombia','Costa Rica','Cuba','Dominica',
    'Dominican Republic','Ecuador','El Salvador','Grenada','Guatemala','Guyana','Haiti','Honduras','Jamaica','Mexico','Nicaragua','Panama','Paraguay','Peru','Puerto Rico',
    'Saint Kitts and Nevis','Saint Lucia','Saint Vincent and the Grenadines','Suriname','Trinidad and Tobago','Uruguay','Venezuela') THEN 'Latin America and the Caribbean'
	WHEN country IN ('Canada','Greenland','United States of America') THEN 'Noth America'
    ELSE 'Unknown'
END;


-- The dataset has too many groups for age. So it is easier to compare, we will reduce the number of groups.

UPDATE BMI_t
SET age_group = LOWER(age_group);

UPDATE BMI_t
SET age_group = CASE
	WHEN TRIM(age_group) IN ('18-19','20-24') THEN '18-24'
    WHEN TRIM(age_group) IN ('25-29','30-34') THEN '25-34'
    WHEN TRIM(age_group) IN ('35-39','40-44') THEN '35-44'
    WHEN TRIM(age_group) IN ('45-49','50-54') THEN '45-54'
    WHEN TRIM(age_group) IN ('55-59','60-64') THEN '55-64'
    WHEN TRIM(age_group) IN ('65-69','70-74') THEN '65-74'
    WHEN TRIM(age_group) IN ('75-79','80-84','85plus') THEN '75+'
    ELSE 'Unknown'
END;


-- To give more context to the BMI numbers, we will create a new column with different body weight classes

ALTER TABLE BMI_t
ADD COLUMN weight_class VARCHAR(30) NOT NULL;

UPDATE BMI_t
SET weight_class = CASE
	WHEN mean_body_mass_index < 18.5 THEN 'underweight'
    WHEN mean_body_mass_index >= 18.5 AND mean_body_mass_index <= 24.9 THEN 'healthy weight'
    WHEN mean_body_mass_index >= 25.0 AND mean_body_mass_index <= 29.9 THEN 'overweight'
    WHEN mean_body_mass_index > 30.0 THEN 'obese'
    ELSE 'Unknown'
END;


-- To compare countries from each other, we will create a new column and assign a rank to each country based on their average BMI.

ALTER TABLE BMI_t
ADD COLUMN rank_global int;

UPDATE BMI_t AS b
JOIN (
    SELECT
        year_num,
        country,
        RANK() OVER (PARTITION BY year_num ORDER BY AVG(mean_body_mass_index)) AS rank_global
    FROM BMI_t
    GROUP BY year_num, country
) AS subquery ON b.year_num = subquery.year_num AND b.country = subquery.country
SET b.rank_global = subquery.rank_global;


/*-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
/*-- QUESTIONS RELATED TO DATASET
     [Q1] What was this average BMI in 1975 vs 2016 ?
*/

SELECT
    round(AVG(CASE WHEN year_num = 1975 THEN mean_body_mass_index END),1) AS average_BMI_1975,
    round(AVG(CASE WHEN year_num = 2016 THEN mean_body_mass_index END),1) AS average_BMI_2016,
    round(((AVG(CASE WHEN year_num = 2016 THEN mean_body_mass_index END) - AVG(CASE WHEN year_num = 1975 THEN mean_body_mass_index END)) / AVG(CASE WHEN year_num = 1975 THEN mean_body_mass_index END)) * 100,1) AS percentage_change
FROM BMI_t
WHERE year_num IN (1975, 2016);

-- In 1975 the average was 22.4. Forty one years later, this number has gone up to 25.9. A increase of 15.8%.
-- 25.9 is classed as 'overweight' (25.0-29.9), meaning the average global population was overweight in 2016. 


-- [Q2] Which countries had the largest average BMI in 2016?

SELECT country, region, round(avg(mean_body_mass_index),1) as average_BMI_2016
FROM BMI_t
WHERE year_num = 2016
Group by country
order by average_BMI_2016 desc
limit 10;

-- In 2016, American Samoa had the largest average BMI with 32.5. This is classed as "Obese" (30.0 and above).
-- All the other countries in the top 10 also have a BMI of over 30 and therefore are classed as "Obese", with the exception of Kuwait.
-- The top 8 countries are all from the Pacific.


-- [Q3] Which countries had the smallest average BMI in 2016?

SELECT country, region, round(avg(mean_body_mass_index),1) as average_BMI_2016
FROM BMI_t
WHERE year_num = 2016
Group by country
order by average_BMI_2016 asc
limit 10;

-- Both Eritrea and Ethiopia had the smallest average BMI in 2016 with 20.5. This is classed as "Healthy Weight" (18.5-24.9).
-- The countries with the s average BMI are all from either Sub-Saharan Africa or Asia 


-- [Q4] Which regions had the largest average BMI in 2016?

SELECT region, round(avg(mean_body_mass_index),1) as average_BMI_2016
FROM BMI_t
WHERE year_num = 2016
Group by region
order by average_BMI_2016 desc;

-- The Pacific had the largest average BMI in 2016 of 29.3. This is just shy from "Obese" (30.0 and above).
-- North America is second with 27.4 and Middle East and Norht Africa is third with 27.2.
-- Sub-Saharan Africa has the smallest average of 23.3


-- [Q5] Which age groups have the largest BMI in 2016? How does this compare to 1975?

SELECT
    a.age_group,
    round((b.avg_bmi_1975),2) as bmi_1975,
    round((a.avg_bmi_2016),2) as bmi_2016,
    round((a.avg_bmi_2016 - b.avg_bmi_1975),2) AS bmi_change
FROM (
    SELECT
        age_group,
        avg(mean_body_mass_index) AS avg_bmi_2016
    FROM BMI_t
    Where year_num = 2016
	group by age_group 
) AS a
JOIN (
    SELECT
        age_group,
        avg(mean_body_mass_index) AS avg_bmi_1975
    FROM BMI_t
    WHERE year_num = 1975
    GROUP BY age_group
) AS b
ON a.age_group = b.age_group
ORDER BY bmi_change DESC;

-- In 2016, age group 45-54 had the largest average BMI of 27.31.
-- Follwed by 55-64 year olds with an average of 27.29.
-- The average BMI has increased for all age groups between 1975 and 2016. The biggest difference for age_group 55-64 which has gone up from 23.13 to 27.29.
-- Followed by 45-54 which has gone up from 23.25 to 27.31.
-- Age's 18-24 have seen to smallest change. From 21.11 to 23.31. 

-- [Q6] Which sex had the largest BMI in 2016? How does this compare to 1975?

SELECT
    a.sex,
    round((b.avg_bmi_1975),2) as bmi_1975,
    round((a.avg_bmi_2016),2) as bmi_2016,
    round((a.avg_bmi_2016 - b.avg_bmi_1975),2) AS bmi_change
FROM (
    SELECT
        sex,
        avg(mean_body_mass_index) AS avg_bmi_2016
    FROM BMI_t
    Where year_num = 2016
	group by sex 
) AS a
JOIN (
    SELECT
        sex,
        avg(mean_body_mass_index) AS avg_bmi_1975
    FROM BMI_t
    WHERE year_num = 1975
    GROUP BY sex
) AS b
ON a.sex = b.sex
ORDER BY bmi_change DESC;

-- In 2016, the average BMI of females was 26.32 compared to 25.46 for men. Slightly higher.
-- Females have also seen the biggest change between 1975 and 2016. Going up from 22.71 to 26.32.


-- [Q7] Which countries had the largest average BMI per region in 2016?

SELECT b.country, b.region, b.average_BMI_2016
FROM (
    SELECT 
        region,
        country,
        ROUND(AVG(mean_body_mass_index), 1) as average_BMI_2016
    FROM BMI_t
    WHERE year_num = 2016
    GROUP BY region, country
) AS b
JOIN (
    SELECT region, MAX(average_BMI_2016) AS max_average_BMI
    FROM (
        SELECT 
            region,
            ROUND(AVG(mean_body_mass_index), 1) as average_BMI_2016
        FROM BMI_t
        WHERE year_num = 2016
        GROUP BY region, country
    ) AS subquery
    GROUP BY region
) AS max_per_region
ON b.region = max_per_region.region AND b.average_BMI_2016 = max_per_region.max_average_BMI
ORDER BY b.average_BMI_2016 DESC;

-- The countries with the largest BMI per region are American Samoa for the Pacific with an average of 32.5
-- Saint Lucia for Latin America and the Caribbean with an average of 30.0
-- Kuwait for Middle East and North Africa with an average of 29.7
-- United States of America for North America with an average of 28.8
-- Iraq for Asia with an average of 28.6
-- Czech Republic and Turkey for Europe with an average of 28.0
-- South Africa for Sub-Saharan Africa with an average of 27.2 



-- [Q8] Which countries had the smallest average BMI per region in 2016?

SELECT b.country, b.region, b.average_BMI_2016
FROM (
    SELECT 
        region,
        country,
        ROUND(AVG(mean_body_mass_index), 1) as average_BMI_2016
    FROM BMI_t
    WHERE year_num = 2016
    GROUP BY region, country
) AS b
JOIN (
    SELECT region, MIN(average_BMI_2016) AS max_average_BMI
    FROM (
        SELECT 
            region,
            ROUND(AVG(mean_body_mass_index), 1) as average_BMI_2016
        FROM BMI_t
        WHERE year_num = 2016
        GROUP BY region, country
    ) AS subquery
    GROUP BY region
) AS max_per_region
ON b.region = max_per_region.region AND b.average_BMI_2016 = max_per_region.max_average_BMI
ORDER BY b.average_BMI_2016 ASC;

-- The countries with the smallest BMI per region are Eritrea and Ethiopia for Sub-Saharan Africa with an average of 20.5
-- Timor-Leste for Asia with an average of 21.1
-- Yemen for Middle East and North Africa with an average of 23.7
-- Papua New Guinea for Pacific with an average of 28.8
-- Haiti for Latin America and the Caribbean with an average of 25.1
-- Denmark and France for Europe with an average of 25.6
-- Greenland for North America with an average of 26.3 

-- [Q9] What percentage of countries had an average "healthy BMI" of between 18.5-24.9 in 2016? Underweight? Overweight? Obese?

SELECT
    year_num,
    SUM(CASE WHEN avg_bmi < 18.5 THEN 1 ELSE 0 END) AS underweight_countries,
    SUM(CASE WHEN avg_bmi >= 18.5 AND avg_bmi <= 24.9 THEN 1 ELSE 0 END) AS healthy_countries,
    SUM(CASE WHEN avg_bmi >= 25.0 AND avg_bmi <= 29.9 THEN 1 ELSE 0 END) AS overweight,
    SUM(CASE WHEN avg_bmi > 30.0 THEN 1 ELSE 0 END) AS obese,
    COUNT(*) AS total_countries,
    (SUM(CASE WHEN avg_bmi < 18.5 THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_underweight,
    (SUM(CASE WHEN avg_bmi >= 18.5 AND avg_bmi <= 24.9 THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_healthy,
     SUM(CASE WHEN avg_bmi >= 25.0 AND avg_bmi <= 29.9 THEN 1 ELSE 0 END) / COUNT(*) * 100 AS percentage_overweight,
    SUM(CASE WHEN avg_bmi > 30.0 THEN 1 ELSE 0 END)/ COUNT(*) * 100 AS percentage_obese
FROM (
    SELECT
        year_num,
        country,
        AVG(mean_body_mass_index) AS avg_bmi
    FROM BMI_t
    WHERE year_num = 2016
    GROUP BY year_num, country
) AS avg_bmi_per_country
GROUP BY year_num;

-- In 2016 the number of overweight countries was 61%
-- The number of healthy countries was 34%
-- The number of obese countries was 4%
-- 0% of countries were underweight


-- [Q10] How do the results from 2016 differ from 1975?

SELECT
    year_num,
    SUM(CASE WHEN avg_bmi < 18.5 THEN 1 ELSE 0 END) AS underweight_countries,
    SUM(CASE WHEN avg_bmi >= 18.5 AND avg_bmi <= 24.9 THEN 1 ELSE 0 END) AS healthy_countries,
    SUM(CASE WHEN avg_bmi >= 25.0 AND avg_bmi <= 29.9 THEN 1 ELSE 0 END) AS overweight,
    SUM(CASE WHEN avg_bmi > 30.0 THEN 1 ELSE 0 END) AS obese,
    COUNT(*) AS total_countries,
    (SUM(CASE WHEN avg_bmi < 18.5 THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_underweight,
    (SUM(CASE WHEN avg_bmi >= 18.5 AND avg_bmi <= 24.9 THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS percentage_healthy,
     SUM(CASE WHEN avg_bmi >= 25.0 AND avg_bmi <= 29.9 THEN 1 ELSE 0 END) / COUNT(*) * 100 AS percentage_overweight,
    SUM(CASE WHEN avg_bmi > 30.0 THEN 1 ELSE 0 END)/ COUNT(*) * 100 AS percentage_obese
FROM (
    SELECT
        year_num,
        country,
        AVG(mean_body_mass_index) AS avg_bmi
    FROM BMI_t
    GROUP BY year_num, country
) AS avg_bmi_per_country
GROUP BY year_num;

-- In 1975 74.5% were healthy, 12.5% overweight, 10.5% underweight, 0.5% obese
-- In 2016 34.0% were healthy, 61.0% overweight, 0.0% underweight, 4.0% obese.
-- In 1975, most countries have an average BMI of "healthy weight". In 2016 this number dropped to 34%.
-- The majority of countries have an average BMI "overweight" compared to just 12.5% in 1975.
-- There are no more countries with an average BMI of "underweight" compared to 10.5% in 1975.
-- 4% of countries have an average BMI of "obese" compared to 0.5% in 1975. 


-- [Q11] Which countries experienced the largest change in average BMI from 1975-2016? The smallest change? Negative change?

SELECT
    a.country,
    round((b.avg_bmi_1975),2) as bmi_1975,
    round((a.avg_bmi_2016),2) as bmi_2016,
    round((a.avg_bmi_2016 - b.avg_bmi_1975),2) AS bmi_change
FROM (
    SELECT
        country,
        avg(mean_body_mass_index) AS avg_bmi_2016
    FROM BMI_t
    Where year_num = 2016
	group by country 
) AS a
JOIN (
    SELECT
        country,
        avg(mean_body_mass_index) AS avg_bmi_1975
    FROM BMI_t
    WHERE year_num = 1975
    GROUP BY country
) AS b
ON a.country = b.country
ORDER BY bmi_change DESC;

-- Saint Lucia has experienced the largest change between 1975 and 2016. Going from an average BMI of 22.81 to 30.0. A change of 7.19.
-- Kiribati is second. Going from 23.18 to 29.19. A change of 6.01.
-- Followed by Samoa. Going from 26.21 to 32.08. A change of 5.87.

-- At the opposite end Bahrain has experienced a negative change. Going from 24.76 to 24.42. A change of -0.34. This is the only country with a negative change.
-- Nauru only experienced a small change between 1975 and 2016. Going from 30.52 to 30.67. A change of 0.15.
-- Japan also experienced a small change. Going from 22.02 to 22.69. A change of 0.67. 


-- [Q12] Has the country with the largest BMI in 2016, the same as 1975? How has BMI changed from 1975-2016?

SELECT
    year_num,
    country,
    round((avg_bmi),1) AS largest_avg_bmi
FROM (
    SELECT
        year_num,
        country,
        AVG(mean_body_mass_index) AS avg_bmi,
        ROW_NUMBER() OVER (PARTITION BY year_num ORDER BY AVG(mean_body_mass_index) DESC) AS rn
    FROM BMI_t
    GROUP BY year_num, country
) AS avg_bmi_per_country_per_year
WHERE rn = 1;

-- From 1975 - 1988 Nauru had the largest average BMI compared to any other country.
-- In 1975 Nauru was classed as an obese country (> 30.0).
-- In 1989 American Samoa became the country with the largest average BMI. American Samoa continues to have the largest average till this day.

  
-- [Q13] Has the country with the smallest BMI in 2016, the same as 1975? How has BMI changed from 1975-2016?

SELECT
    year_num,
    country,
    round((avg_bmi),1) AS lowest_avg_bmi
FROM (
    SELECT
        year_num,
        country,
        AVG(mean_body_mass_index) AS avg_bmi,
        ROW_NUMBER() OVER (PARTITION BY year_num ORDER BY AVG(mean_body_mass_index) ASC) AS rn
    FROM BMI_t
    GROUP BY year_num, country
) AS avg_bmi_per_country_per_year
WHERE rn = 1;

-- From 1975 to 1991 Bangladesh had the smallest average BMI compared to any other country.
-- In 1987 Bangladesh became the last country to move from "underweight" (< 18.5) to "healthy weight" (18.5 -24.9)
-- From 1992 to 2000 Viet Nam had the smallest average BMI compared to any other country.
-- From 2001 to 2004 Timor-Leste had the smallest average BMI compared to any other country.
-- From 2005 Ethiopia had the smallest average BMI compared to any other country. Both Ethiopia and Eritrea had the smallest average BMI in 2016 with a BMI of 20.5.
  


-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------





