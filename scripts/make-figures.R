# Regenerates the figures used in README.md.
# Run from the repository root:  Rscript scripts/make-figures.R

nba <- read.csv("data/NBA_Statistics.csv")
dir.create("figures", showWarnings = FALSE)

# Palette: one accent hue for the data, neutrals for everything else
surface <- "#fcfcfb"
ink     <- "#0b0b0b"
ink2    <- "#52514e"
muted   <- "#898781"
grid    <- "#e1e0d9"
axis_c  <- "#c3c2b7"
accent  <- "#2a78d6"

open_png <- function(file, width, height) {
  if (requireNamespace("ragg", quietly = TRUE)) {
    ragg::agg_png(file, width = width, height = height, res = 200, background = surface)
  } else {
    png(file, width = width, height = height, res = 200, bg = surface)
  }
}

panel <- function(xlim, ylim, xticks, yticks, xlab, ylab, title, subtitle) {
  plot(NA, xlim = xlim, ylim = ylim, axes = FALSE, xlab = "", ylab = "", xaxs = "i", yaxs = "i")
  abline(h = yticks, col = grid, lwd = 1)
  abline(h = ylim[1], col = axis_c, lwd = 1.5)
  axis(1, at = xticks, tick = FALSE, col.axis = muted, cex.axis = 0.85, line = -0.4)
  axis(2, at = yticks, tick = FALSE, col.axis = muted, cex.axis = 0.85, las = 1, line = -0.4)
  mtext(xlab, side = 1, line = 2.3, col = ink2, cex = 0.85)
  mtext(ylab, side = 2, line = 2.9, col = ink2, cex = 0.85)
  mtext(title, side = 3, line = 1.7, adj = 0, font = 2, col = ink, cex = 1)
  mtext(subtitle, side = 3, line = 0.45, adj = 0, col = ink2, cex = 0.85)
}

dot <- function(x, y) points(x, y, pch = 21, bg = accent, col = surface, lwd = 2.4, cex = 1.6)

# Text with a surface-coloured halo so labels stay legible over gridlines
tag <- function(x, y, txt, ...) {
  for (a in seq(0, 2 * pi, length.out = 9)[-9]) {
    text(x + xinch(0.015) * cos(a), y + yinch(0.015) * sin(a), txt, cex = 0.8, col = surface, ...)
  }
  text(x, y, txt, cex = 0.8, col = ink2, ...)
}

m1   <- lm(WINP ~ TPGP, nba)
m2   <- lm(WINP ~ FGP, nba)
m12  <- lm(WINP ~ TPGP + FGP, nba)
full <- lm(WINP ~ TPGP + FGP + I(TPGP^2) + I(FGP^2) + TPGP * FGP, nba)

# 1. Win probability against each predictor ------------------------------------
open_png("figures/winp-vs-predictors.png", 2000, 900)
par(mfrow = c(1, 2), mar = c(4.2, 4.6, 3.8, 1.2), oma = c(0, 0.5, 0, 0.5), bg = surface)
hi <- which.max(nba$WINP); lo <- which.min(nba$WINP)
for (v in c("TPGP", "FGP")) {
  fit <- if (v == "TPGP") m1 else m2
  x <- nba[[v]]
  rng <- range(x)
  panel(xlim = c(floor(rng[1]) - 0.5, ceiling(rng[2]) + 0.5), ylim = c(0.12, 0.85),
        xticks = seq(floor(rng[1]), ceiling(rng[2]), by = 2), yticks = seq(0.2, 0.8, by = 0.2),
        xlab = if (v == "TPGP") "Three-point percentage (TPGP)" else "Field goal percentage (FGP)",
        ylab = "Win probability (WINP)",
        title = if (v == "TPGP") "Win probability vs three-point %" else "Win probability vs field goal %",
        subtitle = bquote(R^2 == .(sprintf("%.3f", summary(fit)$r.squared)) ~ "on its own"))
  abline(fit, col = ink2, lwd = 2.4)
  dot(x, nba$WINP)
  tag(x[hi], nba$WINP[hi], nba$Team[hi], pos = if (x[hi] > median(x)) 2 else 4, offset = 0.9)
  tag(x[lo], nba$WINP[lo], nba$Team[lo], pos = 1, offset = 1.1)
}
dev.off()

# 2. Model diagnostics for the final model -------------------------------------
open_png("figures/final-model-diagnostics.png", 2000, 900)
par(mfrow = c(1, 2), mar = c(4.2, 4.6, 3.8, 1.2), oma = c(0, 0.5, 0, 0.5), bg = surface)
panel(xlim = c(0.2, 0.85), ylim = c(-0.2, 0.2),
      xticks = seq(0.2, 0.8, by = 0.2), yticks = seq(-0.2, 0.2, by = 0.1),
      xlab = "Fitted win probability", ylab = "Residual",
      title = "Residuals vs fitted", subtitle = "No clear pattern around zero")
abline(h = 0, col = axis_c, lwd = 2.4)
dot(fitted(m12), resid(m12))
qq <- qqnorm(rstandard(m12), plot.it = FALSE)
panel(xlim = c(-2.5, 2.5), ylim = c(-3, 3),
      xticks = seq(-2, 2, by = 1), yticks = seq(-3, 3, by = 1),
      xlab = "Theoretical quantiles", ylab = "Standardized residuals",
      title = "Normal Q-Q plot", subtitle = "Close to the line, with a few points off in the tails")
qqline(rstandard(m12), col = ink2, lwd = 2.4)
dot(qq$x, qq$y)
dev.off()

# 3. Adjusted R-squared by model ----------------------------------------------
models <- data.frame(
  label = c("TPGP only", "FGP only", "TPGP + FGP (final model)", "Full second-order (5 terms)"),
  adj_r2 = c(summary(m1)$adj.r.squared, summary(m2)$adj.r.squared,
             summary(m12)$adj.r.squared, summary(full)$adj.r.squared)
)
n <- nrow(models)
ypos <- rev(seq_len(n))
open_png("figures/adjusted-r2-by-model.png", 2000, 760)
par(mar = c(3.4, 15, 3.8, 2), bg = surface)
plot(NA, xlim = c(0, 0.75), ylim = c(0.4, n + 0.6), axes = FALSE, xlab = "", ylab = "", xaxs = "i", yaxs = "i")
abline(v = seq(0.2, 0.6, by = 0.2), col = grid, lwd = 1)
abline(v = 0, col = axis_c, lwd = 1.5)
axis(1, at = seq(0, 0.6, by = 0.2), tick = FALSE, col.axis = muted, cex.axis = 0.85, line = -0.4)
title_x <- grconvertX(0.105, "ndc", "user")
mtext(expression("Adjusted " * R^2), side = 1, line = 2.1, col = ink2, cex = 0.85)
mtext(expression(bold("Adjusted " * R^2 * " by model")), side = 3, line = 1.7, adj = 0, col = ink, cex = 1,
      at = title_x, xpd = NA)
mtext("Both shooting percentages help; higher-order terms do not", side = 3, line = 0.45, adj = 0,
      col = ink2, cex = 0.85, at = title_x, xpd = NA)
final <- 3
rect(0, ypos - 0.2, models$adj_r2, ypos + 0.2, col = ifelse(seq_len(n) == final, accent, axis_c), border = NA)
text(-0.015, ypos, models$label, adj = 1, xpd = NA, cex = 0.9, col = ifelse(seq_len(n) == final, ink, ink2),
     font = ifelse(seq_len(n) == final, 2, 1))
text(models$adj_r2 + 0.012, ypos, sprintf("%.3f", models$adj_r2), adj = 0, cex = 0.9,
     col = ifelse(seq_len(n) == final, ink, ink2), font = ifelse(seq_len(n) == final, 2, 1))
dev.off()

cat("Wrote figures/winp-vs-predictors.png, figures/final-model-diagnostics.png, figures/adjusted-r2-by-model.png\n")
