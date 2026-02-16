# -----------------
# Setup
# -----------------
devtools::load_all()

# -----------------
# Load DF
# -----------------

df <- readRDS("tests/xtest/df_v2.rds")
df$sahadsfbaoij5w4tfhsghsgsgfhsgfhsd <- df$financial_prudence

# -----------------
# Regression Tables
# -----------------

m1 = lm(
  crypto ~
    financial_knowledge +
    overconfidence +
    self_knowledge +
    financial_prudence +
    digital_confidence +
    advisor_confidence +
    gender +
    age +
    occupation +
    income_decile +
    isocntry,
  data = df
)

m2 = glm(
  crypto ~
    financial_knowledge +
    financial_prudence *
    digital_confidence +
    overconfidence +
    self_knowledge +
    advisor_confidence +
    gender +
    age +
    occupation +
    income_decile +
    isocntry,
  data = df,
  family = "binomial",
  weights = w14
)

easytable(m1,m2,
          control.var = "isocntry",
          highlight = T,
          output = "word")
