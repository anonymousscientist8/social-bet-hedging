# Load packages
library(tidyverse)
library(gtable)
library(grid)
library(gridExtra)
library(patchwork)
rm(list=ls())

#############################################################
# Load dataframe
strategies <-  read.csv("strategies3.csv")

# Bootstrapping code
# function to get 95% frequentist confidence interval of mean of vector x using classical bootstrapping
# argument 'bca = T' gives you bias-corrected and accelerated bootstrapping
boot_ci <- function(x, perms=5000, bca=F) {
  library(boot)
  get_mean <- function(x, d) {
    return(mean(x[d]))
  }
  x <- as.vector(na.omit(x))
  mean <- mean(x)
  if(bca){
    boot <- boot.ci(boot(data=x,
                         statistic=get_mean,
                         R=perms,
                         parallel = "multicore",
                         ncpus = 4),
                    type="bca")
    low <- boot$bca[1,4]
    high <- boot$bca[1,5]
  }else{
    boot <- boot.ci(boot(data=x,
                         statistic=get_mean,
                         R=perms,
                         parallel = "multicore",
                         ncpus = 4),
                    type="perc")
    low <- boot$perc[1,4]
    high <- boot$perc[1,5]
  }
  c(low=low,mean=mean,high=high, N=round(length(x)))
}


# get mean and 95% CIs via bootstrapping of values y within grouping variable x
# argument 'bca = T' gives you bias-corrected and accelerated bootstrapping
boot_ci2 <- function(d=d, y=d$y, x=d$x, perms=5000, bca=F){
  df <- data.frame(effect=unique(x))
  df$low <- NA
  df$mean <- NA
  df$high <- NA
  df$n.obs <- NA
  for (i in 1:nrow(df)) {
    ys <- y[which(x==df$effect[i])]
    if (length(ys)>1 & var(ys)>0 ){
      b <- boot_ci(y[which(x==df$effect[i])], perms=perms, bca=bca)
      df$low[i] <- b[1]
      df$mean[i] <- b[2]
      df$high[i] <- b[3]
      df$n.obs[i] <- b[4]
    }else{
      df$low[i] <- min(ys)
      df$mean[i] <- mean(ys)
      df$high[i] <- max(ys)
      df$n.obs[i] <- length(ys)
    }
  }
  df
}

# tidy data
d <- 
  strategies %>% 
  filter(Total >0) %>% 
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
    Modifier == 1 ~ "frequent")) %>% 
  pivot_longer(`Diversifying 3`:`Focusing 3`, values_to = "count", names_to = "strategy") %>% 
  select(strategy, count, switch, roost.bias, feed.bias) %>% 
    # create groups for bootstrapping
    mutate(strat_switch_roost_feed = paste(strategy, switch, roost.bias, feed.bias, sep= "_")) %>% 
    # create groups for plotting
    mutate(roost_feed = paste(roost.bias, feed.bias, sep= "_")) 

# get means
means <- 
  boot_ci2(x= d$strat_switch_roost_feed, y=d$count) %>% 
  separate(effect, into=c("strategy", "switch", "roost.bias", "feed.bias"), sep= "_") 
  
# create custom labels
feed_labels <- c("low" = "Low food-sharing ingroup bias", "medium" = "Medium food-sharing ingroup bias", "high" = "High food-sharing ingroup bias")
roost_labels <- c("low" = "Low co-roosting ingroup bias", "medium" = "Medium co-roosting ingroup bias", "high" = "High co-roosting ingroup bias")

# plot means
(plot <- 
    means %>% 
    mutate(switch= paste(switch, "roost switching")) %>% 
  mutate(switch = factor(switch, levels= c("rare roost switching", "empirical roost switching", "frequent roost switching"))) %>% 
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
  ylab("social strategy")+
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
