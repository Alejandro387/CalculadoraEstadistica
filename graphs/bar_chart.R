# This file registers the bar chart graph.
# The function draws one bar for each unique value in the selected column.
register_graph(
  "Bar chart",
  fn = function(df, cols, params) {
    # Count the unique, non-missing values to pick one colour per bar.
    n_colours <- length(unique(df[[cols[1]]][!is.na(df[[cols[1]]])]))
    bar_colours <- graph_colours(params$colours, n_colours)
    # factor() so numeric discrete columns don't drop the fill aesthetic
    ggplot(df, aes(x = .data[[cols[1]]], fill = factor(.data[[cols[1]]]))) +
      geom_bar() +
      scale_fill_manual(values = bar_colours) +
      guides(fill = "none") +
      labs(
        title = param_or(params$title, NULL),
        x = param_or(params[["label1"]], cols[1]),
        y = param_or(params[["label2"]], i18n$t("Count"))
      )
  },
  types = c("nominal", "discrete"),
  min_cols = 1, max_cols = 1,
  params = list(
    p_text("title", "Title", ""),
    p_text("label1", "Label 1", ""),
    p_text("label2", "Label 2", "")
  ),
  colours = TRUE
)
