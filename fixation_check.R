rm(list = ls())

strategies <- read.csv("C:\\Users\\raven\\Documents\\strategies3.csv")
strategies <- strategies[strategies$Total != 0,]
p1 <- strategies$Pink/strategies$Total
p2 <- strategies$Magenta/strategies$Total
p3 <- strategies$Violet/strategies$Total
p4 <- strategies$Blue/strategies$Total
p5 <- strategies$Green/strategies$Total
p6 <- strategies$Yellow/strategies$Total
check <- rep(0, length(strategies))
check <- ifelse(p1 == 1, 1, check)
check <- ifelse(p2 == 1, 1, check)
check <- ifelse(p3 == 1, 1, check)
check <- ifelse(p4 == 1, 1, check)
check <- ifelse(p5 == 1, 1, check)
check <- ifelse(p6 == 1, 1, check)
mean(check)
(11880 - length(strategies$Threshold) + sum(check))/11880
