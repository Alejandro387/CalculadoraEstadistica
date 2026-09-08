# These tests check the graphs module.

# This environment records the inputs of the last graph call.
capture <- new.env(parent = emptyenv())

register_graph(
  # This graph saves its arguments and returns an empty plot.
  "Probe plot", function(df, cols, params) {
    capture$last <- list(df = df, cols = cols, params = params)
    ggplot2::ggplot(df)
  },
  types = "continuous", min_cols = 1, max_cols = 1,
  params = list(p_num("bins", "Bins", 10, min_val = 1)),
  colours = TRUE, regression_toggle = TRUE
)

register_graph(
  # This graph always fails, so the tests can check the error message.
  "Broken plot", function(df, cols, params) stop("boom"),
  types = "continuous"
)

# This line exposes the registry for the tests.
app_env$available_graphs <- app_env$.graph_registry$graphs

# This line gets the server function of the graphs module.
mod_graphs_server <- get("mod_graphs_server", envir = mod_env, inherits = FALSE)

test_that("a fresh draw runs the graph with default state", {
  store <- new_data_store()
  store$selected_cols("Sepal.Length")

  testServer(mod_graphs_server, args = list(store = store), {
    session$userData$shiny.i18n <- list(lang = reactiveVal("en"))
    session$setInputs(graph = "Probe plot", draw = 1)
    session$flushReact()

    expect_identical(capture$last$cols, "Sepal.Length")
    expect_identical(capture$last$df, store$df)
    expect_identical(capture$last$params$bins, 10)
    expect_identical(capture$last$params$resolution, default_resolution)
    expect_identical(capture$last$params$colours, character(0))
  })
})

test_that("redraw picks up edited params and a valid resolution", {
  store <- new_data_store()
  store$selected_cols("Sepal.Length")

  testServer(mod_graphs_server, args = list(store = store), {
    session$userData$shiny.i18n <- list(lang = reactiveVal("en"))
    session$setInputs(graph = "Probe plot", draw = 1)
    session$flushReact()

    session$setInputs(param_bins = 25, resolution_text = "900, 500", redraw = 1)
    session$flushReact()
    expect_identical(capture$last$params$bins, 25)
    expect_identical(capture$last$params$resolution, c(900, 500))

    session$setInputs(resolution_text = "abc", redraw = 1)
    session$flushReact()
    expect_identical(capture$last$params$resolution, c(900, 500))
  })
})

test_that("the regression toggle flips and re-runs the graph", {
  store <- new_data_store()
  store$selected_cols("Sepal.Length")

  testServer(mod_graphs_server, args = list(store = store), {
    session$userData$shiny.i18n <- list(lang = reactiveVal("en"))
    session$setInputs(graph = "Probe plot", draw = 1)
    session$flushReact()
    expect_false(isTRUE(capture$last$params$regression_line))

    session$setInputs(toggle_regression = 1)
    session$flushReact()
    expect_true(capture$last$params$regression_line)
  })
})

test_that("editing the data re-runs the open graph", {
  store <- new_data_store()
  store$selected_cols("Sepal.Length")

  testServer(mod_graphs_server, args = list(store = store), {
    session$userData$shiny.i18n <- list(lang = reactiveVal("en"))
    session$setInputs(graph = "Probe plot", draw = 1)
    session$flushReact()
    expect_identical(nrow(capture$last$df), 150L)

    store$df <- store$df[1:50, ]
    store$bump()
    session$flushReact()
    expect_identical(nrow(capture$last$df), 50L)
  })
})

test_that("a failing graph surfaces a translated, readable error", {
  store <- new_data_store()
  store$selected_cols("Sepal.Length")

  testServer(mod_graphs_server, args = list(store = store), {
    session$userData$shiny.i18n <- list(lang = reactiveVal("en"))
    session$setInputs(graph = "Broken plot", draw = 1)
    session$flushReact()

    err <- tryCatch({ output$graph_plot; NULL }, error = function(e) e)
    expect_s3_class(err, "error")
    expect_match(conditionMessage(err), "Error while drawing the graph")
    expect_match(conditionMessage(err), "boom")
  })
})

test_that("a language change preserves the selected graph", {
  lang <- reactiveVal("en")
  store <- new_data_store()
  store$selected_cols("Sepal.Length")

  testServer(mod_graphs_server, args = list(store = store), {
    session$userData$shiny.i18n <- list(lang = lang)
    session$setInputs(graph = "Probe plot")
    session$flushReact()
    expect_true(grepl('value="Probe plot"[^/]*checked',
                      output$graph_choices$html))

    lang("es")
    session$flushReact()
    expect_true(grepl('value="Probe plot"[^/]*checked',
                      output$graph_choices$html))
  })
})
