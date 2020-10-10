library(shiny)
library(shinydashboard)
library(shinyWidgets)
source("./modules/selector.r")
source("./modules/mode_sel.r")

module_frontend(
    name = dropmenu,
    args = alist(
        title_sel = ,
        icon = ,
        title = "Settings",
        status="primary",
        right = TRUE,
        tooltip = TRUE,
        label = "Settings"),
    body = dropdownButton(
        status= status,
        right= right,
        icon = icon,
        tooltip = tooltip ,
        label = label,
        tags$h3(title),

        get_frontend (selector,list (ID (sel),title_sel)),

        fluidRow (
            column (get_frontend (mode_sel,list (ID (distribution),
                                                 "Distribution",inline = TRUE)),
                    uiOutput (ID (warning)),
                    width = 6),

            column (get_frontend (mode_sel,list (ID (set_game),"Set/Game",inline=TRUE)),
                    tags$p ("decide the context in which the probability of the event will be calculated"),
                    width = 6))))

module_backend (
    name = dropmenu,
    args = alist (choices = ,
                  selected = NULL),
    body = {
            dist <- get_backend (mode_sel,list (ID (distribution)))

            bind_output (warning,
                         renderUI (if (dist())
                                      tags$p ("distribution mode need at least 3 data point for each event",
                                              style="color: #dd4b39;")
                                      else tags$p ()))




            list(game_set = get_backend (mode_sel,list (ID (set_game))),
                            dist = dist,
                            selected = get_backend (selector,
                                                    list (ID (sel),
                                                          choices = choices ,
                                                             selected = selected)))})
