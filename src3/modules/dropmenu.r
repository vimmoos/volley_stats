library(shiny)
library(shinydashboard)
library(shinyWidgets)
source("./modules/selector.r")
source("./modules/mode_sel.r")

f_dropmenu <- function(id,title)
{
    dropdownButton(
        tags$h3("Settings"), module_selector (0) (id),
        column (module_mode_sel (0) (paste0("distribution",id),"Distribution",inline=TRUE),
                uiOutput (paste0("warning",id)),
                width = 6),
        column (module_mode_sel(0) (paste0 ("game",id),"Set/Game",inline=TRUE),
                tags$p ("decide the context in which the probability of the event will be calculated"),
                width = 6),

        status= "primary",
        right= TRUE,
        icon = icon ("gear"),
        tooltip = TRUE,
        label = "Settings"

    )
}

b_dropmenu <-
function(input,output,session,filter_group,data,title,id,filter=FALSE)
{
    dist <- module_mode_sel (TRUE) (input,output,
        session,paste0 ("distribution",id))

    game_set <- module_mode_sel (TRUE) (input,output,session,
        paste0 ("game",id))

    output [[paste0 ("warning",id)]]<-
        renderUI (if (dist())
                      tags$p ("distribution mode need at least 3 data point for each event",
                              style="color: #dd4b39;")
                  else tags$p ())



    c (game_set = game_set,
        dist = dist,

       selected =
           module_selector (TRUE) (input,
               output,session,
               filter_group,
               data,
               title,
               id,filter=filter))

}

module_dropmenu <- function (borf) if (borf) b_dropmenu else f_dropmenu
