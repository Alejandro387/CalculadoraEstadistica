
# This file registers the marginal variances operation.
# It calculates the variance of each selected column.
register_operation(

  "Marginal variances",

  fn = function(df, cols) unlist(lapply(df[cols], var, na.rm = TRUE)),

  types = c("discrete", "continuous"),

  min_cols = 1, max_cols = Inf

)

