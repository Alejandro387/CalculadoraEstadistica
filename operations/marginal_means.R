
# This file registers the marginal means operation.
# It calculates the mean of each selected column.
register_operation(

  "Marginal means",

  fn = function(df, cols) unlist(lapply(df[cols], mean, na.rm = TRUE)),

  types = c("discrete", "continuous"),

  min_cols = 1, max_cols = Inf

)

