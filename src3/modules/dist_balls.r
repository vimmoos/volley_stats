library(shiny)
library(shinydashboard)


f_upload_game <- function(id, accept) {
  box(
    id = id,
    title = tags$p("Upload", style = "font-size: 300%;"),
    status = "info",
    solidHeader = TRUE,
    collapsible = TRUE,
    fluidRow(
      valueBox(uiOutput(paste0("Outside_Hitter", id)),
        "Outside Hitter",
        icon = icon(""), color = "red"),
      valueBox(uiOutput(paste0("Middle_Blocker", id)),
        "Middle Blocker",
        icon = icon("thumbs-up"), color = "yellow"),
      valueBox(uiOutput(paste0("Opposite", id)), "Opposite",
        icon = icon("bomb"), color = "green")),


  )
}

b_upload_game <- function(input, output, session, id, data) {
  bind_outputs(data(), c(
    "Outside_Hitter", "Middle_Blocker",
    "Opposite"))


}

module_upload_game <- function(borf) if (borf) b_upload_game else f_upload_game
