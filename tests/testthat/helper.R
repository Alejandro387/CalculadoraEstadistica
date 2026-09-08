
# This helper file prepares the environment for the test files.

# This function finds the app root.
# It checks each parent folder for core/ and modules/.
find_app_root <- function(start = getwd()) {
  folder <- normalizePath(start, winslash = "/", mustWork = TRUE)
  repeat {
    if (dir.exists(file.path(folder, "core")) && dir.exists(file.path(folder, "modules"))) {
      return(folder)
    }
    if (identical(folder, dirname(folder))) {
      stop("App root not found above ", start,
           "; run the tests from inside the project.")
    }
    folder <- dirname(folder)
  }
}

# These lines load the packages that the tests need.
library(shiny)
library(bslib)
library(ggplot2)

app_root <- find_app_root()

app_env <- new.env(parent = globalenv())
app_env$app_file <- function(...) file.path(app_root, ...)

source(app_env$app_file("core", "i18n.R"), local = app_env)
source(app_env$app_file("core", "data_store.R"), local = app_env)
source(app_env$app_file("core", "graph_params.R"), local = app_env)
source(app_env$app_file("core", "graph_registry.R"), local = app_env)
source(app_env$app_file("core", "ui_helpers.R"), local = app_env)

# These stubs replace the modal functions, so the tests run without a user interface.
app_env$showModal <- function(ui, session = getDefaultReactiveDomain()) NULL
app_env$removeModal <- function(session = getDefaultReactiveDomain()) NULL
app_env$showNotification <- function(...) NULL

# This environment holds the graphs module for the tests.
mod_env <- new.env(parent = app_env)
source(app_env$app_file("modules", "mod_graphs.R"), local = mod_env)

# This line copies the app objects to the global environment for the tests.
# The modal stubs must not reach the global environment.
# A stub there would also swallow the modals of a real app in this session.
keep <- setdiff(ls(app_env, all.names = TRUE), c("showModal", "removeModal", "showNotification"))
list2env(mget(keep, envir = app_env), envir = globalenv())
