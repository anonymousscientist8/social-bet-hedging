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
  filter(SocialInheritance1 == FALSE) %>%
  filter(Modifier %in% c(-1, 0, 1)) %>%
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
  mutate(switch = case_when(
    Modifier == -1 ~ "(a) rare roost switching (stable co-roosting groups)",
    Modifier == 0 ~ "(b) empirical roost switching (normal fission-fusion dynamics)",
    Modifier == 1 ~ "(c) maximal roost switching (daily fission-fusion dynamics)")) %>%
  pivot_longer(`Diversifying 3`:`Focusing 3`, values_to = "count", names_to = "strategy") %>% 
  select(strategy, count, switch, roost.bias, feed.bias) %>% 
    # create groups for bootstrapping
    mutate(strat_switch_roost_feed = paste(strategy, switch, roost.bias, feed.bias, sep= "_")) %>% 
    # create groups for plotting
    mutate(roost_feed = paste(roost.bias, feed.bias, sep= "_")) %>%
  mutate(Gini = case_when(
    strategy == "Diversifying 3" ~ 0,
    strategy == "Diversifying 2" ~ 0.333,
    strategy == "Diversifying 1" ~ 0.667,
    strategy == "Focusing 1" ~ 0.75,
    strategy == "Focusing 2" ~ 0.751,
    strategy == "Focusing 3" ~ 0.771)) %>% 
  mutate(conditions = paste(roost.bias," co-roosting ingroup bias\n", 
                     feed.bias, " food-sharing ingroup bias\n", sep = ""))

# get means
means <- d %>%
  group_by(Gini, switch, conditions) %>%
  summarise(
    n.obs = n(),
    low = mean(count, na.rm = TRUE) - 1.96 * sd(count, na.rm = T) / sqrt(n()),
    mean = mean(count, na.rm = TRUE),
    high = mean(count, na.rm = TRUE) + 1.96 * sd(count, na.rm = T) / sqrt(n()),
    .groups = 'drop'
  )
  
# plot means
(plot <- 
  ggplot(data = means, mapping = aes(x = Gini, y = mean, colour = conditions, linetype= conditions)) +
  geom_line() +
  geom_errorbar(aes(ymin = low, ymax = high), width = 0.01) +
  facet_wrap(~ switch, ncol = 1) +
  ylab("average number of surviving bats") +
  xlab("amount of focusing in allogrooming (Gini coefficient)") +
  scale_color_viridis_d(option= "F") + 
  theme_bw()+
    theme(strip.text= element_text(hjust=0)))

# scale_color_viridis_c()# Save as PDF
ggsave(
  "Fig5.pdf",
  plot = plot,
  scale = 1,
  width = 7,
  height = 5,
  units = "in",
  dpi = 300)
