# Load packages
library(tidyverse)
library(grid)
library(gridExtra)
library(patchwork)

# Clear workspace
rm(list = ls())

# Load original data
d <- read.csv("filename\\social_bet_hedging21 experiment-spreadsheet_XXmonYY_Z.csv", header = FALSE)

# create temporary data file
temp <- data.frame(matrix(nrow = 360,ncol = 7))

# store data
for (j in 1:360) {
  for (i in 1:7) {
    temp[j,i] <- d[(j-1)*7 + i]
  }
}

# Write file
write.csv(temp,"filename\\temp.csv")
