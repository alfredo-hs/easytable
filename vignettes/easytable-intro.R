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
# easy_table(models)


## -----------------------------------------------------------------------------
easy_table(models, output = "markdown")


## -----------------------------------------------------------------------------
easy_table(models, output = "latex")


## ----eval=FALSE---------------------------------------------------------------
# easy_table(models, output = "markdown", robust.se = TRUE)


## ----eval=FALSE---------------------------------------------------------------
# # Marginal effects (note: requires margins package)
# easy_table(models[2:3], output = "markdown", margins = TRUE)


## ----eval=FALSE---------------------------------------------------------------
# easy_table(
#   models[2:3],
#   output = "markdown",
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
easy_table(
  models_controls,
  output = "markdown",
  control.var = c("species", "island")
)


## ----eval=FALSE---------------------------------------------------------------
# easy_table(models, output = "word", highlight = TRUE)


## -----------------------------------------------------------------------------
# Logistic regression for sex (remove NAs first)
penguins_complete <- na.omit(penguins)

g1 <- glm(sex ~ body_mass_g, data = penguins_complete, family = binomial)
g2 <- glm(sex ~ body_mass_g + species, data = penguins_complete, family = binomial)

glm_models <- list(
  "Bivariate" = g1,
  "With Species" = g2
)

easy_table(glm_models, output = "markdown")


## ----eval=FALSE---------------------------------------------------------------
# easy_table(
#   models,
#   output = "word",
#   csv = "penguin_regression_results"
# )
# # Creates: penguin_regression_results.csv


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
# easy_table(
#   models_full,
#   output = "word",
#   robust.se = TRUE,
#   control.var = c("species", "island", "sex"),
#   highlight = TRUE,
#   csv = "final_results"
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

