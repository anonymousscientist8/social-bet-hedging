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
  read.csv("C:\\Users\\Raven\\social_bet_hedging\\strategies3.csv") %>% 
  mutate(bins= cut(Modifier, 
                   breaks = c(-Inf, -0.5, 0.5, Inf), 
                   labels = c("-1", "0", "1")))


# get data
d <- 
  strategies %>% 
  filter(Total != 0) %>% 
  filter(Discriminatory == 30) %>%
  filter(Predation != 0) %>%
  filter(SocialInheritance1 == FALSE) %>%
  filter(Threshold == 0) %>%
  filter(Modifier == 0)

# get means and 95% CIs
means <- d %>%
  group_by(Foraging) %>%
  summarise(
    n.obs = n(),
    low = mean(Average, na.rm = TRUE) - 1.96 * sd(Average, na.rm = T) / sqrt(n()),
    mean = mean(Average, na.rm = TRUE),
    high = mean(Average, na.rm = TRUE) + 1.96 * sd(Average, na.rm = T) / sqrt(n()),
    .groups = 'drop'
  ) %>% 
  as_tibble()


# Compute average switches per group (used for x-axis)
switch_summary <- d %>%
  group_by(Foraging) %>%
  summarise(Foraging = mean(Foraging), .groups = 'drop')

# Merge with means for plotting
means <- means %>%
  left_join(switch_summary)

# plot means and 95% CIs
plot <- 
  means %>% 
    mutate(survival = round(n.obs/1000*100)) %>% 
  ggplot(aes(x=Foraging, y=mean))+
    geom_jitter(data= d, aes(x=Foraging, y=Average), height= 0, width=0.001, alpha=0.3, color= "darkgrey")+
    geom_line()+
    geom_point(size=2)+
    geom_errorbar(aes(ymin= low, ymax= high, width=0.003))+
    geom_text(
      aes(y = 3, label = paste0(survival)),
      size = 3,
      color = "green4"
    )+
    ylab("average number of daily grooming partners")+
    xlab("foraging-success rate") +
    theme_bw() +
    theme(legend.position = "none")
    
print(plot)

