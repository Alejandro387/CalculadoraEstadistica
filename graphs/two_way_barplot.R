# This file registers the two-way barplot graph.
# The function draws a stacked barplot with a legend for two columns.
register_graph(
  "Vertical barplot with labels",
  fn = function(df, cols, params) {
    # Build a two-way count table from the two selected columns.
    counts <- table(df[[cols[1]]], df[[cols[2]]])
    barplot(
      counts,
      xlab = param_or(params[["label2"]], cols[2]),
      col = graph_colours(params$colours, nrow(counts)),
      legend.text = rownames(counts),
      args.legend = list(title = param_or(params[["label1"]], cols[1]))
    )
  },
  types = c("nominal", "discrete"),
  min_cols = 2, max_cols = 2,
  params = list(
    p_text("label1", "Label 1", ""),
    p_text("label2", "Label 2", "")
  ),
  colours = TRUE
)
