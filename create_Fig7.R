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
  filter(Foraging == 0.93) %>%
  filter(Predation > 0) %>%
  filter(SocialInheritance1 == FALSE) %>%
  mutate(roost.bias = case_when(
    Threshold == 0 ~ "low",
    Threshold == 1200 ~ "high")) %>% 
  mutate(feed.bias = case_when(
    Discriminatory == 30 ~ "low",
    Discriminatory == 50 ~ "medium",
    Discriminatory == 70 ~ "high")) %>% 
  mutate(roost.bias = factor(roost.bias, levels= c("low", "high"))) %>% 
  mutate(feed.bias = factor(feed.bias, levels= c("low", "medium", "high"))) %>% 
  # create groups for bootstrapping
  mutate(scenario = paste(Modifier, roost.bias, feed.bias, sep= "_")) %>% 
  # create groups for plotting
  mutate(scenario2 = paste(roost.bias, feed.bias, sep= "_")) 

# get means and 95% CIs
means <- d %>%
  group_by(Modifier, roost.bias, feed.bias) %>%
  summarise(
    n.obs = n(),
    low = mean(Average, na.rm = TRUE) - 1.96 * sd(Average, na.rm = T) / sqrt(n()),
    mean = mean(Average, na.rm = TRUE),
    high = mean(Average, na.rm = TRUE) + 1.96 * sd(Average, na.rm = T) / sqrt(n()),
    .groups = 'drop'
  ) %>% 
  # add missing population
  add_row(Modifier= 1, roost.bias= "low", feed.bias= "high", n.obs= 0) %>%   
  mutate(roost.bias = factor(roost.bias, levels= c("low", "high"))) %>% 
  mutate(feed.bias = factor(feed.bias, levels= c("low", "medium", "high"))) %>% 
  mutate(scenario2 = paste(roost.bias, feed.bias, sep= "_")) %>% 
  as_tibble()


# Compute average switches per group (used for x-axis)
switch_summary <- d %>%
  group_by(Modifier, roost.bias, feed.bias) %>%
  summarise(Modifier = mean(Modifier), .groups = 'drop')

# Merge with means for plotting
means <- means %>%
  left_join(switch_summary, by = c("Modifier", "roost.bias", "feed.bias"))

# create custom labels
feed_labels <- c("low" = "Low food-sharing ingroup bias", "medium" = "Medium food-sharing ingroup bias", "high" = "High food-sharing ingroup bias")
roost_labels <- c("low" = "Low co-roosting ingroup bias", "medium" = "Medium co-roosting ingroup bias", "high" = "High co-roosting ingroup bias")

means$scenario2

# plot means and 95% CIs
plot <- 
  means %>% 
    mutate(survival = round(n.obs/1000*100)) %>% 
  ggplot(aes(x=Modifier, y=mean, group = scenario2))+
     facet_wrap2(~ feed.bias + roost.bias,
              labeller = labeller(feed.bias = feed_labels, roost.bias = roost_labels), ncol = 2, strip = strip_split(c("right", "top")))+#, scales = "free_x") +
    geom_jitter(data= d, aes(x=Modifier, y=Average), height= 0, width=0.05, alpha=0.3, color= "darkgrey")+
    geom_line()+
    geom_point(size=2)+
    geom_errorbar(aes(ymin= low, ymax= high, width=0.1))+
    geom_text(
      aes(y = 3, label = paste0(survival)),
      size = 3,
      color = "green4"
    )+
    ylab("average number of daily grooming partners")+
    xlab("roost switching modifier") +
    theme_bw() +
    theme(legend.position = "none")
    
print(plot)
