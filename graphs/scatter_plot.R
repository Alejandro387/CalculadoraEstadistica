# This file registers the scatter plot graph.
# The function draws points for two columns and can add a regression line.
register_graph(
  "Scatter plot",
  fn = function(df, cols, params) {
    plot <- ggplot(df, aes(x = .data[[cols[1]]], y = .data[[cols[2]]])) +
      geom_point(
        size = params$size,
        colour = graph_colours(params$colours, 1)[1],
        na.rm = TRUE
      ) +
      labs(
        title = param_or(params$title, NULL),
        x = param_or(params[["label1"]], cols[1]),
        y = param_or(params[["label2"]], cols[2])
      )
    # Add a regression line only when the user turns on the toggle.
    if (isTRUE(params$regression_line)) {
      # Keep only the rows where both columns have a value.
      complete_rows <- !is.na(df[[cols[1]]]) & !is.na(df[[cols[2]]])
      x_values <- df[[cols[1]]][complete_rows]
      y_values <- df[[cols[2]]][complete_rows]
      # Calculate the slope and intercept of the regression line.
      slope <- cov(x_values, y_values) / var(x_values)
      intercept <- mean(y_values) - slope * mean(x_values)
      if (is.finite(intercept) && is.finite(slope)) {
        plot <- plot + geom_abline(intercept = intercept, slope = slope)
      }
    }
    plot
  },
  types = c("discrete", "continuous"),
  min_cols = 2, max_cols = 2,
  regression_toggle = TRUE,
  params = list(
    p_num("size", "Point size", 1.5, min_val = 0),
    p_text("title", "Title", ""),
    p_text("label1", "Label 1", ""),
    p_text("label2", "Label 2", "")
  ),
  colours = TRUE
)
