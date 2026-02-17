## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)


## ----eval=FALSE---------------------------------------------------------------
# # Install from GitHub
# devtools::install_github("alfredo-hs/easytable")


## ----message=FALSE------------------------------------------------------------
library(easytable)
library(palmerpenguins)
data(penguins)


## -----------------------------------------------------------------------------
# Fit three nested models
m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
m2 <- lm(body_mass_g ~ flipper_length_mm + species, data = penguins)
m3 <- lm(body_mass_g ~ flipper_length_mm + species + island, data = penguins)

# Create named list
models <- list(
  "Model 1" = m1,
  "Model 2" = m2,
  "Model 3" = m3
)


## ----eval=FALSE---------------------------------------------------------------
# easytable(models)


## -----------------------------------------------------------------------------
easytable(models, output = "word")


## -----------------------------------------------------------------------------
easytable(models, output = "latex")


## ----eval=FALSE---------------------------------------------------------------
# easytable(models, output = "word", robust.se = TRUE)


## ----eval=FALSE---------------------------------------------------------------
# # Marginal effects (note: requires margins package)
# easytable(models[2:3], output = "word", margins = TRUE)


## ----eval=FALSE---------------------------------------------------------------
# easytable(
#   models[2:3],
#   output = "word",
#   robust.se = TRUE,
#   margins = TRUE
# )


## -----------------------------------------------------------------------------
# Add more controls
m4 <- lm(body_mass_g ~ flipper_length_mm + bill_length_mm, data = penguins)
m5 <- lm(body_mass_g ~ flipper_length_mm + bill_length_mm + species + island,
         data = penguins)

models_controls <- list(
  "Baseline" = m4,
  "With Controls" = m5
)

# Group species and island as control variables
easytable(
  models_controls,
  output = "word",
  control.var = c("species", "island")
)


## ----eval=FALSE---------------------------------------------------------------
# easytable(models, output = "word", highlight = TRUE)


## -----------------------------------------------------------------------------
# Logistic regression for sex (remove NAs first)
penguins_complete <- na.omit(penguins)

g1 <- glm(sex ~ body_mass_g, data = penguins_complete, family = binomial)
g2 <- glm(sex ~ body_mass_g + species, data = penguins_complete, family = binomial)

glm_models <- list(
  "Bivariate" = g1,
  "With Species" = g2
)

easytable(glm_models, output = "word")


## ----eval=FALSE---------------------------------------------------------------
# easytable(
#   models,
#   output = "word",
#   export.word = "penguin_regression_results.docx",
#   export.csv = "penguin_regression_results.csv"
# )
# # Creates: penguin_regression_results.docx and penguin_regression_results.csv


## ----eval=FALSE---------------------------------------------------------------
# # Fit models with controls
# m_baseline <- lm(body_mass_g ~ flipper_length_mm + bill_length_mm,
#                  data = penguins)
# 
# m_full <- lm(body_mass_g ~ flipper_length_mm + bill_length_mm +
#                species + island + sex,
#              data = na.omit(penguins))
# 
# models_full <- list(
#   "Baseline" = m_baseline,
#   "Full Model" = m_full
# )
# 
# # Create publication-ready table
# easytable(
#   models_full,
#   output = "word",
#   robust.se = TRUE,
#   control.var = c("species", "island", "sex"),
#   highlight = TRUE,
#   export.word = "final_results.docx",
#   export.csv = "final_results.csv"
# )


## -----------------------------------------------------------------------------
# Good
models_named <- list(
  "Baseline" = m1,
  "Add Species" = m2,
  "Full Model" = m3
)

# Less clear
models_numbered <- list(
  "Model1" = m1,
  "Model2" = m2,
  "Model3" = m3
)


## ----eval=FALSE---------------------------------------------------------------
# install.packages("flextable")
