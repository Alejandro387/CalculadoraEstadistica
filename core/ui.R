# This file defines the user interface of the app.
ui <- page_sidebar(
  title = i18n$t("Data Table Editor"),
  theme = bs_theme(preset = 'sandstone'),
  shiny.i18n::usei18n(i18n),
  sidebar = sidebar(
    width = 300,

    # The selector changes the language of the interface.
    selectInput(
      "selected_language",
      i18n$t("Change language"),
      choices = setNames(
        i18n$get_languages(),
        c(en = "English", es = "Espa\u00f1ol", it = "Italiano")[i18n$get_languages()]
      ),
      selected = i18n$get_translation_language()
    ),

    # This line places the sidebar modules in the accordion.
    do.call(accordion, c(list(open = "upload"), build_module_ui("sidebar")))
  ),
  # This line places the main modules in the main area.
  do.call(tagList, build_module_ui("main")),
  # This script opens a link in a new browser tab when the app sends the openGraphTab message.
  tags$script(HTML(
    "Shiny.addCustomMessageHandler('openGraphTab', function(url) {
       window.open(url, '_blank');
     });"
  ))
)
