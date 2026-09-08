
# This file registers the marginal modes operation.
# It calculates the mode of each selected column.
register_operation(

  "Marginal modes",

  # stat_mode is a shared helper function, defined in another file.
  fn = function(df, cols) unlist(lapply(df[cols], stat_mode)),

  types = c("discrete", "continuous"),

  min_cols = 1, max_cols = Inf

)

