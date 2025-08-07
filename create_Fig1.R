rm(list = ls())

library(tidyverse)

# Create test data
f1 <- rep(0, 12)
f2 <- rep(0, 12)
f3 <- rep(0, 12)
d1 <- rep(0, 12)
d2 <- rep(0, 12)
d3 <- rep(0, 12)
f1[1:12] <- 0.5^(1:12)*5
f2[1:8] <- 0.5^(1:8)*5
f3[1:4] <- 0.5^(1:4)*5
f1[12] <- f1[11]
f2[8] <- f2[7]
f3[4] <- f3[3]
d1[1:4] <- rep(5/4, 4)
d2[1:8] <- rep(5/8, 8)
d3[1:12] <- rep(5/12, 12)
partners <- 1:12
d <- data.frame(cbind(partners, d3, d2, d1, f1, f2, f3))
colnames(d) <- c("partners", "diversifying 3", "diversifying 2", "diversifying 1", "focusing 1", "focusing 2", "focusing 3")

# Reshape the data to long format
d <- d %>%
  pivot_longer(
    cols = -partners,
    names_to = "strategy",
    values_to = "value"
  )

# Set strategy factor levels for order and color control
d$strategy <- factor(d$strategy, levels = c(
  "diversifying 3", "diversifying 2", "diversifying 1",
  "focusing 1", "focusing 2", "focusing 3"
))

# Define a light-to-dark color palette
strategy_colors <- c(
  "diversifying 3" = "gray90",
  "diversifying 2" = "gray",
  "diversifying 1" = "gray70",
  "focusing 1" = "gray50",
  "focusing 2" = "gray30",
  "focusing 3" = "gray10"
)


# Plot histogram
ggplot(data = d, mapping = aes(x = partners, y = value, fill = strategy)) +
  geom_col(position = "dodge", color = "black") +
  facet_wrap(~ strategy, ncol = 6) +
  theme_bw() +
  ylab("grooming investment") +
  theme(legend.position = "none") +
  scale_x_discrete(
    name = "partner rank",
    limits = as.character(1:12)
  ) +
  scale_fill_manual(values = strategy_colors)
