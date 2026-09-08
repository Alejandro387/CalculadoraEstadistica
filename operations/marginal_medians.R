
# This file registers the marginal medians operation.
# It calculates the median of each selected column.
register_operation(

  "Marginal medians",

  fn = function(df, cols) unlist(lapply(df[cols], median, na.rm = TRUE)),

  types = c("discrete", "continuous"),

  min_cols = 1, max_cols = Inf

)

