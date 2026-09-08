# This file registers the density plot graph.
# The function draws the estimated density curve for the selected column.
register_graph(
  "Density plot",
  fn = function(df, cols, params) {
    ggplot(df, aes(x = .data[[cols[1]]])) +
      # The adjust parameter sets the bandwidth of the density curve.
      geom_density(
        adjust = params$adjust,
        colour = graph_colours(params$colours, 1)[1],
        na.rm = TRUE
      ) +
      labs(
        title = param_or(params$title, NULL),
        x = param_or(params[["label1"]], cols[1]),
        y = param_or(params[["label2"]], i18n$t("Density"))
      )
  },
  types = "continuous",
  min_cols = 1, max_cols = 1,
  params = list(
    p_num("adjust", "Bandwidth adjustment", 1, min_val = 0),
    p_text("title", "Title", ""),
    p_text("label1", "Label 1", ""),
    p_text("label2", "Label 2", "")
  ),
  colours = TRUE
)
