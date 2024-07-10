rm(list = ls())

library(tidyverse)

d <- read.csv("C:\\Users\\raven\\Downloads\\food_sharing_donations_2010-2014.csv")

bats <- unique(d$donor)

averages <- rep(NA,length(bats))
for (i in 1:length(bats)) {
  temp <- d[d$donor == bats[i],]
  dates <- unique(temp$date)
  times2 <- rep(0,length(dates))
  for (j in 1:length(dates)) {
    temp2 <- temp[temp$date == dates[j],]
    receivers <- unique(temp2$receiver)
    times <- rep(0, length(receivers))
    for (k in 1:length(receivers)) {
      temp3 <- temp2[temp2$receiver == receivers[k],]
      times[k] <- sum(temp3$donation.sec)
    }
    times2[j] <- mean(times)
  }
  averages[i] <- mean(times2)
}

weight_given_avg <- mean(averages)/60*37/1000/33*100
