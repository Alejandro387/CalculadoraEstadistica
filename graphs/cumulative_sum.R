# This file registers the cumulative sum graph.
# The function draws a line plot of the running total of the column values.
register_graph(
  "Cumulative sum",
  fn = function(df, cols, params) {
    values <- df[[cols[1]]]
    # Remove missing values before the cumulative sum calculation.
    values <- values[!is.na(values)]
    ggplot(
      data.frame(Index = seq_along(values), Cumulative = cumsum(values)),
      aes(x = Index, y = Cumulative)
    ) +
      geom_line(colour = graph_colours(params$colours, 1)[1]) +
      geom_point(colour = graph_colours(params$colours, 1)[1]) +
      labs(
        title = param_or(params$title, NULL),
        x = param_or(params[["label1"]], i18n$t("Observation")),
        y = param_or(params[["label2"]], sprintf(i18n$t("Cumulative sum of %s"), cols[1]))
      )
  },
  types = c("discrete", "continuous"),
  min_cols = 1, max_cols = 1,
  params = list(
    p_text("title", "Title", ""),
    p_text("label1", "Label 1", ""),
    p_text("label2", "Label 2", "")
  ),
  colours = TRUE
)
