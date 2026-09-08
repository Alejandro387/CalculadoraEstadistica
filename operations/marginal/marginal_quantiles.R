
# This file registers the marginal quartiles operation.
# It calculates the quartiles of each selected column.
register_operation(

  "Marginal quartiles",

  fn = function(df, cols) unlist(lapply(df[cols], quantile, na.rm = TRUE)),

  types = c("discrete", "continuous"),

  min_cols = 1, max_cols = Inf

)

