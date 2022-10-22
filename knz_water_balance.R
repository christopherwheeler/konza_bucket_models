# knz_water_balance.R
# Change in Storage time series at Konza from simple water balance
# P[mm] - AET[mm] - Q[mm] = delta_S[mm]
# Timestep: daily totals
# P = precipitation
# AET is actual evapotranspiration
# Q is runoff: discharge at Kings creek gauge normalized to catchment area, then
# multiplied by number of seconds in a day (86400)

library(tidyverse)
library(janitor)

# wrangle precip
precip <- read_csv("data/daily_precip.csv") %>%
  filter(watershed == "HQ") %>%
  rename(precip_mm = ppt) %>%
  rename(date = RecDate) %>%
  mutate(date = lubridate::mdy(date)) %>%
  select(date, precip_mm)

# wrangle AET
aet <- read_csv("data/daily_aet.csv") %>%
  mutate(date = lubridate::make_date(year = recyear, month = recmonth, day = recday)) %>%
  rename(daily_et = DailyET) %>%
  select(date, daily_et)




