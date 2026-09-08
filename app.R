# This file starts the app.
# It loads the packages, finds the app folder, and builds the app environment.
# Then it loads all code files in order and starts Shiny.

# This block installs and loads the packages that the app needs.
required_packages <- c("shiny", "bslib", "DT", "ggplot2", "qcc", "e1071", "shiny.i18n", "colourpicker")
for (package in required_packages) {
  if (!requireNamespace(package, quietly = TRUE)) install.packages(package)
  library(package, character.only = TRUE)
}

# This block finds the app root folder.
# The root folder is the folder that holds core/ and modules/.
app_root <- local({
  # This helper checks that a folder holds core/ and modules/.
  has_app_layout <- function(folder) {
    dir.exists(file.path(folder, "core")) && dir.exists(file.path(folder, "modules"))
  }

  # R records the file of each sourced file.
  # This helper collects the folders of those files.
  from_source_frames <- function() {
    source_dirs <- Filter(is.character, lapply(rev(sys.frames()), function(frame) {
      tryCatch(get("ofile", envir = frame, inherits = FALSE), error = function(e) NULL)
    }))
    if (length(source_dirs)) dirname(unlist(source_dirs, use.names = FALSE)) else character(0)
  }

  # This helper reads the folder from the --file= argument of Rscript.
  from_rscript_arg <- function() {
    file_args <- grep("^--file=", commandArgs(), value = TRUE)
    if (length(file_args)) dirname(sub("^--file=", "", file_args)) else character(0)
  }

  # This helper collects the working directory and its parent folders.
  from_wd_ancestors <- function() {
    folder <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
    ancestors <- folder
    for (i in 1:10) {
      folder <- dirname(folder)
      ancestors <- c(ancestors, folder)
      if (identical(folder, dirname(folder))) break  # reached filesystem root
    }
    ancestors
  }

  # The code uses the first candidate folder that has the app layout.
  candidates <- unique(c(from_source_frames(), from_rscript_arg(), from_wd_ancestors()))
  found <- Filter(has_app_layout, candidates)
  if (!length(found)) {
    stop("App root not found: no candidate directory contains both core/ ",
         "and modules/. Launch the app from inside the project, or source ",
         "app.R directly.")
  }
  normalizePath(found[1], winslash = "/", mustWork = TRUE)
})

# The app environment holds all app code.
# It keeps the global workspace clean.
app_env <- new.env(parent = globalenv())

# The app pins the modal functions of the shiny package here.
# A same-named object in the global workspace would otherwise replace them.
app_env$showModal <- shiny::showModal
app_env$removeModal <- shiny::removeModal
app_env$showNotification <- shiny::showNotification

# This helper builds a path from the app root.
app_env$app_file <- function(...) file.path(app_root, ...)
app_file <- app_env$app_file

# This block loads the core files.
# The helper files load first, and the UI and the server load last.
source(app_file("core", "i18n.R"), local = app_env)
source(app_file("core", "data_store.R"), local = app_env)
source(app_file("core", "operation_registry.R"), local = app_env)
source(app_file("core", "graph_params.R"), local = app_env)
source(app_file("core", "graph_registry.R"), local = app_env)
source(app_file("core", "module_registry.R"), local = app_env)
source(app_file("core", "ui_helpers.R"), local = app_env)

source(app_file("core", "ui.R"), local = app_env)
source(app_file("core", "server.R"), local = app_env)

# This line starts the Shiny app.
shinyApp(app_env$ui, app_env$server)
