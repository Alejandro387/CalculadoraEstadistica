
# This file registers the conditional standard deviations operation.
# It calculates the standard deviation of one column for each group of a second column.
register_operation(

  "Conditional standard deviations",

  fn = function(df, cols) {

    # Get the value column and the group column.
    values <- df[[cols[1]]]

    groups <- as.factor(df[[cols[2]]])

    # Keep only rows where both the value and the group are not NA.
    complete_rows <- !is.na(values) & !is.na(groups)

    # Calculate the standard deviation of values for each group in groups.
    grouped_stats <- tapply(values[complete_rows], groups[complete_rows], sd, na.rm = TRUE)

    if (is.list(grouped_stats)) {

      # tapply can return a list. Change it to a plain named vector.
      unlist(grouped_stats)

    } else {

      result <- as.vector(grouped_stats)

      # Add the group names back to the result.
      names(result) <- as.character(dimnames(grouped_stats)[[1]])

      result

    }

  },

  types = conditional_types_check,

  min_cols = 2, max_cols = 2

)

