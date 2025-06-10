# Load packages
library(tidyverse)
library(grid)
library(gridExtra)
library(patchwork)

# Clear workspace
rm(list = ls())

# Load original data
d <- read.csv("filename\\social_bet_hedging21 experiment-spreadsheet_XXmonYY_Z.csv", header = FALSE)

# create temporary data file
temp <- data.frame(matrix(nrow = 360,ncol = 7))

# store data
for (j in 1:360) {
  for (i in 1:7) {
    temp[j,i] <- d[(j-1)*7 + i]
  }
}

# Write file
write.csv(temp,"filename\\temp.csv")

#############################################################
# Load dataframe
strategies <-  read.csv("filename\\strategies3.csv")

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

#############################################################
# -1, 0, 30
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == -1,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 30,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot1 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  ggtitle("low food-sharing in-group bias") +
  xlab("") +
  ylab("low roost switching") +
  theme(legend.position = "none")
print(plot1)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# -1, 1200, 30
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == -1,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 30,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot10 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  ggtitle("low food-sharing in-group bias") +
  xlab("") +
  ylab("low roost switching") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5))
print(plot10)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# -1, 0, 50
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == -1,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 50,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot2 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  ggtitle("medium food-sharing in-group bias") +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot2)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# -1, 1200, 50
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == -1,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 50,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot11 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  ggtitle("medium food-sharing in-group bias") +
  xlab("") +
  ylab("") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5))
print(plot11)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# -1, 0, 70
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == -1,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 70,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot3 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  ggtitle("high food-sharing in-group bias") +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot3)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# -1, 1200, 70
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == -1,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 70,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot12 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  ggtitle("high food-sharing in-group bias") +
  xlab("") +
  ylab("") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5))
print(plot12)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# 0, 0, 30
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 0,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 30,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot4 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("empirical roost switching") +
  theme(legend.position = "none")
print(plot4)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# 0, 1200, 30
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 0,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 30,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot13 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("empirical roost switching") +
  theme(legend.position = "none")
print(plot13)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")



#############################################################
# 0, 0, 50
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 0,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 50,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot5 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot5)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")



#############################################################
# 0, 1200, 50
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 0,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 50,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot14 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot14)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")



#############################################################
# 0, 0, 70
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 0,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 70,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot6 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot6)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# 0, 1200, 70
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 0,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 70,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot15 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot15)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# 1, 0, 30
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 1,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 30,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot7 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("high roost switching") +
  theme(legend.position = "none")
print(plot7)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# 1, 1200, 30
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 1,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 30,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot16 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("high roost switching") +
  theme(legend.position = "none")
print(plot16)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("high roost switching") +
  theme(legend.position = "none")


#############################################################
# 1, 0, 50
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 1,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 50,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot8 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot8)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# 1, 1200, 50
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 1,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 50,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot17 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot17)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# 1, 0, 70
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 1,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 70,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot9 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot9)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")


#############################################################
# 1, 1200, 70
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Modifier == 1,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 70,]

# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*6))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*6))
strat <- rep(c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:6) {
    d$pop[(j-1)*6+i] <- strategies2[j,i+3]
    d$trial[(j-1)*6+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable Diversify','Inequitable Diversify','Equitable Neutral','Inequitable Neutral','Equitable Focusing','Inequitable Focusing'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")





# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*3))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*3))
strat <- rep(c('Diversifying','Balanced','Focusing'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:3) {
    d$pop[(j-1)*3+i] <- strategies2[j,i+10]
    d$trial[(j-1)*3+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Diversifying','Balanced','Focusing'))
plot18 <- boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")
print(plot18)




# Create data frame that shows the population from each trial
pop <- as.numeric(rep(0, length(strategies2$Threshold)*2))
trial <- as.numeric(rep(0, length(strategies2$Threshold)*2))
strat <- rep(c('Equitable','Inequitable'), length(strategies2$Threshold))
d <- data.frame(cbind(trial,strat,pop))
for (j in 1:length(strategies2$Threshold)) {
  for (i in 1:2) {
    d$pop[(j-1)*2+i] <- strategies2[j,i+13]
    d$trial[(j-1)*2+i] <- j
  }
}
d$pop <- as.numeric(d$pop)

# get mean and 95% CI of response 1
boot_ci(d$pop)

# get mean and 95% CI of response 1 by group
boot_ci2(d, d$pop, d$strat)

# make dataframe with data points
points <-
  d %>%
  #relabel the group as effect to match other dataset
  mutate(effect = strat)

# plot
d$strat <- factor(d$strat, levels = c('Equitable','Inequitable'))
boot_ci2(d, d$pop, d$strat) %>%
  ggplot(aes(x=effect, y=mean, color=effect))+
  geom_jitter(data= points, aes(y= pop), size=3, alpha=0.5, height=0, width=0.1)+
  geom_point(position = position_nudge(x = 0.25), size=1)+
  geom_errorbar(aes(ymin=low, ymax=high, width=0.5), position = position_nudge(x = 0.25), linewidth=2)+
  theme_bw() +
  xlab("") +
  ylab("") +
  theme(legend.position = "none")




#############################################################
y_label <- textGrob("number of surviving bats", rot = 90, gp = gpar(fontsize = 12))
combined_plot1 <- (plot1 | plot2 | plot3) /
  (plot4 | plot5 | plot6) /
  (plot7 | plot8 | plot_spacer()) &
  plot_annotation(
    title = 'low roosting in-group bias',
    caption = 'strategy',
    tag_levels = 'a') &
  theme(
    plot.title = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(hjust = 0.5, size = 12),
    plot.tag = element_text(size = 10)
  )
# Create a custom layout to add the y-axis label to the left of the combined plot
combined_grob1 <- patchworkGrob(combined_plot1)
full_grob1 <- grid.arrange(
  y_label, combined_grob1, 
  ncol = 2, 
  widths = unit.c(unit(1, "lines"), unit(1, "npc") - unit(1, "lines"))
)


y_label <- textGrob("number of surviving bats", rot = 90, gp = gpar(fontsize = 12))
combined_plot2 <- (plot10 | plot11 | plot12) /
  (plot13 | plot14 | plot15) /
  (plot16 | plot17 | plot18) &
  plot_annotation(
    title = 'high roosting in-group bias',
    caption = 'strategy',
    tag_levels = 'a') &
  theme(
    plot.title = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(hjust = 0.5, size = 12),
    plot.tag = element_text(size = 10)
  )
# Create a custom layout to add the y-axis label to the left of the combined plot
combined_grob2 <- patchworkGrob(combined_plot2)
full_grob2 <- grid.arrange(
  y_label, combined_grob2, 
  ncol = 2, 
  widths = unit.c(unit(1, "lines"), unit(1, "npc") - unit(1, "lines"))
)


############################################
# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 30,]

# Create data frame that shows the population from each trial
strategies2$Average <- as.numeric(strategies2$Average)
strategies2$Modifier <- as.numeric(strategies2$Modifier)
plot19 <- ggplot(data = strategies2, mapping = aes(x = Modifier, y = Average)) +
  geom_jitter(width = 0.1, alpha = 0.5) +#, color = "red") +
  geom_smooth(method = 'lm') +#, color = "darkred") +
  theme_bw() +
  ggtitle("low food-sharing in-group bias") +
  ylab("low roosting in-group bias") +
  xlab("")



# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 50,]

# Create data frame that shows the population from each trial
strategies2$Average <- as.numeric(strategies2$Average)
strategies2$Modifier <- as.numeric(strategies2$Modifier)
plot20 <- ggplot(data = strategies2, mapping = aes(x = Modifier, y = Average)) +
  geom_jitter(width = 0.1, alpha = 0.5) +#, color = "green") +
  geom_smooth(method = 'lm') +#, color = "darkgreen") +
  theme_bw() +
  ggtitle("medium food-sharing in-group bias") +
  ylab("") +
  xlab("")



# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Threshold == 0,]
strategies2 <- strategies2[strategies2$Discriminatory == 70,]

# Create data frame that shows the population from each trial
strategies2$Average <- as.numeric(strategies2$Average)
strategies2$Modifier <- as.numeric(strategies2$Modifier)
plot21 <- ggplot(data = strategies2, mapping = aes(x = Modifier, y = Average)) +
  geom_jitter(width = 0.1, alpha = 0.5) +#, color = "blue") +
  geom_smooth(method = 'lm') +#, color = "darkblue") +
  theme_bw() +
  ggtitle("high food-sharing in-group bias") +
  ylab("") +
  xlab("")



# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 30,]

# Create data frame that shows the population from each trial
strategies2$Average <- as.numeric(strategies2$Average)
strategies2$Modifier <- as.numeric(strategies2$Modifier)
plot22 <- ggplot(data = strategies2, mapping = aes(x = Modifier, y = Average)) +
  geom_jitter(width = 0.1, alpha = 0.5) +#, color = "red") +
  geom_smooth(method = 'lm') +#, color = "darkred") +
  theme_bw() +
  ylab("high roosting in-group bias") +
  xlab("")



# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 50,]

# Create data frame that shows the population from each trial
strategies2$Average <- as.numeric(strategies2$Average)
strategies2$Modifier <- as.numeric(strategies2$Modifier)
plot23 <- ggplot(data = strategies2, mapping = aes(x = Modifier, y = Average)) +
  geom_jitter(width = 0.1, alpha = 0.5) +#, color = "green") +
  geom_smooth(method = 'lm') +#, color = "darkgreen") +
  theme_bw() +
  ylab("") +
  xlab("")




# Filter out situations where virtual bats went extinct
strategies2 <- strategies[strategies$Total != 0,]
strategies2 <- strategies2[strategies2$Threshold == 1200,]
strategies2 <- strategies2[strategies2$Discriminatory == 70,]

# Create data frame that shows the population from each trial
strategies2$Average <- as.numeric(strategies2$Average)
strategies2$Modifier <- as.numeric(strategies2$Modifier)
plot24 <- ggplot(data = strategies2, mapping = aes(x = Modifier, y = Average)) +
  geom_jitter(width = 0.1, alpha = 0.5) +#, color = "blue") +
  geom_smooth(method = 'lm') +#, color = "darkblue") +
  theme_bw() +
  ylab("") +
  xlab("")


combined_plot3 <- (plot19 + plot20 + plot21) /
  (plot22 + plot23 + plot24)
y_label <- textGrob("average number of grooming partners per day", rot = 90, gp = gpar(fontsize = 12))
combined_plot3 <- combined_plot3 +
  plot_annotation(
    caption = 'roost-switching modifier',
    tag_levels = 'a') &
  theme(
    plot.title = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(hjust = 0.5, size = 12),
    plot.tag = element_text(size = 10)
  )
# Create a custom layout to add the y-axis label to the left of the combined plot
combined_grob3 <- patchworkGrob(combined_plot3)
full_grob3 <- grid.arrange(
  y_label, combined_grob3, 
  ncol = 2, 
  widths = unit.c(unit(1, "lines"), unit(1, "npc") - unit(1, "lines"))
)

