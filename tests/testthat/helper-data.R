# Test data setup using Palmer Penguins dataset
# This file is sourced before tests run

# Create sample models for testing (only if palmerpenguins is available)
if (requireNamespace("palmerpenguins", quietly = TRUE)) {
  penguins <- palmerpenguins::penguins
  penguins_complete <- na.omit(penguins)
} else {
  skip("palmerpenguins package not available")
}

# Linear models
test_m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
test_m2 <- lm(body_mass_g ~ flipper_length_mm + species, data = penguins)
test_m3 <- lm(body_mass_g ~ flipper_length_mm + species + island, data = penguins)

test_models_lm <- list(
  Model1 = test_m1,
  Model2 = test_m2,
  Model3 = test_m3
)

# GLM models (logistic regression for sex)
test_g1 <- glm(sex ~ body_mass_g, data = penguins_complete, family = binomial)
test_g2 <- glm(sex ~ body_mass_g + species, data = penguins_complete, family = binomial)

test_models_glm <- list(
  Logit1 = test_g1,
  Logit2 = test_g2
)

# Single model for simple tests
test_single_model <- list(SimpleModel = test_m1)

# Models with control variables
test_models_with_controls <- list(
  Base = lm(body_mass_g ~ flipper_length_mm, data = penguins),
  Full = lm(body_mass_g ~ flipper_length_mm + species + island + bill_length_mm, data = penguins)
)
