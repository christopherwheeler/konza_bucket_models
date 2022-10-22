# looking_at_delta_s.R

library(tidyverse)

df <- read_csv("data/daily_delta_s.csv") %>%
  mutate(year = lubridate::year(date))

ggplot(df, aes(x = date, y = delta_s)) +
  geom_point(shape = 21) +
  facet_wrap(~ year, scales = "free_x") +
  scale_x_date(date_labels = "%m") +
  xlab("Date") +
  ylab("Daily \u0394S (mm)") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 18))

?facet_wrap
