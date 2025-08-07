rm(list = ls())

# Load Packages
library(tidyverse)

# List of ages by days live
a <- 0:(365*16)

# Compute the probability of finding food
f <- 0.93 / (1 + exp(-0.005 * (a - 300)))

# Make data frame
d <- data.frame(cbind(a, f))

# Plot
ggplot(data = d) +
  geom_hline(yintercept = 0.93, color = "blue") +
  geom_vline(xintercept = (365*2), color = "red") +
  geom_line(mapping = aes(x = a, y = f), color = "black", size = 1.5) +
  xlab("age (days)") +
  ylab("probability of successfully foraging for food") +
  theme_bw()