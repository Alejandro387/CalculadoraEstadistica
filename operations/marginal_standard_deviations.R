
# This file registers the marginal standard deviations operation.
# It calculates the standard deviation of each selected column.
register_operation(

  "Marginal standard deviations",

  fn = function(df, cols) unlist(lapply(df[cols], sd, na.rm = TRUE)),

  types = c("discrete", "continuous"),

  min_cols = 1, max_cols = Inf

)

