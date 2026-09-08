# This file creates the translator for the app.
# The key language is English.
library(shiny.i18n)

# This line reads the translation files from translations/standard.
i18n <- Translator$new(translation_csvs_path = app_file("translations", "standard"))
# The key column of the translation files holds the English strings.
i18n$set_translation_language("en")

# This line turns on the translation in the browser.
i18n$use_js()
