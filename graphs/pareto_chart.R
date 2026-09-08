# This file registers the Pareto chart graph.
# The function uses the qcc package to draw a Pareto chart of the column counts.
register_graph(
  "Pareto chart",
  fn = function(df, cols, params) {
    # Count the values in the column to build the Pareto chart bars.
    counts <- table(df[[cols[1]]])
    qcc::pareto.chart(
      counts,
      col = graph_colours(params$colours, length(counts)),
      main = param_or(params$main, cols[1])
    )
  },
  types = c("nominal", "discrete"),
  min_cols = 1, max_cols = 1,
  params = list(
    p_text("main", "Title", "")
  ),
  colours = TRUE
)
