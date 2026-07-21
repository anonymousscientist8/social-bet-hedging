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

# Get Gini coefficient
gini <- function(x) {
  x <- sort(x)
  n <- length(x)
  G <- (2 * sum(x * seq_len(n))) / (n * sum(x)) - (n + 1) / n
  return(G)
}
gf3 <- gini(f3)
gf2 <- gini(f2)
gf1 <- gini(f1)
gd1 <- gini(d1)
gd2 <- gini(d2)
gd3 <- gini(d3)

# Reshape the data to long format
d <- d %>%
  pivot_longer(
    cols = -partners,
    names_to = "strategy",
    values_to = "value"
  )

Gini <- rep(c(gd3, gd2, gd1, gf1, gf2, gf3),6)
d <- 
  data.frame(d, Gini) %>%
  mutate(label = paste0(strategy, "\nGini = ", round(Gini, 3)))

# Add partners, bias
d$num_partners <- rep(c("12 partners", "8 partners", "4 partners"), 12)
d$biased <- rep(c("not biased", "not biased", "not biased", "biased", "biased", "biased"))
d <- 
  d %>%
  mutate(
    num_partners = factor(num_partners, levels = c("12 partners", "8 partners", "4 partners")),
    biased = factor(biased, levels = c("not biased", "biased"))
  )

# Set strategy factor levels for order and color control
d <- 
  d %>% 
  mutate(label = ifelse(label == "diversifying 3\nGini = 0", 
                        "diversifying 3\nGini = 0.000",
                        label)) %>% 
  mutate(label = ifelse(label == "focusing 1\nGini = 0.75", 
                        "focusing 1\nGini = 0.750",
                        label)) %>% 
  mutate(label = factor(label, levels = c(
  "diversifying 3\nGini = 0.000", 
  "diversifying 2\nGini = 0.333", 
  "diversifying 1\nGini = 0.667",
  "focusing 1\nGini = 0.750", 
  "focusing 2\nGini = 0.751", 
  "focusing 3\nGini = 0.771"))) 
  


# Plot histogram
(plot <- 
  ggplot(data = d, mapping = aes(x = partners, y = value)) +
  geom_col(position = "dodge", color = "black", fill= "lightgrey") +
  facet_grid(biased ~ num_partners) +
  theme_bw() +
  ylab("allogrooming investment") +
  theme(legend.position = "none") +
  scale_x_discrete(
    limits = as.character(1:12)
  ) +
  geom_label(
    data = d,
    aes(x = Inf, y = Inf, label = label,
        hjust = 1.1,
        vjust = 1.1), 
    fill= "white"
  ) +
  xlab("partner rank") +
  scale_x_continuous(breaks = seq(1, 12, by = 1)))

# Save as PDF
ggsave(
  "Fig2.pdf",
  plot = plot,
  scale = 1,
  width = 7.5,
  height = 3.5,
  units = "in",
  dpi = 300)
