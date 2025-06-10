# Load packages
library(tidyverse)
library(grid)
library(gridExtra)
library(patchwork)
library(dplyr)
rm(list=ls())

#############################################################
# Load dataframe
strategies <-  
  read.csv("strategies3.csv") %>% 
  mutate(bins= cut(Modifier, 
                   breaks = c(-Inf, -0.5, 0.5, Inf), 
                   labels = c("-1", "0", "1")))

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


# get data
d <- 
  strategies %>% 
  filter(Total != 0) %>% 
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
  mutate(switch = factor(switch, levels= c("rare", "empirical", "frequent"))) %>% 
  mutate(roost.bias = factor(roost.bias, levels= c("low", "high"))) %>% 
  mutate(feed.bias = factor(feed.bias, levels= c("low", "medium", "high"))) %>% 
  # create groups for bootstrapping
  mutate(scenario = paste(switch, roost.bias, feed.bias, sep= "_")) %>% 
  # create groups for plotting
  mutate(scenario2 = paste(roost.bias, feed.bias, sep= "_")) 

# get means and 95% CIs
means <- 
  boot_ci2(d, x= d$scenario, y= d$Average) %>% 
  separate(effect, into = c("switch", "roost.bias", "feed.bias")) %>% 
  # add missing population
  add_row(switch= "frequent", roost.bias= "low", feed.bias= "high", n.obs= 0) %>%   
  mutate(switch = factor(switch, levels= c("rare", "empirical", "frequent"))) %>% 
  mutate(roost.bias = factor(roost.bias, levels= c("low", "high"))) %>% 
  mutate(feed.bias = factor(feed.bias, levels= c("low", "medium", "high"))) %>% 
  mutate(scenario2 = paste(roost.bias, feed.bias, sep= "_")) %>% 
  as_tibble()
  
# create custom labels
feed_labels <- c("low" = "Low food-sharing ingroup bias", "medium" = "Medium food-sharing ingroup bias", "high" = "High food-sharing ingroup bias")
roost_labels <- c("low" = "Low co-roosting ingroup bias", "medium" = "Medium co-roosting ingroup bias", "high" = "High co-roosting ingroup bias")

means$scenario2

# plot means and 95% CIs
(plot <- 
  means %>% 
    mutate(survival = round(n.obs/660*100)) %>% 
  ggplot(aes(x=switch, y=mean, group= scenario2))+
     facet_grid(rows= vars(feed.bias), cols= vars(roost.bias),
              labeller = labeller(feed.bias = feed_labels, roost.bias = roost_labels)) +
    geom_jitter(data= d, aes(x=switch, y=Average), height= 0, width=0.1, alpha=0.3, color= "darkgrey")+
    geom_line(color= "darkblue")+
    geom_point(size=2, color= "darkblue")+
    geom_errorbar(aes(ymin= low, ymax= high, width=0.2), color= "darkblue")+
    geom_text(aes(y=3, label= paste0(survival, "%")), size=3, color= "green4")+
    ylab("average number of daily grooming partners")+
    xlab("roost-switching rate")+
    theme_bw())
    
# save plot
ggsave(
  "Figure2.pdf",
  plot = plot,
  scale = 1,
  width = 5,
  height = 8,
  units = c("in", "cm", "mm", "px"),
  dpi = 300)
