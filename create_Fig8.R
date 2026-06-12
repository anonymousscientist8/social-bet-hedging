rm(list = ls())

library(tidyverse)

# load data
d_wins <- read.csv("C:\\Users\\Raven\\social_bet_hedging\\diversifying_wins.csv")
example <- rep("(a) empirical roost switching, low food-sharing bias", length(d_wins$day))
d_wins <- data.frame(d_wins, example)
f_wins <- read.csv("C:\\Users\\Raven\\social_bet_hedging\\focusing_wins.csv")
example <- rep("(b) rare roost switching, high food-sharing bias", length(f_wins$day))
f_wins <- data.frame(f_wins, example)
df <- rbind(d_wins, f_wins)
colnames(df) <- c("day", "diversifying 3", "focusing 1",
                  "diversifying 2", "focusing 2",
                  "diversifying 1", "focusing 3", "total", "example")

# Convert to long format
df_long <- df %>%
  pivot_longer(
    cols = c(
      "diversifying 3",
      "focusing 1",
      "diversifying 2",
      "focusing 2",
      "diversifying 1",
      "focusing 3",
      "total"
    ),
    names_to = "strategy",
    values_to = "value",
  )

# plot data
ggplot() +
  geom_line(data = df_long[df_long$strategy == "total",], mapping = aes(x = day, y = value, color = strategy)) +
  geom_line(data = df_long[df_long$strategy != "total",], mapping = aes(x = day, y = value, color = strategy)) +
  theme_bw() +
  scale_color_manual(
    values = c(
      "diversifying 3" = "pink",
      "diversifying 2" = "red",
      "diversifying 1" = "red4",
      "focusing 1" = "blue4",
      "focusing 2" = "blue",
      "focusing 3" = "cyan",
      "total" = "black"
    )
  ) +
  xlab("days") +
  ylab("individuals") +
  facet_wrap( ~ example, ncol = 2)