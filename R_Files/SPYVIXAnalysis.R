#First we may import our source files to the session

SPYVIXF1 <- read.csv("SPYVIXF1.csv")

SPYVIXF2 <- read.csv("SPYVIXF2.csv")

#Q1. Find the average number of business days per month throughout the period January 2010-February 2023

mean(SPYVIXF2$Business_Days)
#There are 20.87 business days in the average month

#Q2. What is the average daily percent return of the SPDR S&P 500 Index ETF during this period?

SPYVIXF1$SPY_CHANGE_PCT <- as.numeric(SPYVIXF1$SPY_CHANGE_PCT)
mean(SPYVIXF1$SPY_CHANGE_PCT, na.rm = TRUE)

# We observe that the average daily return over 13 years is approximately 0.043%
#Q3. Find the total number of days where the S&P 500 ETF declined from the previous day's close and percentage of total days where this occurs. Additionally, find the average return of the S&P 500 ETF given that the instrument declined from the previous day.

negative_SPY_days <- sum(SPYVIXF1$SPY_CHANGE_PCT < 0, na.rm = TRUE)
#There are 1440 days where the S&P 500 declined from the period day
all_days <- sum(SPYVIXF1$SPY_CHANGE_PCT > -30, na.rm = TRUE)
negative_SPY_days/all_days
#Approximately 43.6% of days observe the S&P 500 declining.

mean(SPYVIXF1$SPY_CHANGE_PCT[SPYVIXF1$SPY_CHANGE_PCT < 0], na.rm = TRUE)
#The average red day sees the S&P 500 declining by 0.644%

#Q4. Find the total number of days where the S&P 500 ETF appreciated from the previous day's close and percentage of total days where this occurs. Additionally, find the average return of the S&P 500 ETF given that the instrument appreciated from the previous day.

positive_SPY_days <- sum(SPYVIXF1$SPY_CHANGE_PCT > 0, na.rm = TRUE)
#There are 1851 days where the S&P 500 appreciated from the period day
all_days <- sum(SPYVIXF1$SPY_CHANGE_PCT > -30, na.rm = TRUE)
positive_SPY_days/all_days
#Approximately 56.1% of days observe the S&P 500 appreciating

mean(SPYVIXF1$SPY_CHANGE_PCT[SPYVIXF1$SPY_CHANGE_PCT > 0], na.rm = TRUE)
#The average green day sees the S&P 500 appreciating by 0.578%

#Q5. What is the daily return of the VIX Index given that the $SPY depreciated during the trading period?
SPYVIXF1$VIX_CHANGE_PCT <- as.numeric(SPYVIXF1$VIX_CHANGE_PCT)
mean(SPYVIXF1$VIX_CHANGE_PCT[SPYVIXF1$SPY_CHANGE_PCT < 0], na.rm = TRUE)

# Given that the S&P 500 index declined, the VIX appreciated an average of 4.34%

#Q6. What is the daily return of the VIX Index given that the $SPY appreciated during the trading period?

mean(SPYVIXF1$VIX_CHANGE_PCT[SPYVIXF1$SPY_CHANGE_PCT > 0], na.rm = TRUE)
# Given that the S&P 500 index appreciated, the VIX declined by an average of 3.04%%

#Q7. Compare the total number of days where the VIX Index closes green against the total number of days where the $SPY closes red
positive_VIX_days <- sum(SPYVIXF1$VIX_CHANGE_PCT > 0, na.rm = TRUE)
# There are 1523 days where the VIX closed green
positive_VIX_days/negative_SPY_days
# There are 1.058 positive VIX days for every negative SPY day

#Q8. Compare the total number of days where the VIX Index closes red against the total number of days where the $SPY closes green
negative_VIX_days <- sum(SPYVIXF1$VIX_CHANGE_PCT < 0, na.rm = TRUE)
# There are 1770 days where the VIX closed red
negative_VIX_days/positive_SPY_days
# There are 0.956 negative VIX days for every positive SPY day

#Q9. Find the total number of days where the $SPY closes >+2%, and the average return for this subset of days
twopct_SPY_days <- sum(SPYVIXF1$SPY_CHANGE_PCT > 2, na.rm = TRUE)
#There are 56 days where the S&P 500 index closed >+2% during this 13 year period
mean(SPYVIXF1$SPY_CHANGE_PCT[SPYVIXF1$SPY_CHANGE_PCT > 2], na.rm = TRUE)
#For this subset of days, the average return is +2.833%

#Q10. Find the total number of days where the $SPY closes <-2%, and the average return for this subset of days
twopctred_SPY_days <- sum(SPYVIXF1$SPY_CHANGE_PCT < -2, na.rm = TRUE)
#There are 65 days where the S&P 500 index closed <-2% during this 13 year period
mean(SPYVIXF1$SPY_CHANGE_PCT[SPYVIXF1$SPY_CHANGE_PCT < -2], na.rm = TRUE)
#For this subset of days, the average return is -3.122%

#Q11. Print the 10 best days of the $SPY's performance and their corresponding VIX change
head(SPYVIXF1[order(SPYVIXF1$SPY_CHANGE_PCT, decreasing = TRUE), c("SPY_CHANGE_PCT", "VIX_CHANGE_PCT")], n = 10)
# Among the top 10 best days for the $SPY, there were 3 occurrences of VIX appreciating

#Q12. Print the 10 worst days of the $SPY's performance and their corresponding VIX change
head(SPYVIXF1[order(SPYVIXF1$SPY_CHANGE_PCT, decreasing = FALSE), c("SPY_CHANGE_PCT", "VIX_CHANGE_PCT")], n = 10)
# Among the top 10 worst days of the $SPY's performance, there was 1 occurence of the VIX depreciating

#Q13. Print the 10 best days of the VIX Index's performance and their corresponding $SPY change
head(SPYVIXF1[order(SPYVIXF1$VIX_CHANGE_PCT, decreasing = TRUE), c("VIX_CHANGE_PCT", "SPY_CHANGE_PCT")], n = 10)
# Among the top 10 best days for the VIX, all observations corresponded to a decrease in the $SPY

#Q14. Print the 10 worst days of the VIX Index's performance and their corresponding $SPY change
head(SPYVIXF1[order(SPYVIXF1$VIX_CHANGE_PCT, decreasing = FALSE), c("VIX_CHANGE_PCT", "SPY_CHANGE_PCT")], n = 10)
# Among the top 10 worst days for the $VIX, all corresponding $SPY values were positive (albeit one by less than 1%) 