nba <- read.csv("data/NBA_Statistics.csv")
nba

nba1.lm <- lm(WINP ~ TPGP + FGP, data = nba)
summary(nba1.lm)

# Adj_r^2 = 0.5909

nba2.lm <- lm(WINP ~ TPGP, data = nba)
summary(nba2.lm)

# R^2 = 0.3592, Adj_r^2 = 0.3363

nba3.lm <- lm(WINP ~ FGP, data = nba)
summary(nba3.lm)

#R^2 = 0.3965, Adj_r^2 = 0.375
