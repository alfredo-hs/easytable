
test_df <- mtcars

# Ensure the dataset name referenced in model calls exists during tests
mtcars <- mtcars

# Linear models
test_m1 <- stats::lm(mpg ~ wt, data = mtcars)
test_m2 <- stats::lm(mpg ~ wt + hp, data = mtcars)
test_m3 <- stats::lm(mpg ~ wt + hp + am, data = mtcars)

test_models_lm <- list(
  Model1 = test_m1,
  Model2 = test_m2,
  Model3 = test_m3
)

# GLM models (logistic regression)
test_g1 <- stats::glm(am ~ wt, data = mtcars, family = stats::binomial)
test_g2 <- stats::glm(am ~ wt + hp, data = mtcars, family = stats::binomial)

test_models_glm <- list(
  Logit1 = test_g1,
  Logit2 = test_g2
)

# Single model for simple tests
test_single_model <- list(SimpleModel = test_m1)

# Models with control variables
test_models_with_controls <- list(
  Base = stats::lm(mpg ~ wt, data = mtcars),
  Full = stats::lm(mpg ~ wt + hp + am + disp, data = mtcars)
)
