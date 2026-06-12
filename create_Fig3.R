rm(list = ls())

# Load Packages
library(tidyselect)

# hours until starvation
t <- 0:73

# Compute percentage of max weight
y <- 130.25 * (80 - t) ^ (-0.126)

# Make data frame
d <- data.frame(cbind(t, y))

# Plot
ggplot() +
  geom_line(data = d, mapping = aes(x = t, y = y), color = "black", size = 1.5) +
  xlab("hours until starvation") +
  ylab("percentage of maximum weight") +
  theme_bw()
