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
strategies <-  read.csv("C:\\Users\\Raven\\social_bet_hedging\\strategies4.csv")


# get data
d <- 
  strategies %>% 
  filter(Total != 0) %>% 
  mutate(strat= case_when(
    round(Test) == 1 ~ "Diversifying 3",
    round(Test) == 2 ~ "Diversifying 2",
    round(Test) == 3 ~ "Diversifying 1",
    round(Test) == 4 ~ "Focusing 1",
    round(Test) == 5 ~ "Focusing 2",
    round(Test) == 6 ~ "Focusing 3")) %>% 
  mutate(strat= fct_relevel(strat,
    "Diversifying 3",
    "Diversifying 2",
    "Diversifying 1",
    "Focusing 1",
    "Focusing 2",
    "Focusing 3")) %>% 
  mutate(strat= fct_rev(strat))

# plot means and 95% CIs
(plot <-
  ggplot(data = d, mapping = aes(x=Rate, y=strat))+
  geom_jitter(alpha=0.5, size=2, height=0.1, width=0)+
  ylab("most common strategy")+
  xlab("roost-switching rate") +
  scale_x_continuous(breaks=seq(0, 0.1, by=0.01)) +
  coord_cartesian(xlim=c(0.008, 0.078))+  
  theme_bw())

# Save as PDF
ggsave(
  "FigS3.pdf",
  plot = plot,
  scale = 1,
  width = 6,
  height = 2.5,
  units = "in",
  dpi = 300)


