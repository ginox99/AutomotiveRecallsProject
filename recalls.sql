--Top 12 most frequently recalled manufacturers in the past 20 years
SELECT  manufacturer, COUNT(*) AS num_recalls
FROM recalls
WHERE recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
GROUP BY manufacturer
ORDER BY num_recalls DESC
LIMIT 12

--Top 12 manufacturers by number of affected vehicles
SELECT  manufacturer, SUM(potentially_affected) AS num_affected
FROM recalls
WHERE recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
GROUP BY manufacturer
HAVING SUM(potentially_affected) IS NOT NULL
ORDER BY num_affected DESC
LIMIT 12

--Number of recalls per year
SELECT EXTRACT(YEAR FROM report_received_date) AS year, 
COUNT(*) AS num_recalls
FROM recalls
WHERE recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
GROUP BY year
ORDER BY year

--Number of affected vehicles per year
SELECT EXTRACT(YEAR FROM report_received_date) AS year, 
SUM(potentially_affected) AS num_affected
FROM recalls
WHERE recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
GROUP BY year
ORDER BY year

--Number of recalls monthly
SELECT EXTRACT(MONTH FROM report_received_date) AS month,
COUNT(*) AS num_recalls
FROM recalls
WHERE recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
GROUP BY month
ORDER BY month 

--Number of recalls seasonally
WITH MonthlyRecallCounts AS (
SELECT EXTRACT(MONTH FROM report_received_date) AS month,
       COUNT(*) AS num_recalls
FROM recalls
WHERE recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
GROUP BY month
)

SELECT season, SUM(num_recalls) AS season_recalls
FROM (SELECT CASE
            WHEN month IN (3, 4, 5) THEN 'Spring'
            WHEN month IN (6, 7, 8) THEN 'Summer'
            WHEN month IN (9, 10, 11) THEN 'Autumn'
            WHEN month IN (12, 1, 2) THEN 'Winter'
        END AS season,
        num_recalls
        FROM MonthlyRecallCounts
	    ) AS SeasonalCounts
GROUP BY season
ORDER BY season_recalls

--Top 10 common components failure
SELECT component, COUNT(*) AS num_recalls
FROM recalls
WHERE recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
GROUP BY component
ORDER BY num_recalls DESC
LIMIT 10

--Percentage of impact of recall on driving ability
WITH RecallsCounts AS(
SELECT COUNT(nhtsa_id ) AS not_driveable
FROM recalls
WHERE park_outside = 'Yes' or do_not_drive = 'Yes'
AND recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
),
     TotalRecalls AS(
SELECT COUNT(nhtsa_id)	AS total_recalls
FROM recalls
WHERE recall_type = 'Vehicle'
AND report_received_date BETWEEN '2003-01-01' AND '2022-12-31'
)

SELECT not_driveable, 
       total_recalls, 
       (not_driveable * 100.0 / total_recalls ) AS percentage_impact
FROM RecallsCounts, TotalRecalls;
