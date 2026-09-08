# This file registers the stem-and-leaf graph.
# The function returns the text output of the stem function as the plot.
register_graph(
  "Stem-and-leaf",
  fn = function(df, cols, params) {
    # Capture the text lines that the stem function prints.
    utils::capture.output(stem(df[[cols[1]]], scale = params$scale))
  },
  types = c("discrete", "continuous"),
  min_cols = 1, max_cols = 1,
  render = "text",
  params = list(
    p_num("scale", "Scale", 1, min_val = 0)
  )
)
