select * from encoded_narrative;
-- ===============================================================================================================================================
-- 1. Weather Conditions
-- What is the distribution of crashes under different weather conditions? ===============================
SELECT
    WEATHER_COND_CD,
    SUM(CRASH_SEVERITY_CD = 'Property Damage Only') AS O_Count,
    SUM(CRASH_SEVERITY_CD = 'Injury Possible') AS C_Count,
    SUM(CRASH_SEVERITY_CD = 'Minor Injury Suspected') AS B_Count,
    SUM(CRASH_SEVERITY_CD = 'Serious Injury Suspected') AS A_Count,
    SUM(CRASH_SEVERITY_CD = 'Fatal') AS K_Count,
    COUNT(*) AS Total_Count
FROM
    encoded_narrative
WHERE
    WEATHER_COND_CD IS NOT NULL
GROUP BY
    WEATHER_COND_CD
ORDER BY
    WEATHER_COND_CD;
    
SET SESSION group_concat_max_len = 1000000;
    

SET @sql = (
    SELECT GROUP_CONCAT(DISTINCT
            CONCAT(
                'SUM(CRASH_SEVERITY_CD = "', CRASH_SEVERITY_CD, '") AS ', REPLACE(CRASH_SEVERITY_CD, ' ', '_'), '_Count'
            )
        ) AS query
    FROM encoded_narrative
);

-- Final query using the generated column counts
SET @final_query = CONCAT(
    'SELECT WEATHER_COND_CD, ', @sql, ', COUNT(*) AS Total_Count
    FROM encoded_narrative
    WHERE WEATHER_COND_CD IS NOT NULL
    GROUP BY WEATHER_COND_CD
    ORDER BY WEATHER_COND_CD;'
);

-- Execute the final query
PREPARE dynamic_query FROM @final_query;
EXECUTE dynamic_query;
DEALLOCATE PREPARE dynamic_query;

-- ===============================================================================================================================================
-- 2. Crash Types:
-- What are the most common crash types, and how do they correlate with crash severity?===============================
SET SESSION group_concat_max_len = 1000000;

SET @sql = (
    SELECT GROUP_CONCAT(DISTINCT
            CONCAT(
                'SUM(CRASH_TYPE_CD = "', CRASH_TYPE_CD, '") AS `', REPLACE(CRASH_TYPE_CD, ' ', '_'), '_Count`'
            )
        ) AS query
    FROM encoded_narrative
);

-- Final query using the generated column counts
SET @final_query = CONCAT(
    'SELECT CRASH_SEVERITY_CD, ', @sql, ', COUNT(*) AS Total_Count
    FROM encoded_narrative
    WHERE CRASH_SEVERITY_CD IS NOT NULL
    GROUP BY CRASH_SEVERITY_CD
    ORDER BY CRASH_SEVERITY_CD;'
);

-- Execute the final query
PREPARE dynamic_query FROM @final_query;
EXECUTE dynamic_query;
DEALLOCATE PREPARE dynamic_query;


-- Is there a relationship between crash types and the presence of distracted drivers? ===============================
SELECT
    CRASH_TYPE_CD,
    SUM(DISTRACTED_DRIVER_IND = 'Y') AS Distracted_Count,
    SUM(DISTRACTED_DRIVER_IND = 'N') AS Not_Distracted_Count,
    COUNT(*) AS Total_Count
FROM encoded_narrative
WHERE
    CRASH_TYPE_CD IS NOT NULL
GROUP BY
    CRASH_TYPE_CD
ORDER BY
    CRASH_TYPE_CD;
    
-- Are crashes in work zones associated with specific crash types? ===============================
SELECT
    CRASH_TYPE_CD,
    SUM(ODPS_LOC_IN_WORK_ZONE_CD = 'Activity Area') AS Activity_Count,
    SUM(ODPS_LOC_IN_WORK_ZONE_CD = 'Advance Warning Area') AS Advance_Count,
    SUM(ODPS_LOC_IN_WORK_ZONE_CD = 'Before The 1St Work Zone Warning Sign') AS Before_Count,
    SUM(ODPS_LOC_IN_WORK_ZONE_CD = 'Termination Area') AS Termination_Count,
    SUM(ODPS_LOC_IN_WORK_ZONE_CD = 'Transition Area') AS Transition_Count,
    -- Add more severity columns as needed
    COUNT(*) AS Total_Count
FROM encoded_narrative
WHERE
    CRASH_TYPE_CD IS NOT NULL
GROUP BY
    CRASH_TYPE_CD
ORDER BY
    CRASH_TYPE_CD;
-- ===============================================================================================================================================
-- 3. Crash Severity:
select count(OBJECTID), CRASH_SEVERITY_CD
from encoded_narrative
group by CRASH_SEVERITY_CD;

-- What is the distribution of crash severity across different years? ===============================
SELECT
    CRASH_YR,
    CRASH_SEVERITY_CD,
    COUNT(*) AS Count
FROM encoded_narrative
WHERE
    CRASH_YR IS NOT NULL
    AND CRASH_SEVERITY_CD IS NOT NULL
GROUP BY
    CRASH_YR, CRASH_SEVERITY_CD
ORDER BY
    CRASH_YR, CRASH_SEVERITY_CD;

-- Are crashes during specific weather conditions more likely to result in severe outcomes? ===============================
SELECT
    WEATHER_COND_CD,
    CRASH_SEVERITY_CD,
    COUNT(*) AS Count
FROM encoded_narrative
WHERE
    WEATHER_COND_CD IS NOT NULL
    AND CRASH_SEVERITY_CD IS NOT NULL
GROUP BY
    WEATHER_COND_CD, CRASH_SEVERITY_CD
ORDER BY
    WEATHER_COND_CD, CRASH_SEVERITY_CD;

-- How does crash severity vary based on the functional class of the road? ===============================
SELECT
    FUNCTIONAL_CLASS_CD,
    CRASH_SEVERITY_CD,
    COUNT(*) AS Count
FROM encoded_narrative
WHERE
    FUNCTIONAL_CLASS_CD IS NOT NULL
    AND CRASH_SEVERITY_CD IS NOT NULL
GROUP BY
    FUNCTIONAL_CLASS_CD, CRASH_SEVERITY_CD
ORDER BY
    FUNCTIONAL_CLASS_CD, CRASH_SEVERITY_CD;
-- ===============================================================================================================================================
-- 4. Days of the Week, Months, Time of day:
-- select * from encoded_narrative;
-- On which days of the week do most crashes occur? Is there a pattern? ===============================
SELECT
	COUNT(*) as Crash_Count,
    CASE DAY_IN_WEEK_CD
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
        WHEN 7 THEN 'Sunday'
        ELSE 'Unknown Day'
    END as Day_of_Week
FROM encoded_narrative
GROUP BY DAY_IN_WEEK_CD
ORDER BY Crash_Count DESC;

-- Are there any significant variations in crash frequency across different months? ===============================
SELECT
	COUNT(*) as Crash_Count,
    CASE MONTH_OF_CRASH
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE 'Unknown Month'
    END as Month_of_Crash
FROM encoded_narrative
GROUP BY MONTH_OF_CRASH
ORDER BY Crash_Count DESC;

-- How does crash severity change based on the time of day? ===============================
SELECT
    CASE
        WHEN HOUR_OF_CRASH >= 0 AND HOUR_OF_CRASH < 6 THEN 'Night'
        WHEN HOUR_OF_CRASH >= 6 AND HOUR_OF_CRASH < 12 THEN 'Morning'
        WHEN HOUR_OF_CRASH >= 12 AND HOUR_OF_CRASH < 18 THEN 'Afternoon'
        WHEN HOUR_OF_CRASH >= 18 THEN 'Evening'
        ELSE 'Unknown'
    END AS TimeOfDayCategory,
    CRASH_SEVERITY_CD,
    COUNT(*) as CrashCount
FROM encoded_narrative
GROUP BY
    TimeOfDayCategory, CRASH_SEVERITY_CD
ORDER BY
    TimeOfDayCategory, CRASH_SEVERITY_CD;
    
-- How does crash type change based on the time of day? ===============================
SELECT
    CASE
        WHEN HOUR_OF_CRASH >= 0 AND HOUR_OF_CRASH < 6 THEN 'Night'
        WHEN HOUR_OF_CRASH >= 6 AND HOUR_OF_CRASH < 12 THEN 'Morning'
        WHEN HOUR_OF_CRASH >= 12 AND HOUR_OF_CRASH < 18 THEN 'Afternoon'
        WHEN HOUR_OF_CRASH >= 18 THEN 'Evening'
        ELSE 'Unknown'
    END AS TimeOfDayCategory,
    CRASH_TYPE_CD,
    COUNT(*) as CrashCount
FROM encoded_narrative
GROUP BY
    TimeOfDayCategory, CRASH_TYPE_CD
ORDER BY
    TimeOfDayCategory, CRASH_TYPE_CD;
    
-- ===============================================================================================================================================
-- 5. Speed Numbers:
-- What is the average speed of units involved in crashes? ===============================
SELECT
	AVG(U1_UNIT_SPEED_NBR) as AVG_U1_Speed,
    AVG(U2_UNIT_SPEED_NBR) as AVG_U2_Speed
FROM encoded_narrative
WHERE U1_UNIT_SPEED_NBR IS NOT NULL
and U2_UNIT_SPEED_NBR IS NOT NULL;
    
-- Is there a correlation between speed and crash severity? ===============================
SELECT
    CRASH_SEVERITY_CD,
    AVG(U1_UNIT_SPEED_NBR) AS AverageSpeed
FROM
    encoded_narrative
WHERE
    U1_UNIT_SPEED_NBR IS NOT NULL -- Exclude rows where speed is null
GROUP BY
    CRASH_SEVERITY_CD
ORDER BY
    CRASH_SEVERITY_CD;
    
-- Is there a correlation between speed and crash type? ===============================
SELECT
    CRASH_TYPE_CD,
    AVG(U1_UNIT_SPEED_NBR) AS AverageSpeed
FROM
    encoded_narrative
WHERE
    U1_UNIT_SPEED_NBR IS NOT NULL -- Exclude rows where speed is null
GROUP BY
    CRASH_TYPE_CD
ORDER BY
    CRASH_TYPE_CD;
    
-- How does the speed of units vary based on road conditions? ===============================
SELECT
    ROAD_COND_PRIMARY_CD,
    AVG(U1_UNIT_SPEED_NBR) AS AverageSpeed
FROM
    encoded_narrative
WHERE
    ROAD_COND_PRIMARY_CD IS NOT NULL -- Exclude rows where speed is null
GROUP BY
    ROAD_COND_PRIMARY_CD
ORDER BY
    ROAD_COND_PRIMARY_CD;
    
-- ===============================================================================================================================================
-- 6. Age Numbers:
-- Are younger drivers more likely to be involved in certain types of crashes? ===============================
SELECT
    DISTINCT ODOT_YOUNG_DRIVER_IND,
    CRASH_TYPE_CD,
    COUNT(*) as Crash_Count
FROM
    encoded_narrative
GROUP BY ODOT_YOUNG_DRIVER_IND
, CRASH_TYPE_CD
ORDER BY ODOT_YOUNG_DRIVER_IND ASC;

-- Are younger drivers more likely to be involved in certain severity of crashes? ===============================
SELECT
    DISTINCT ODOT_YOUNG_DRIVER_IND,
    CRASH_SEVERITY_CD,
    COUNT(*) as Crash_Count
FROM
    encoded_narrative
GROUP BY ODOT_YOUNG_DRIVER_IND
, CRASH_SEVERITY_CD
ORDER BY ODOT_YOUNG_DRIVER_IND ASC;

-- Are younger drivers more likely to speed? ===============================
SELECT
    DISTINCT ODOT_YOUNG_DRIVER_IND,
    ODPS_SPEED_IND,
    COUNT(*) as Crash_Count
FROM
    encoded_narrative
GROUP BY ODOT_YOUNG_DRIVER_IND
, ODPS_SPEED_IND
ORDER BY ODOT_YOUNG_DRIVER_IND ASC;

-- Are younger drivers more to be under the influence? ===============================
SELECT
    DISTINCT ODOT_YOUNG_DRIVER_IND,
    U1_DISTRACTED_BY_1_CD,
    U1_IS_ALCOHOL_SUSPECTED,
    U1_IS_MARIJUANA_SUSPECTED,
    COUNT(*) as Crash_Count
FROM
    encoded_narrative
WHERE
    U1_DISTRACTED_BY_1_CD IS NOT NULL 
GROUP BY ODOT_YOUNG_DRIVER_IND,
	U1_DISTRACTED_BY_1_CD,
    U1_IS_ALCOHOL_SUSPECTED,
    U1_IS_MARIJUANA_SUSPECTED
ORDER BY ODOT_YOUNG_DRIVER_IND ASC;

-- ===============================================================================================================================================
-- 7. Vehicle Types and Work Zones:
-- Are specific types of vehicles more prone to crashes in work zones? ===============================
-- How does the presence of work zones affect the crash severity and type? ===============================
-- Is there a relationship between crash severity and the type of roadway (freeway, non-freeway)? ===============================
-- ===============================================================================================================================================
-- 8. Driver Characteristics:
-- What is the distribution of distracted drivers among different age groups? ===============================
-- Are certain pre-crash actions more common among specific demographics? ===============================
-- Do age and gender play a role in determining the type of crashes? ===============================
-- ===============================================================================================================================================
-- 9. Special Conditions:
-- How does crash severity change under different lighting conditions? ===============================
-- Are crashes in school zones more likely to involve young drivers? ===============================
-- Is there an association between severe crashes and specific roadway characteristics (e.g., intersections, ramps)? ===============================
-- ===============================================================================================================================================
-- 10. Unrestrained Occupants and Crash Outcomes:
-- What percentage of crashes involve unrestrained occupants, and how does it impact crash outcomes? ===============================
-- Are unrestrained occupants more likely to be involved in severe crashes? ===============================
-- Is there a relationship between unrestrained occupants and the type of roadway? ===============================
-- ===============================================================================================================================================
-- 11. Autonomous Vehicles:
-- How frequently are autonomous vehicles involved in crashes? ===============================
-- Is there a pattern in the pre-crash actions of autonomous vehicles? ===============================
-- Are crashes involving autonomous vehicles more likely to occur during specific weather conditions? ===============================
-- ===============================================================================================================================================