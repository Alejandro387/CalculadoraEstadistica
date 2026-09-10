# These tests check the translation discovery of the i18n module.

# This helper builds a language folder with a base table and optional
# extra tables. Each table is a named vector of key -> translation rows.
make_language_folder <- function(root, folder, code, base, extras = list()) {
  dir.create(file.path(root, folder), recursive = TRUE)
  base <- data.frame(en = names(base), value = unname(base), check.names = FALSE)
  names(base)[2] <- code
  write.csv(base, file.path(root, folder, paste0("translation_", code, ".csv")),
            row.names = FALSE, fileEncoding = "UTF-8")
  for (i in seq_along(extras)) {
    extra <- data.frame(en = names(extras[[i]]), value = unname(extras[[i]]), check.names = FALSE)
    names(extra)[2] <- code
    write.csv(extra, file.path(root, folder, names(extras)[i]),
              row.names = FALSE, fileEncoding = "UTF-8")
  }
}

test_that("discover_translations loads the base table of each language folder", {
  root <- tempfile("i18n_test_"); dir.create(root)
  make_language_folder(root, "Spanish", "es", c("Hello" = "Hola", "Bye" = "Adiós"))
  make_language_folder(root, "Italian", "it", c("Hello" = "Ciao"))

  tables <- discover_translations(root, refresh = TRUE)
  expect_setequal(names(tables), c("es", "it"))
  expect_setequal(tables$es$en, c("Hello", "Bye"))
  expect_identical(tables$es$es[tables$es$en == "Hello"], "Hola")
})

test_that("discover_translations appends the extra csv files to the base", {
  root <- tempfile("i18n_test_"); dir.create(root)
  make_language_folder(root, "Spanish", "es",
                       c("Hello" = "Hola"),
                       list(extra_words.csv = c("Bye" = "Adiós")))

  tables <- discover_translations(root, refresh = TRUE)
  expect_setequal(tables$es$en, c("Hello", "Bye"))
})

test_that("a key defined again keeps its last translation", {
  root <- tempfile("i18n_test_"); dir.create(root)
  make_language_folder(root, "Spanish", "es",
                       c("Hello" = "Hola"),
                       list(extra_words.csv = c("Hello" = "Buenas")))

  expect_warning(tables <- discover_translations(root, refresh = TRUE),
                 "the last definition wins")
  expect_identical(tables$es$es[tables$es$en == "Hello"], "Buenas")
  # The override leaves a single row per key.
  expect_equal(nrow(tables$es), 1)
})

test_that("a folder without a base translation_*.csv is skipped with a warning", {
  root <- tempfile("i18n_test_"); dir.create(root)
  make_language_folder(root, "Spanish", "es", c("Hello" = "Hola"))
  dir.create(file.path(root, "Empty"))

  expect_warning(tables <- discover_translations(root, refresh = TRUE),
                 "no translation_\\*\\.csv base file")
  expect_setequal(names(tables), "es")
})

test_that("a base file without its own language column is skipped with a warning", {
  root <- tempfile("i18n_test_"); dir.create(root)
  dir.create(file.path(root, "French"))
  write.csv(data.frame(en = "Hello", es = "Hola"),
            file.path(root, "French", "translation_fr.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")

  expect_warning(tables <- discover_translations(root, refresh = TRUE),
                 "no 'fr' column")
  expect_length(tables, 0)
})

test_that("build_translator serves the languages of all the folders", {
  root <- tempfile("i18n_test_"); dir.create(root)
  make_language_folder(root, "Spanish", "es",
                       c("Hello" = "Hola"),
                       list(extra_words.csv = c("Bye" = "Adiós")))
  make_language_folder(root, "Italian", "it", c("Hello" = "Ciao", "Bye" = "Ciao ciao"))

  # The Translator warns about the missing config yaml of shiny.i18n.
  translator <- suppressWarnings(build_translator(root, refresh = TRUE))
  expect_true(all(c("es", "it") %in% translator$get_languages()))
  translator$set_translation_language("es")
  expect_identical(translator$t("Hello"), "Hola")
  expect_identical(translator$t("Bye"), "Adiós")
  translator$set_translation_language("it")
  expect_identical(translator$t("Hello"), "Ciao")
})

test_that("build_translator rejects tables with different key columns", {
  root <- tempfile("i18n_test_"); dir.create(root)
  make_language_folder(root, "Spanish", "es", c("Hello" = "Hola"))
  dir.create(file.path(root, "Odd"))
  write.csv(data.frame(key = "Hello", it = "Ciao"),
            file.path(root, "Odd", "translation_it.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")

  expect_error(build_translator(root, refresh = TRUE), "same key column")
})
