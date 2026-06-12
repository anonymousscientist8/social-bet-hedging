# Load packages
library(tidyverse)
library(ggh4x)
library(grid)
library(gridExtra)
library(patchwork)
library(dplyr)
rm(list=ls())

#############################################################
# Load dataframe
strategies <-  
  read.csv("C:\\Users\\Raven\\social_bet_hedging\\strategies4.csv")


# get data
d <- 
  strategies %>% 
  filter(Total != 0)

# plot means and 95% CIs
plot <-
  ggplot(data = d, mapping = aes(x=Rate, y=Test))+
  geom_smooth() +
  geom_point()+
  ylab("focusing level")+
  xlab("relaized roost-switching rate") +
  scale_x_continuous(breaks=seq(0, 0.085, by=0.005)) +
  scale_y_continuous(breaks=seq(1, 6, by=1)) +
  theme_bw() 
    
print(plot)
