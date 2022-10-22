# knz_water_balance.R
# Change in Storage time series at Konza from simple water balance
# P[mm] - AET[mm] - Q[mm] = delta_S[mm]
# Timestep: daily totals, starting on October 16th, 2000
# P = precipitation
# AET is actual evapotranspiration
# Q is runoff: discharge at Kings creek gauge normalized to catchment area, then
# multiplied by number of seconds in a day (86400)

library(tidyverse)
library(janitor)
library(dataRetrieval)
library(RColorBrewer)

# Wrangle precip
precip <- read_csv("data/daily_precip.csv") %>%
  filter(watershed == "HQ") %>%
  rename(daily_precip_mm = ppt) %>%
  rename(date = RecDate) %>%
  mutate(date = lubridate::mdy(date)) %>%
  mutate(daily_precip_mm = as.numeric(daily_precip_mm)) %>%
  select(date, daily_precip_mm)

# Wrangle AET
aet <- read_csv("data/daily_aet.csv") %>%
  mutate(date = lubridate::make_date(year = recyear, month = recmonth, day = recday)) %>%
  rename(daily_et_mm = DailyET) %>%
  select(date, daily_et_mm)

# Wrangle runoff: USGS 06879650 KINGS C NR MANHATTAN, KS
site_number <- "06879650"
param_code <- "00060"

# Step 1: get data with dataRetrieval
# Raw daily data:
q <- readNWISdv(site_number,param_code, "2000-10-16","2022-10-20")

# Step 2: wrangle q
q <- q %>%
  rename(discharge_cfs = X_00060_00003) %>%
  rename(date = Date) %>%
  mutate(discharge_m3 = discharge_cfs * 0.028316846592) %>%
  mutate(discharge_norm_m = discharge_m3 / 1.0593e+7) %>%
  mutate(discharge_norm_mm = discharge_norm_m * 1000) %>%
  mutate(daily_q_mm = discharge_norm_mm * 86400) %>%
  select(date, daily_q_mm)

# join precip, aet, and runoff data frames
df <- left_join(aet, precip, by = "date") %>%
  left_join(q, by = "date") %>%
  drop_na() %>%
  mutate(delta_s = daily_precip_mm - daily_et_mm - daily_q_mm)

# Save df as CSV
write_csv(df, "data/daily_delta_s.csv")

#Plot change in storage
ggplot(df, aes(x = date, y = delta_s)) +
  geom_point(shape = 21) +
  xlab("Date") +
  ylab("Daily \u0394S (mm)") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14))
