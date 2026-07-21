# Load packages
library(tidyverse)
library(grid)
library(gridExtra)
library(patchwork)

rm(list=ls())

#############################################################
# Load dataframe
strategies <-  
  read.csv("filename\\strategies3.csv") %>% 
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
feed_labels <- c("low" = "(a) Low food-sharing ingroup bias", "medium" = "(b) Medium food-sharing ingroup bias", "high" = "(c) High food-sharing ingroup bias")



# plot means and 95% CIs
(plot <- 
  means %>% 
    mutate(survival = round(n.obs/1000*100)) %>% 
  ggplot(aes(x=Modifier, y=survival, group = scenario2, 
             color= roost.bias, shape= roost.bias))+
     facet_wrap(~ feed.bias,
              labeller = labeller(feed.bias = feed_labels), ncol = 3) +
    geom_line()+
    geom_point(size=2)+
    ylab("percentage of surviving populations")+
    xlab("relative roost switching rate (roost switching modifier)") +
    scale_color_manual(values= c("#FA8657",  "darkred"))+
    guides(color = guide_legend(title = "co-roosting\ningroup bias"), 
           shape = guide_legend(title = "co-roosting\ningroup bias"))+
    theme_bw() +
    theme(legend.position= "inside", 
          legend.box = "black",
          legend.box.background= element_rect(color = "black", fill=NA),
          legend.position.inside = c(0.2, 0.3)))

# Save as PDF
ggsave(
  "Fig07.pdf",
  plot = plot,
  scale = 1,
  width = 7.5,
  height = 2.8,
  units = "in",
  dpi = 300)


