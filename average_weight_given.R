rm(list = ls())

# Load pacakges
library(tidyverse)

# Upload data
d <- read.csv("filename\\food_sharing_donations_2010-2014.csv")

# Find each bat
bats <- unique(d$donor)

# Used to store average amount of blood donated
averages <- rep(NA,length(bats))
for (i in 1:length(bats)) {
  # For every bat
  # Filter to only the bat we care about
  temp <- d[d$donor == bats[i],]
  # Find relevant dates
  dates <- unique(temp$date)
  # And create a placeholder for the mean amount of time donated
  times2 <- rep(0,length(dates))
  for (j in 1:length(dates)) {
    # Fore each date
    # Filter to the relevant date
    temp2 <- temp[temp$date == dates[j],]
    # Look at all bats donated to
    receivers <- unique(temp2$receiver)
    # Create a placeholder for the amount donated for each bat
    times <- rep(0, length(receivers))
    for (k in 1:length(receivers)) {
      # And for each potential receiver
      # Filter to only the relvant interactions
      temp3 <- temp2[temp2$receiver == receivers[k],]
      # Find amount of donated blood
      times[k] <- sum(temp3$donation.sec)
    }
    # Find mean time donated
    times2[j] <- mean(times)
  }
  averages[i] <- mean(times2)
}

# Convert time to weight (based on aveerage donation rates)
weight_given_avg <- mean(averages)/60*37/1000/33*100
