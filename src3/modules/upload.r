library(shiny)
library(shinydashboard)
source ("./modules/selector.r")
source ("./modules/utils.r")

f_upload_game <- function(id,accept)
{
    box(
        id = id,
        title =  tags$p ("Upload",style= "font-size: 300%;"),
        status = "info",
        solidHeader =  TRUE,
        collapsible =  TRUE,
        useSweetAlert ("dark"),
        module_selector (0) (id),
        airDatepickerInput (paste0("game_date",id),
                            label = "Select the date of the game",
                            autoClose = TRUE,
                            maxDate = Sys.Date (),
                            startView= Sys.Date (),
                            addon = 'none'
                            ),
        selectizeInput (paste0 ("opponent",id),choices = NULL,
                        label = "Select/create the Opponent",
                        options = list (create = TRUE,
                                        createOnBlur = TRUE,
                                        allowEmptyOption = FALSE,
                                        placeholder = "Type an Opponent",
                                        preload = TRUE,
                                        onInitialize = I('function() { this.setValue(""); }'),
                                        createFilter = "[a-z]+")
                        ),
        fileInput(paste0("file",id),
                  "Choose the csv file of the game", width = "30%",
                  multiple = FALSE, accept = accept),

        ## dataTableOutput (paste0 ("contents",id)),
        actionButton (paste0 ("upload_l",id),
                      label = "Upload locally",
                      icon = icon ("upload")),
        actionButton (paste0 ("upload_d",id),
                      label = "Upload to database",
                      icon = icon ("upload"))


    )
}

b_upload_game <- function(input,output,session,id,data)
{

    sel <- module_selector (TRUE) (input,output,session,quote (Team),data,
        "Select a Team",id,filter=FALSE)

    observe(updateSelectizeInput (session,paste0 ("opponent",id),
                          selected = NULL,
                          choices = levels(unique(data()$Opponent)),
                          server=TRUE))
    ## output [[paste0 ("selecto",id)]] <- renderUI ( selectizeInput
    ##     (paste0("opponent",id), choices = , ) )

    observe_confirmation (session,input [[paste0 ("upload_d",id)]],
                          is.null (sel ()$selected) |
                          is.null (input [[paste0 ("game_date",id)]]) |
                          is.null (input [[paste0 ("opponent",id)]]) |
                          is.null (input [[paste0 ("file",id)]]),
                          paste0  ("confirm_d",id), "Are you sure to upload in the database?",
                          tags$ul (tags$li (paste ("Team:",sel ()$selected)),
                                   tags$li (paste ("Date:",input [[paste0 ("game_date",id)]])),
                                   tags$li (paste ("Opponent:",input [[paste0 ("opponent",id)]])),
                                   tags$li (paste ("File:",input [[paste0 ("file",id)]]$name))))


    observe_confirmation (session,input [[paste0 ("upload_l",id)]],
                          is.null (sel ()$selected) |
                          is.null (input [[paste0 ("game_date",id)]]) |
                          is.null (input [[paste0 ("opponent",id)]]) |
                          is.null (input [[paste0 ("file",id)]]),
                          paste0  ("confirm_l",id), "Are you sure to upload locally?",
                          tags$ul (tags$li (paste ("Team:",sel ()$selected)),
                                   tags$li (paste ("Date:",input [[paste0 ("game_date",id)]])),
                                   tags$li (paste ("Opponent:",input [[paste0 ("opponent",id)]])),
                                   tags$li (paste ("File:",input [[paste0 ("file",id)]]$name))))
    output [[paste0 ("contents",id)]] <-
        renderDataTable({
            req(input [[paste0 ("file",id) ]])

            tryCatch({df<-
                          read.csv(input [[paste0 ("file",id)]]$datapath)},
            error = function(e)
                stop(safeError(e)))
            print (df)
            df},options = c (scrollX = "true", scrollY= "true",
                             scrollCollapse = "true")
            )
    }

module_upload_game <- function (borf) if (borf) b_upload_game else f_upload_game
