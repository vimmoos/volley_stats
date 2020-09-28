library(shiny)
library(shinydashboard)
source ("./modules/selector.r")
source ("./modules/utils.r")

f_create_team <- function(id,accept)
{
    box(
        id = id,
        title =  tags$p ("Create Team",style= "font-size: 300%;"),
        status = "success",
        solidHeader =  TRUE,
        collapsible =  TRUE,
        useSweetAlert ("dark"),
        textInput(paste0 ("team",id),
                  label = "insert the name of the team"),

        fileInput(paste0("position_f",id),
                  "Choose the csv file of team name and position",
                  width = "30%", multiple = FALSE, accept = accept),

        dataTableOutput (paste0 ("contents",id)),
        actionButton (paste0 ("upload_l",id),
                      label = "Upload locally",
                      icon = icon ("upload")),
        actionButton (paste0 ("upload_d",id),
                      label = "Upload in database",
                      icon = icon ("upload"))


    )
}
b_create_team <- function(input,output,session,id)
{

    ## observeEvent (input)
    observe_confirmation (session, input [[paste0 ("upload_d",id)]],
                          is.null (input [[paste0 ("team",id)]]) |
                          is.null (input [[paste0 ("position_f",id)]]),
                          paste0 ("confirm_d",id), "Are you sure to upload?",
                          tags$ul(tags$li (paste ("Team:",input [[paste0 (
                                                                     "team",
                                                                     id)]])),
                                  tags$li (paste ("Position:",
                                                  input [[paste0 ("position_f",id)]]$name))))

    observe_confirmation (session, input [[paste0 ("upload_l",id)]],
                          is.null (input [[paste0 ("team",id)]]) |
                          is.null (input [[paste0 ("position_f",id)]]),
                          paste0 ("confirm_l",id), "Are you sure to upload?",
                          tags$ul(tags$li (paste ("Team:",input [[paste0 (
                                                                     "team",
                                                                     id)]])),
                                  tags$li (paste ("Position:",
                                                  input [[paste0 ("position_f",id)]]$name))))
    output [[paste0 ("contents",id)]] <-
        renderDataTable({
            req(input [[paste0 ("position_f",id) ]])

            tryCatch({df<-
                          read.csv(input [[paste0 ("position_f",id)]]$datapath)},
            error = function(e)
                stop(safeError(e)))
            df},options = c (scrollX = "true", scrollY= "true",
                             scrollCollapse = "true")
            )
    }

module_create_team <- function (borf) if (borf) b_create_team else f_create_team
