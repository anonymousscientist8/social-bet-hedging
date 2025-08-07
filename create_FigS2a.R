rm(list = ls())

# Load Packages
library(tidyverse)

# List of ages by days live
a <- 0:300

# Compute weight
w_max <- 5.5453 * a^0.3012 + 0.00001

# Make data frame
d <- data.frame(cbind(a, w_max))

# Measured weights
points <- data.frame(
  a = c(0, 25, 60, 90, 300),
  w_max = c(6, 12, 18, 24, 33)
)

# Plot
ggplot() +
  geom_hline(yintercept = 33, color = "red") +
  geom_line(data = d, mapping = aes(x = a, y = w_max), color = "black", size = 1.5) +
  geom_point(data = points, mapping = aes(x = a, y = w_max)) +
  xlab("age (days)") +
  ylab("weight (grams)") +
  theme_bw()
