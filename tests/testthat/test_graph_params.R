# These tests check the graph parameter helpers.

# The mock session lets the reactive helpers run outside a Shiny app.
domain <- MockShinySession$new()
with_domain <- function(expr) withReactiveDomain(domain, expr)

test_that("parse_resolution accepts valid two-integer specs", {
  res <- with_domain(parse_resolution("600, 400"))
  expect_true(res$ok)
  expect_identical(res$size, c(600, 400))
  expect_identical(with_domain(parse_resolution("100,50"))$size, c(100, 50))
})

test_that("parse_resolution falls back to the default when blank", {
  blank <- with_domain(parse_resolution(""))
  expect_true(blank$ok)
  expect_identical(blank$size, default_resolution)
  expect_identical(with_domain(parse_resolution(NULL))$size, default_resolution)
})

test_that("parse_resolution rejects bad input with a message", {
  # Each entry is a resolution text that the parser rejects.
  bad <- c(
    "600",             # one number
    "600, 400, 100",   # three numbers
    "600, abc",        # non-numeric
    "0, 400",          # non-positive
    "-1, 400",         # negative
    "600, 20000",      # above max_resolution
    "600.5, 400"       # fractional pixels
  )
  for (text in bad) {
    res <- with_domain(parse_resolution(text))
    expect_false(res$ok, info = text)
    expect_null(res$size, info = text)
    expect_match(res$msg, "Not a valid resolution", info = text)
  }
})

test_that("parse_colour_vector parses colour lists", {
  res <- with_domain(parse_colour_vector("#ff0000, blue"))
  expect_true(res$ok)
  expect_identical(res$colours, c("#ff0000", "blue"))
})

test_that("parse_colour_vector treats blank input as empty", {
  res <- with_domain(parse_colour_vector(""))
  expect_true(res$ok)
  expect_identical(res$colours, character(0))
  expect_identical(with_domain(parse_colour_vector(NULL))$colours, character(0))
})

test_that("parse_colour_vector rejects non-colours with a helpful message", {
  res <- with_domain(parse_colour_vector("red, notacolour"))
  expect_false(res$ok)
  expect_match(res$msg, "notacolour")
})

test_that("t_sprintf substitutes and survives missing format specifiers", {
  expect_identical(
    with_domain(t_sprintf("Colour vector set (%d colours)", 3)),
    "Colour vector set (3 colours)"
  )
  expect_identical(
    with_domain(t_sprintf("Colour vector set (%d colours)")),
    "Colour vector set (%d colours)"
  )
})

test_that("default_params names entries by param id", {
  specs <- list(p_num("bins", "Bins", 30, min_val = 1), p_text("title", "Title"))
  expect_identical(default_params(specs), list(bins = 30, title = ""))
})

test_that("collect_params reads live input values and falls back to defaults", {
  specs <- list(p_num("bins", "Bins", 30, min_val = 1, max_val = 100))
  expect_identical(collect_params(specs, list(param_bins = 50))$bins, 50)
  expect_identical(collect_params(specs, list(param_bins = 500))$bins, 100)
  expect_identical(collect_params(specs, list(param_bins = "abc"))$bins, 30)
  expect_identical(collect_params(specs, list())$bins, 30)
})

test_that("collect_params passes through colour and text values", {
  specs <- list(p_colour("fill", "Fill", "#1f77b4"), p_text("title", "Title"))
  expect_identical(
    collect_params(specs, list(param_fill = "#ff0000", param_title = "A")),
    list(fill = "#ff0000", title = "A")
  )
  expect_identical(
    collect_params(specs, list(param_fill = "", param_title = "")),
    list(fill = "#1f77b4", title = "")
  )
})

test_that("preview_resolution scales down but never up", {
  expect_identical(preview_resolution(c(600, 400)), c(600, 400))
  expect_identical(preview_resolution(c(2000, 1000)), c(1000, 500))
  expect_identical(preview_resolution(c(100, 5000)), c(20, 1000))
})
