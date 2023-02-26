/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Date]
      ,[SPY_Open]
      ,[SPY_High]
      ,[SPY_Low]
      ,[SPY_Close]
      ,[Adj_Close]
      ,[SPY_Volume]
  FROM [spyvsvix].[dbo].[spydataset2010]

SELECT [spydataset2010].[Date], ([SPY_Open] + [SPY_Close])/2 as SPY_PRICE, ([VIX_Open] + [VIX_Close])/2 as VIX_PRICE, [SPY_Volume]
FROM [spyvsvix].[dbo].[spydataset2010]
JOIN [spyvsvix].[dbo].[vixdataset2010]
ON [spydataset2010].[Date] = [vixdataset2010].[Date];


SELECT [spydataset2010].[Date], ([SPY_Open] + [SPY_Close])/2 as SPY_PRICE, ([VIX_Open] + [VIX_Close])/2 as VIX_PRICE, [SPY_Volume]
INTO SPYVIX2
FROM [spyvsvix].[dbo].[spydataset2010]
JOIN [spyvsvix].[dbo].[vixdataset2010]
ON [spydataset2010].[Date] = [vixdataset2010].[Date];

SELECT *,
       CASE WHEN LAG(SPY_PRICE) OVER (ORDER BY date) = 0
                THEN 0
            ELSE round(100*((SPY_PRICE / LAG(SPY_PRICE) OVER (ORDER BY date))-1),3)
       END AS SPY_CHANGE_PCT,
	   CASE WHEN LAG(VIX_PRICE) OVER (ORDER BY date) = 0
                THEN 0
            ELSE round(100*((VIX_PRICE / LAG(VIX_PRICE) OVER (ORDER BY date))-1),3)
       END AS VIX_CHANGE_PCT
	   INTO SPYVIXF1
FROM SPYVIX2;

SELECT
  FORMAT(date, 'yyyy-MM') AS year_month,
  COUNT(*) AS Business_Days,
  AVG(SPY_Price) as AVG_SPY,
  AVG(VIX_Price) as AVG_VIX,
  ROUND(AVG(CAST(SPY_CHANGE_PCT AS decimal(10, 2))), 2) AS AVG_SPY_CHANGE_PCT,
  ROUND(AVG(CAST(VIX_CHANGE_PCT AS decimal(10, 2))), 2) AS AVG_VIX_CHANGE_PCT
  INTO SPXVIXF2
FROM
  SPYVIXF1
GROUP BY
  FORMAT(date, 'yyyy-MM');


SELECT * from SPYVIXF1; --Daily Data
SELECT * from SPXVIXF2; --Monthly Aggregates

-- Simple observations

--1. Average Business Days in a month, over this period?
SELECT AVG(Business_Days) as AVG_BD_Per_Month
from SPXVIXF2; -- The resulting query indicates that in the long term there is approximately 20 business days per month, which I found to be surprising.

--2. Average daily S&P 500 Percent growth during this period?
SELECT round(AVG(SPY_CHANGE_PCT),4) as AVG_DAILY_CHANGE
from SPYVIXF1;--The result, 0.0434%, shows just how powerful compounding can be! 1*1.0004^3300 = 3.74! At such a minute rate, the S&P nearly quadrupled over a 13 year period.

--3. Average daily S&P 500 Decline, from the subset of red days and the number of red days
SELECT round(AVG(SPY_CHANGE_PCT),4) as AVG_DAILY_CHANGE, count(SPY_CHANGE_PCT) as Red_Days
from SPYVIXF1
where SPY_CHANGE_PCT < 0;--We see that there have been 1440 red days, with the average declining day being -0.64% (which makes sense, given that we removed green days)

--4. Average daily S&P 500 Increase, from the subset of green days and the number of green days
SELECT round(AVG(SPY_CHANGE_PCT),4) as AVG_DAILY_CHANGE, count(SPY_CHANGE_PCT) as Green_Days
from SPYVIXF1
where SPY_CHANGE_PCT > 0;--We see that there have been 1851 green days, with the average green day being +0.58%. This provides evidence supporting the statenment "stairs up, elevator down"

--5. Average daily VIX Change during S&P 500 Decline, from the subset of red days
SELECT round(AVG(VIX_CHANGE_PCT),4) as AVG_DAILY_CHANGE
from SPYVIXF1
where SPY_CHANGE_PCT < 0;--The vix on average appreciates 4.33% on a red day

--6. Average daily VIX Change during S&P 500 increase, from the subset of green days
SELECT round(AVG(VIX_CHANGE_PCT),4) as AVG_DAILY_CHANGE
from SPYVIXF1
where SPY_CHANGE_PCT > 0;--The VIX on average depreciates 3.04% on a red day

--7. Total VIX green days
SELECT count(VIX_CHANGE_PCT) as Green_Days
from SPYVIXF1
where VIX_CHANGE_PCT > 0;--We see that there have been 1523 green days, more than the 1440 figure of SPY red days (VIX and SPY have a generally inverse relationship). It is likely that the VIX rises on certain SPY green days

--8. Total VIX red days
SELECT count(VIX_CHANGE_PCT) as Green_Days
from SPYVIXF1
where VIX_CHANGE_PCT < 0;--Similarly, we see that there have been 1770 red days, less than the 1851 figure of SPY green days.

--9. Total VIX red days when market is down
SELECT count(VIX_CHANGE_PCT) as Red_Days
from SPYVIXF1
where VIX_CHANGE_PCT < 0 AND SPY_CHANGE_PCT < 0;--Very interestingly, there are 296 instances where the vix depreciates on a red SPY day

--10. Total VIX green days when market is up
SELECT count(VIX_CHANGE_PCT) as Red_Days
from SPYVIXF1
where VIX_CHANGE_PCT > 0 AND SPY_CHANGE_PCT > 0;--Just as interestingly, there are 378 instances where the VIX appreciates on a green SPY day

--11. Total VIX red days when market is up
SELECT count(VIX_CHANGE_PCT) as Red_Days
from SPYVIXF1
where VIX_CHANGE_PCT < 0 AND SPY_CHANGE_PCT > 0;--The VIX depreciates in 1471/1770 instances (83.1%) when the market is up

--12. Total VIX green days when market is down
SELECT count(VIX_CHANGE_PCT) as Red_Days
from SPYVIXF1
where VIX_CHANGE_PCT > 0 AND SPY_CHANGE_PCT < 0;-- The VIX appreciates 1142/1440 instances (79.3%) when the market is down. It is more likely for the VIX to fall on a green day than for the VIX to fall on a red day. 

--13. Average VIX Change
SELECT AVG(VIX_CHANGE_PCT) as AVG_VIX_CHANGE
from SPYVIXF1; --Surprisingly the average VIX change during this period is 0.18%, which would have resulted in astronomical gains over the period, which did not occur. This is likely the result of rebalancing the calculation to adjust for contract rollover.

--14. SPY days >+2%
SELECT COUNT(SPY_CHANGE_PCT)
from SPYVIXF1
where SPY_CHANGE_PCT >2; -- 56/1851 (3.0%) green days saw gains >2%

--15. SPY days <-2%
SELECT COUNT(SPY_CHANGE_PCT)
from SPYVIXF1
where SPY_CHANGE_PCT <-2 -- 65/1440 (4.5%) green days saw gains >2%

--16. Average movement where SPY days >+2%
SELECT AVG(SPY_CHANGE_PCT)
from SPYVIXF1 
where SPY_CHANGE_PCT >2; -- The average movement given that the SPY is at least +2% is 2.83%

--17. Average movement where SPY days <-2%
SELECT AVG(SPY_CHANGE_PCT)
from SPYVIXF1 
where SPY_CHANGE_PCT <-2; -- The average movement given that the SPY is at least -2% is 3.12%

--18. Worst 10 days of the stock market
SELECT TOP 11 SPY_CHANGE_PCT, Date, VIX_Change_PCT
from SPYVIXF1 
order by SPY_CHANGE_PCT asc; -- Ignoring the null value, the top 3 worst day for the S&P 500 occurred within a week apart, during the initial COVID crash. Surprisingly the corresponding VIX value for the worst day is quite small. 

--19. Best 10 days of the stock market
SELECT TOP 10 SPY_CHANGE_PCT, Date, VIX_Change_PCT
from SPYVIXF1 
order by SPY_CHANGE_PCT desc; -- The VIX rose on three of the top 10 best days for the S&P 500. The greatest single day increase is 5.8%, during the COVID crash. 8 of the top 10 best days were during March 2020. 

--20. Avg best 10 days of the stock market
SELECT AVG(SPY_CHANGE_PCT)
from SPYVIXF1 
where SPY_CHANGE_PCT >3.4949; 

--21. Avg worst 10 days of the stock market
SELECT AVG(SPY_CHANGE_PCT)
from SPYVIXF1 
where SPY_CHANGE_PCT <-4.2839; 