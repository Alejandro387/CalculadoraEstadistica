# This file registers the histogram graph.
# The function draws one histogram for the selected column.
register_graph(
  "Histogram",
  fn = function(df, cols, params) {
    ggplot(df, aes(x = .data[[cols[1]]])) +
      # The bins parameter sets the number of bars in the histogram.
      geom_histogram(
        bins = params$bins,
        fill = graph_colours(params$colours, 1)[1],
        na.rm = TRUE
      ) +
      labs(
        title = param_or(params$title, NULL),
        x = param_or(params[["label1"]], cols[1]),
        y = param_or(params[["label2"]], i18n$t("Count"))
      )
  },
  types = c("discrete", "continuous"),
  min_cols = 1, max_cols = 1,
  params = list(
    p_num("bins", "Number of bins", 30, min_val = 1, step = 1),
    p_text("title", "Title", ""),
    p_text("label1", "Label 1", ""),
    p_text("label2", "Label 2", "")
  ),
  colours = TRUE
)
