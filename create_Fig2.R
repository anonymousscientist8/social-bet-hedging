# Load packages
library(tidyverse)
library(gtable)
library(grid)
library(gridExtra)
library(patchwork)
rm(list=ls())

#############################################################
# Load dataframe
strategies <-  read.csv("C:\\Users\\Raven\\social_bet_hedging\\strategies3.csv")

# tidy data
d <- 
  strategies %>% 
  filter(Total >0) %>%
  filter(Predation > 0) %>%
  filter(Foraging == 0.93) %>%
  rename("Diversifying 3" = Pink,
         "Diversifying 2" = Violet,
         "Diversifying 1" = Green,
         "Focusing 1" = Magenta,
         "Focusing 2" = Blue,
         "Focusing 3" = Yellow) %>% 
  mutate(roost.bias = case_when(
    Threshold == 0 ~ "low",
    Threshold == 1200 ~ "high")) %>% 
  mutate(feed.bias = case_when(
    Discriminatory == 30 ~ "low",
    Discriminatory == 50 ~ "medium",
    Discriminatory == 70 ~ "high")) %>% 
  mutate(switch= case_when(
    Modifier == -1 ~ "rare",
    Modifier == 0 ~ "empirical",
    Modifier == 1 ~ "maximal")) %>% 
  pivot_longer(`Diversifying 3`:`Focusing 3`, values_to = "count", names_to = "strategy") %>% 
  select(strategy, count, switch, roost.bias, feed.bias) %>% 
    # create groups for bootstrapping
    mutate(strat_switch_roost_feed = paste(strategy, switch, roost.bias, feed.bias, sep= "_")) %>% 
    # create groups for plotting
    mutate(roost_feed = paste(roost.bias, feed.bias, sep= "_")) 

# get means
means <- d %>%
  group_by(strategy, switch, roost.bias, feed.bias) %>%
  summarise(
    n.obs = n(),
    low = mean(count, na.rm = TRUE) - 1.96 * sd(count, na.rm = T) / sqrt(n()),
    mean = mean(count, na.rm = TRUE),
    high = mean(count, na.rm = TRUE) + 1.96 * sd(count, na.rm = T) / sqrt(n()),
    .groups = 'drop'
  )
  
# create custom labels
feed_labels <- c("low" = "Low food-sharing ingroup bias", "medium" = "Medium food-sharing ingroup bias", "high" = "High food-sharing ingroup bias")
roost_labels <- c("low" = "Low co-roosting ingroup bias", "medium" = "Medium co-roosting ingroup bias", "high" = "High co-roosting ingroup bias")

# plot means
(plot <- 
    means %>% 
    mutate(switch= paste(switch, "roost switching")) %>% 
  mutate(switch = factor(switch, levels= c("rare roost switching", "empirical roost switching", "maximal roost switching"))) %>% 
  mutate(roost.bias = factor(roost.bias, levels= c("low", "high"))) %>% 
  mutate(feed.bias = factor(feed.bias, levels= c("low", "medium", "high"))) %>% 
  mutate(strategy= factor(strategy, levels= c("Diversifying 3" ,
                                              "Diversifying 2",
                                              "Diversifying 1",
                                              "Focusing 1",
                                              "Focusing 2",
                                              "Focusing 3"))) %>% 
  mutate(strategy= fct_rev(strategy)) %>% 
  ggplot(aes(x=mean, y=strategy, groups= roost.bias, color= roost.bias, shape= roost.bias))+
  facet_grid(rows= vars(feed.bias), cols= vars(switch),
             labeller = labeller(feed.bias = feed_labels, roost.bias = roost_labels)) +
    geom_vline(xintercept= 0)+
    geom_point(size=2, position = position_dodge(width = 0.8))+
    geom_errorbarh(aes(xmin= low, xmax= high), height=0.5, position = position_dodge(width = 0.8))+
  scale_color_manual(values= c("#FA8657",  "darkred"))+
  guides(color = guide_legend(title = "co-roosting\ningroup bias"), shape = guide_legend(title = "co-roosting\ningroup bias"))+
  xlab("average number of surviving bats")+
  ylab("social networking strategy")+
  theme_bw()+
  theme(legend.box.background= element_rect(color = "black", fill=NA),
        legend.position = "inside",
        legend.position.inside = c(0.9, 0.1)))

  
# save plot
ggsave(
  "Figure1.pdf",
  plot = plot,
  scale = 1,
  width = 8,
  height = 8,
  units = c("in", "cm", "mm", "px"),
  dpi = 300)
