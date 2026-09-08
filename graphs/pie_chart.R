# This file registers the pie chart graph.
# The function draws a pie chart with one slice for each value in the column.
register_graph(
  "Pie chart",
  fn = function(df, cols, params) {
    # Count the values in the column to build the pie slices.
    counts <- table(df[[cols[1]]])
    # Calculate the percent of the total for each slice label.
    percentages <- round(100 * counts / sum(counts), 1)
    pie(
      counts,
      labels = paste0(names(counts), " | ", percentages, "%"),
      col = graph_colours(params$colours, length(counts)),
      clockwise = TRUE,
      init.angle = 90,
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
