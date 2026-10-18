# Predicting NBA Team Win Probability with Regression

Individual final project for STAT 3000 at the University of Manitoba (Fall 2023). It fits and refines a multiple linear regression that predicts an NBA team's win probability from its shooting efficiency.

## Question

Using 2018-19 NBA team statistics, how well do **three-point percentage (TPGP)** and **field goal percentage (FGP)** explain a team's **win probability (WINP)**?

## Data

[`data/NBA_Statistics.csv`](data/NBA_Statistics.csv) has one row for each of the 30 NBA teams in the 2018-19 season.

| Column | Meaning |
| --- | --- |
| `Team` | Team name |
| `WINP` | Win probability (games won / games played) |
| `TPGP` | Three-point goal percentage |
| `FGP` | Field goal percentage |

Source: [NBA.com stats](https://stats.nba.com/).

## Method

1. Fit the single-predictor models `WINP ~ TPGP` and `WINP ~ FGP`, and the additive model `WINP ~ TPGP + FGP`.
2. Fit the full second-order model, then F-test whether any term matters.
3. Refine the model: drop `TPGP*FGP` and then `FGP^2`, the terms with the largest VIF, and finally `TPGP^2`, since no higher-order term was significant.
4. Compare the reduced and full models with a partial F-test.
5. Check the residual plot and normal quantile plot for the final model.

## Result

The final model keeps both predictors:

```
WINP = -3.4975 + 0.0627 * TPGP + 0.0427 * FGP
```

- Adjusted R^2 is 0.5909 for the two-predictor model, compared with 0.3363 for `TPGP` alone and 0.375 for `FGP` alone.
- Both coefficients are significant at the 5% level (p = 0.000476 for `TPGP`, p = 0.000203 for `FGP`).
- The higher-order terms add nothing (partial F-test p = 0.7845).

## Repository layout

```
data/       NBA_Statistics.csv
proposal/   part1-proposal.Rmd and its rendered PDF (Part 1: data set and model criteria)
report/     final-report.Rmd and its rendered PDF (full analysis and write-up)
scripts/    exploratory-models.R (the first model fits, with notes)
```

## Reproducing

Requires R with the `rmarkdown`, `knitr` and `car` packages and a LaTeX engine.

```r
# from the repository root
rmarkdown::render("report/final-report.Rmd")
rmarkdown::render("proposal/part1-proposal.Rmd")
source("scripts/exploratory-models.R")
```

The R Markdown files read the data with a path relative to their own folder, so knit them from where they are.
