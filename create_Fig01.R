rm(list = ls())

# Load Packages
library(tidyverse)
library(patchwork)

# List of ages by days live
a <- 0:(365*16)

# Compute the probability of finding food
f <- 0.93 / (1 + exp(-0.005 * (a - 300)))

# Plot foraging success
p1 <- 
  data.frame(cbind(a, f)) %>% 
  ggplot() +
  geom_hline(yintercept = 0.93, color = "blue") +
  geom_vline(xintercept = (365*2), color = "red") +
  geom_line(mapping = aes(x = a, y = f), color = "black", size = 1.5) +
  xlab("age (days)") +
  ylab("probability of\nsuccessful foraging") +
  theme_bw()

# List of ages by days live
a <- 0:300

# Compute weight
w_max <- 5.5453 * a^0.3012 + 0.00001

# Make data frame
d <- data.frame(cbind(a, w_max))

# Measured weights
points <- data.frame(
  a = c(0, 25, 60, 90, 300),
  w_max = c(6, 12, 18, 24, 33)
)

# Plot for weight change
p2 <- 
  ggplot() +
  geom_hline(yintercept = 33, color = "red") +
  geom_line(data = d, mapping = aes(x = a, y = w_max), color = "black", size = 1.5) +
  geom_point(data = points, mapping = aes(x = a, y = w_max)) +
  xlab("age (days)") +
  ylab("weight (grams)") +
  theme_bw()

# hours until starvation
t <- 0:73

# Compute percentage of max weight
y <- 130.25 * (80 - t) ^ (-0.126)

# Make data frame
d <- data.frame(cbind(t, y))

# Plot
p3 <- 
  ggplot() +
  geom_line(data = d, mapping = aes(x = t, y = y), color = "black", size = 1.5) +
  xlab("hours until starvation") +
  ylab("% of maximum weight") +
  theme_bw()

# Probabilities of roost switching per day
probs <- c(
  0.33868332,
  0.420528596,
  0.506737929,
  0.59242393,
  0.672852887,
  0.744388203,
  0.804994817,
  0.85422101,
  0.89281555,
  0.92222053,
  0.944125339,
  0.960164111,
  0.971757069,
  0.980057298
)

# List of days
days <- 1:14

# Combine data frame
d <- data.frame(days, probs)

# Plot
p4 <-
  ggplot(data = d, mapping = aes(x = days, y = probs)) +
  geom_smooth(se = FALSE) +
  theme_bw() +
  xlab("days since last switch") +
  ylab("probability of roost switch")


# Potential relationship scores
relationship <- 0:0.1:100

# Probability of sharing food
p <- 100 / (1 + exp(-0.1 *(relationship - 50) ) )

# Create data frame
df <- data.frame(relationship, p)

# Plot
p5 <- 
  ggplot(data = df, mapping = aes(x = relationship, y = p)) +
  geom_line() +
  theme_bw() +
  xlab("relationship score") +
  ylab("probability of sharing food")

# Combine plots
(fig1 <- p1+p2+p3+p4+p5+plot_annotation(tag_levels = 'a'))

# Save as PDF
ggsave(
  "Fig1.pdf",
  plot = fig1,
  scale = 1,
  width = 6.5,
  height = 2.5,
  units = "in",
  dpi = 300)
