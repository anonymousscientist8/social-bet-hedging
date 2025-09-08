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
  mutate(switch = factor(switch, levels= c("rare", "empirical", "maximal"))) %>% 
  mutate(roost.bias = factor(roost.bias, levels= c("low", "high"))) %>% 
  mutate(feed.bias = factor(feed.bias, levels= c("low", "medium", "high"))) %>% 
  # create groups for bootstrapping
  mutate(scenario = paste(switch, roost.bias, feed.bias, sep= "_")) %>% 
  # create groups for plotting
  mutate(scenario2 = paste(roost.bias, feed.bias, sep= "_")) 


# Add row with approximated number of switches per day
switches <- rep(0, length(d$Threshold))
for (i in 1:length(switches)) {
  if (d$Threshold[i] == 0 & d$Discriminatory[i] == 30 & d$Modifier[i] == -1) {
    switches[i] <- ((0.010+0.0041+0.0040+4.8*10^-4+0.013)/5)
  }
  if (d$Threshold[i] == 1200 & d$Discriminatory[i] == 30 & d$Modifier[i] == -1) {
    switches[i] <- ((0.021+1.8*10^-4+3.6*10^-5+0.0023+0.036)/5)
  }
  if (d$Threshold[i] == 0 & d$Discriminatory[i] == 50 & d$Modifier[i] == -1) {
    switches[i] <- ((5.3*10^-4+0.0042+0.0073+0.0070+0.0043)/5)
  }
  if (d$Threshold[i] == 1200 & d$Discriminatory[i] == 50 & d$Modifier[i] == -1) {
    switches[i] <- ((0.066+0.047+0.020+0.0053+1.5*10^-4)/5)
  }
  if (d$Threshold[i] == 0 & d$Discriminatory[i] == 70 & d$Modifier[i] == -1) {
    switches[i] <- ((2.6*10^-4+0.0095+0.0017+0.0061+0)/5)
  }
  if (d$Threshold[i] == 1200 & d$Discriminatory[i] == 70 & d$Modifier[i] == -1) {
    switches[i] <- ((0.058+0.0038+0.0012+0.089+0.065)/5)
  }
  if (d$Threshold[i] == 0 & d$Discriminatory[i] == 30 & d$Modifier[i] == 0) {
    switches[i] <- ((0.54+0.56+0.54+0.56+0.43)/5)
  }
  if (d$Threshold[i] == 1200 & d$Discriminatory[i] == 30 & d$Modifier[i] == 0) {
    switches[i] <- ((0.75+0.73+0.76+0.77+0.73)/5)
  }
  if (d$Threshold[i] == 0 & d$Discriminatory[i] == 50 & d$Modifier[i] == 0) {
    switches[i] <- ((0.49+0.45+0.49+0.48+0.49)/5)
  }
  if (d$Threshold[i] == 1200 & d$Discriminatory[i] == 50 & d$Modifier[i] == 0) {
    switches[i] <- ((0.45+0.66+0.49+0.60+0.64)/5)
  }
  if (d$Threshold[i] == 0 & d$Discriminatory[i] == 70 & d$Modifier[i] == 0) {
    switches[i] <- ((0.41+0.47+0.44+0.46+0.45)/5)
  }
  if (d$Threshold[i] == 1200 & d$Discriminatory[i] == 70 & d$Modifier[i] == 0) {
    switches[i] <- ((0.48+0.44+0.45+0.50+0.51)/5)
  }
  if (d$Modifier[i] == 1) {
    switches[i] <- 1
  }
}
d <- data.frame(cbind(d, switches))

# get means and 95% CIs
means <- d %>%
  group_by(switch, roost.bias, feed.bias) %>%
  summarise(
    n.obs = n(),
    low = mean(Average, na.rm = TRUE) - 1.96 * sd(Average, na.rm = T) / sqrt(n()),
    mean = mean(Average, na.rm = TRUE),
    high = mean(Average, na.rm = TRUE) + 1.96 * sd(Average, na.rm = T) / sqrt(n()),
    .groups = 'drop'
  ) %>% 
  # add missing population
  add_row(switch= "maximal", roost.bias= "low", feed.bias= "high", n.obs= 0) %>%   
  mutate(switch = factor(switch, levels= c("rare", "empirical", "maximal"))) %>% 
  mutate(roost.bias = factor(roost.bias, levels= c("low", "high"))) %>% 
  mutate(feed.bias = factor(feed.bias, levels= c("low", "medium", "high"))) %>% 
  mutate(scenario2 = paste(roost.bias, feed.bias, sep= "_")) %>% 
  as_tibble()


# Compute average switches per group (used for x-axis)
switch_summary <- d %>%
  group_by(switch, roost.bias, feed.bias) %>%
  summarise(switches = mean(switches), .groups = 'drop')

# Merge with means for plotting
means <- means %>%
  left_join(switch_summary, by = c("switch", "roost.bias", "feed.bias"))

# create custom labels
feed_labels <- c("low" = "Low food-sharing ingroup bias", "medium" = "Medium food-sharing ingroup bias", "high" = "High food-sharing ingroup bias")
roost_labels <- c("low" = "Low co-roosting ingroup bias", "medium" = "Medium co-roosting ingroup bias", "high" = "High co-roosting ingroup bias")

means$scenario2

# plot means and 95% CIs
(plot <- 
  means %>% 
    mutate(survival = round(n.obs/1000*100)) %>% 
  ggplot(aes(x=switches, y=mean, group = scenario2))+
     facet_wrap2(~ feed.bias + roost.bias,
              labeller = labeller(feed.bias = feed_labels, roost.bias = roost_labels), scales = "free_x", ncol = 2, strip = strip_split(c("right", "top"))) +
    geom_jitter(data= d, aes(x=switches, y=Average), height= 0, width=0.05, alpha=0.3, color= "darkgrey")+
    geom_line(color= "darkblue")+
    geom_point(size=2, color= "darkblue", aes(shape = switch))+
    geom_errorbar(aes(ymin= low, ymax= high, width=0.1), color= "darkblue")+
    geom_text(
      aes(y = 3, label = paste0(survival)),
      size = 3,
      color = "green4"
    )+
    ylab("average number of daily grooming partners")+
    scale_x_log10() +
    xlab("roost switching rate") +
    theme_bw()) +
    theme(legend.position = "none")
    
# save plot
ggsave(
  "Figure2.pdf",
  plot = plot,
  scale = 1,
  width = 5,
  height = 8,
  units = c("in", "cm", "mm", "px"),
  dpi = 300)

