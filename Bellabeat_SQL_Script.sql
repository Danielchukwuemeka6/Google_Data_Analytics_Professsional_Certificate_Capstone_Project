              /** BELLABEAT CASE STUDY  ***/
 

              /** STEP I:  ASK 
			  1.What are some trends in smartdeviceusage? 
			  2.How could thesetrends apply to Bellabeat customers? 
			  3.How could these trends help infuence Bellabeat marketing strategy? **/



			  /**STEP II: DATA PREPARATION**/ 

-- 1. To view all the datasets 
SELECT *
  FROM daily_activity

SELECT *
  FROM sleep_day

SELECT *
  FROM weight


             /** STEP III: DATA PROCESSING **/ 

-- 2. unique individual reporting for activity  --33
SELECT COUNT (DISTINCT id) AS unique_id
 FROM daily_activity

-- 3. unique individual reporting for weight    -- 8 
SELECT COUNT (DISTINCT id) AS unique_id
 FROM weight

-- 4. unique individual reporting for sleep     -- 24
 SELECT COUNT (DISTINCT id) AS unique_id
 FROM sleep_day


--5. getting the start_date and end_date of activities tracked in activity table
SELECT 
  MIN(activity_date) AS start_date,        --start_date is            2016-04-12
  MAX(activity_date) AS end_date	       --end_date   is            2016-05-12
FROM daily_activity


--6. finding start_date and end_data of  sleep_day table
SELECT 
  MIN(sleep_date)     AS start_date,        --start_date is            2016-04-12
  MAX(sleep_date)     AS end_date		    --end_date   is            2016-05-12
FROM sleep_day

--7. finding start_date and end_data of  weight table
SELECT 
  MIN(Date)     AS start_date,        --start_date is                2016-04-12
  MAX(Date)     AS end_date			  --end_date   is                 2016-05-12
FROM weight

--8. checking for duplicate rows in activity data 

SELECT id, activity_date, COUNT(*) AS num_row
FROM daily_activity
GROUP BY Id, activity_date
HAVING COUNT(*) > 1;                                              -- no duplicate 


--9. checking for duplicate rows in sleep_day data 

SELECT Id, sleep_date, COUNT(*)  AS num_row                         -- no duplicate
FROM sleep_day 
GROUP BY Id , sleep_date
HAVING COUNT(*) >1

--10. checking for duplicate for weight table

SELECT Id, Date, COUNT(*) AS num_row                             -- no duplicate        
FROM weight
GROUP BY Id , Date
HAVING COUNT(*) >1 



          /** STEP IV: ANALYZING DATA **/ 

--11. checking the average number of calories burned by average users
SELECT AVG(Calories) AS avg_calories_burned
FROM daily_activity													-- 2364 calories 

--12. average number of steps by average users
SELECT AVG(total_steps) AS avg_steps								--8338 walk steps
FROM daily_activity

--13. Average distance (in miles) walked by our members in a day
SELECT AVG(total_distance) AS avg_distance						    --5.99 miles
FROM daily_activity

--14. entries recorded by day of the week:
--Sunday = 1...Saturday = 7
SELECT															--
    CASE WHEN day_of_week = 1 THEN 'SUN'
         WHEN day_of_week = 2 THEN 'MON'
         WHEN day_of_week = 3 THEN 'TUE'
         WHEN day_of_week = 4 THEN 'WED'
         WHEN day_of_week = 5 THEN 'THU'
         WHEN day_of_week = 6 THEN 'FRI'
         WHEN day_of_week = 7 THEN 'SAT'
    END AS Day,
    entries
FROM (
    SELECT 
        DATEPART(WEEKDAY, activity_date) AS day_of_week,
        COUNT(Id) AS entries
    FROM 
       daily_activity
    GROUP BY 
        DATEPART(WEEKDAY, activity_date)
    ) AS DayCounts
ORDER BY 
    day_of_week;

--- We've discovered that our users sleep more on weekends and register less activity.  
-- 15. Daily breakdown of our users activity level throughout the day as percentages
SELECT 
    ROUND((ROUND(AVG(very_active_prcnt), 2) / 84) * 100, 1) AS avg_very_active_percent,
    ROUND((ROUND(AVG(fairly_active_prcnt), 2) / 84) * 100, 1) AS avg_fairly_active_percent,
    ROUND((ROUND(AVG(lightly_active_prcnt), 2) / 84) * 100, 1) AS avg_lightly_active_percent,
    ROUND((ROUND(AVG(sedentary_minutes_prcnt), 2) / 84) * 100, 1) AS avg_sedentary_minutes_percent
FROM (
    SELECT
        ROUND((very_active_minutes / 1440.0) * 100, 2) AS very_active_prcnt,
        ROUND((fairly_active_minutes / 1440.0) * 100, 2) AS fairly_active_prcnt,
        ROUND((lightly_active_minutes / 1440.0) * 100, 2) AS lightly_active_prcnt,
        ROUND((sedentary_minutes / 1440.0) * 100, 2) AS sedentary_minutes_prcnt
    FROM daily_activity
) AS ActivityPercentages;

/*
Very Active = 1.8%, Fairly Active = 1.1%, Lightly Active = 15.9%, Sedentary = 81.9%. 
We find that users on average spend most of their days in a sedentary state of activity. 
*/
-- 16. Relationship between Calories and Total Steps:
SELECT
  total_steps, 
  calories
FROM daily_activity
WHERE Calories > 400 AND total_steps > 500 -- Filtering out anybody burning less than 400 and TotalSteps under 500. These results could skew our results. 
ORDER BY total_steps DESC  
--- The more steps taken, the more calories burned by the user.

/*
WEIGHT
*/
-- 17. Average weight recorded by our users:
SELECT
  ROUND(avg(WeightPounds),0) as avg_weight_recorded
FROM
 weight-- 159 is the average weight (in lbs)
-- 12. AVG BMI(Body Mass Index) for our users

SELECT ROUND(AVG(BMI),1) as avg_bmi
FROM weight -- 25.2 is the average BMI



-- 18. What is the relationship between different sedentary levels and weight?
SELECT DISTINCT  
  weight_copy.WeightPounds,
  daily_activity.sedentary_minutes
FROM  weight_copy
LEFT JOIN daily_activity
ON weight_copy.Id = daily_activity.id AND weight_copy.Date = daily_activity.activity_date  -- in order to avoid repeated rows we added a second condition
/*
We converted the results from SQL to Excel and divided the sedentary levels
into three groups before calculating the average weight of each.
We noticed that people who engage in more sedentary behavior tend to weigh more than others.
*/
-- 19. Relationship between total steps and weight recorded:
SELECT DISTINCT -- return distinct values for weight and total in order to avoid repeated rows 
  weight.WeightPounds,
  steps.total_steps
FROM  weight
LEFT JOIN daily_activity steps -- LEFT JOIN used to combine the results from daily_activity with weight
ON weight.Id = steps.Id
--- We find that in general the higher weight a user records, the less steps they will take. 
-- 20. What is the AVG amount of time spent sleeping / spent in bed total / time spent in bed not sleeping? 
SELECT
  ROUND(avg(total_minutes_asleep/60),1) AS avg_time_sleep_hrly, -- avg time spent in bed sleeping
  ROUND(avg(total_minute_in_bed/60),2) AS avg_time_bed_hrly, -- avg time spent in bed total
  ROUND(avg(total_minute_in_bed) - avg(total_minutes_asleep),2) AS time_bed_aftersleep -- avg time spent in bed not sleeping

FROM
 sleep_day
 
--   7 hours spent sleeping
--   Total time on bed = 7hrs:39 minutes
--   39 minutes spent in bed, not sleeping

-- 21. Sleep patterns throughout the week: 
--Sleep
--- What day of the week do users sleep the most?
--- 1=Sunday, 7=Sat
SELECT 
  CASE 
    WHEN DATEPART(WEEKDAY, sleep_date) = 1 THEN 'SUN'
    WHEN DATEPART(WEEKDAY, sleep_date) = 2 THEN 'MON'
    WHEN DATEPART(WEEKDAY, sleep_date) = 3 THEN 'TUE'
    WHEN DATEPART(WEEKDAY, sleep_date) = 4 THEN 'WED'
    WHEN DATEPART(WEEKDAY, sleep_date) = 5 THEN 'THU'
    WHEN DATEPART(WEEKDAY, sleep_date) = 6 THEN 'FRI'
    WHEN DATEPART(WEEKDAY, sleep_date) = 7 THEN 'SAT'
  END AS DAY, 
  ROUND(AVG(total_minutes_asleep / 60.0), 2) AS total_hours_sleep
FROM (
  SELECT
    sleep_date,
    total_minutes_asleep
  FROM 
    sleep_day
) AS subquery
GROUP BY
  DATEPART(WEEKDAY, sleep_date)
ORDER BY
  total_hours_sleep DESC;


 --- Users spend 7hrs on average sleeping, SUN and WED is the day that users record the most sleep while getting the least amount on TUES and THU
 
 -- 22. The impact of sleep on daily activity:
SELECT
  ROUND((sleep_day.total_minutes_asleep/60),2) AS Hours_Sleep, 
  daily_activity.fairly_active_minutes, 
  daily_activity.lightly_active_minutes, 
  daily_activity.very_active_minutes, 
  daily_activity.sedentary_minutes
FROM sleep_day
LEFT JOIN daily_activity
ON sleep_day.id = daily_activity.id AND sleep_day.sleep_date  = daily_activity.activity_date

/* 
for the following activity we decided to focus on sedentary and lightly active minutes and 
their relationship to sleep We discovered that when people sleep around 7-8 hours, they 
have the highest amount of energy levels for both sedentary and lightly active 
we also discovered that the user's daily activity decreases significantly depending on how
much or how little they sleep.
*/



