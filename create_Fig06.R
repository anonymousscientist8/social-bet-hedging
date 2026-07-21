# Load packages
library(tidyverse)
library(patchwork)
rm(list=ls())

#############################################################
# Load dataframe
strategies <-  
  read.csv("C:\\Users\\Raven\\social_bet_hedging\\strategies3.csv") %>% 
  mutate(bins= cut(Modifier, 
                   breaks = c(-Inf, -0.5, 0.5, Inf), 
                   labels = c("-1", "0", "1")))

# plot foraging success effects

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
(plot1 <- 
  means %>% 
  mutate(Foraging= ifelse(Foraging==1, "100%", "93%")) %>%   
  mutate(Foraging= fct_rev(Foraging)) %>% 
  ggplot(aes(x=Foraging, y=mean))+
    geom_col(width=0.4, fill= "#1b9e77", color= "black")+
    geom_errorbar(aes(ymin= low, ymax= high, width=0.2))+
    ylab("average number of daily grooming partners")+
    xlab("rate of foraging success") +
    scale_y_continuous(
      limits = c(0, NA), 
      expand = expansion(mult = c(0, 0.05)))+
    theme_bw() +
    theme(legend.position = "none"))

# plot predation effects

# get data
d2 <- 
  strategies %>% 
  filter(Total != 0) %>% 
  filter(Discriminatory == 30) %>%
  filter(Foraging == 0.93) %>%
  filter(SocialInheritance1 == FALSE) %>%
  filter(Threshold == 0) %>%
  filter(Modifier == 0)

# get means and 95% CIs
means2 <- d2 %>%
  group_by(Predation) %>%
  summarise(
    n.obs = n(),
    low = mean(Average, na.rm = TRUE) - 1.96 * sd(Average, na.rm = T) / sqrt(n()),
    mean = mean(Average, na.rm = TRUE),
    high = mean(Average, na.rm = TRUE) + 1.96 * sd(Average, na.rm = T) / sqrt(n()),
    .groups = 'drop'
  ) %>% 
  as_tibble()


# Compute average switches per group (used for x-axis)
switch_summary <- d2 %>%
  group_by(Predation) %>%
  summarise(Predation = mean(Predation), .groups = 'drop')

# Merge with means for plotting
means2 <- means2 %>%
  left_join(switch_summary)

# plot means and 95% CIs
(plot2 <- 
  means2 %>% 
  mutate(Predation= ifelse(Predation==0.0003, "0.03%", "0.00%")) %>%
  mutate(survival = round(n.obs/1000*100)) %>% 
  ggplot(aes(x=Predation, y=mean))+
  geom_col(width=0.4, color= "black", fill="#d95f02")+
  geom_errorbar(aes(ymin= low, ymax= high, width=0.2))+
  ylab("average number of daily grooming partners")+
  xlab("rate of predation") +
    scale_y_continuous(
      limits = c(0, NA), 
      expand = expansion(mult = c(0, 0.05)))+
  theme_bw() +
  theme(legend.position = "none"))

(plot <- plot1+plot2+plot_annotation(tag_levels= "a")+plot_layout(axes = "collect"))

# Save as PDF
ggsave(
  "Fig06.pdf",
  plot = plot,
  scale = 1,
  width = 5,
  height = 4,
  units = "in",
  dpi = 300)


