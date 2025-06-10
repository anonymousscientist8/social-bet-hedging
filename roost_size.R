rm(list = ls())

library(tidyverse)

# import data
d <- read.csv("filename\\empirical.csv")

# for each roost in each simulation, get average roost size
avg <- rep(0, length(d[1,]))
for (i in 1:length(d[1,])) {
  temp <- d[d[,i] != 0,]
  avg[i] <- mean(temp[,i])
}

# Find the average roost size across all 6 scenarios
mean(avg[1:60], na.rm = T)
mean(avg[61:120],na.rm = T)
mean(avg[121:180], na.rm = T)
mean(avg[181:240], na.rm = T)
mean(avg[241:300], na.rm = T)
mean(avg[301:360], na.rm = T)
length(avg[is.na(avg) == F])/12
