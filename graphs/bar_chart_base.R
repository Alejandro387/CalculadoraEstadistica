# This file registers the base-R barplot graph.
# The function draws a barplot with one bar for each value in the column.
register_graph(
  "Barplot (base R)",
  fn = function(df, cols, params) {
    # Count the values in the column to build the bar heights.
    counts <- table(df[[cols[1]]])
    barplot(
      counts,
      col = graph_colours(params$colours, length(counts)),
      main = param_or(params$main, NULL),
      xlab = param_or(params[["label1"]], cols[1]),
      ylab = param_or(params[["label2"]], i18n$t("Count"))
    )
  },
  types = c("nominal", "discrete"),
  min_cols = 1, max_cols = 1,
  params = list(
    p_text("main", "Title", ""),
    p_text("label1", "Label 1", ""),
    p_text("label2", "Label 2", "")
  ),
  colours = TRUE
)
