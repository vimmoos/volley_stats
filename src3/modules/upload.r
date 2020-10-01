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
        airDatepickerInput (paste0("game_date",id),
                            label = "Select the date of the game",
                            autoClose = TRUE,
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
                                        createFilter = "[a-z]+")),
        fluidRow (
            column (fileInput(paste0("file",id),
                              "Choose the csv file of the game", width = "60%",
                              multiple = FALSE, accept = accept),width=8),
            column (downloadButton (paste0 ("template_g",id),
                                    "Download Template"),width=4)),

        ## dataTableOutput (paste0 ("contents",id)),
        actionButton (paste0 ("upload_l",id),
                      label = "Upload locally",
                      icon = icon ("upload")),
        actionButton (paste0 ("upload_d",id),
                      label = "Upload to database",
                      icon = icon ("globe"))


    )
}

b_upload_game <- function(input,output,session,id,data)
{

    observe(updateSelectizeInput (session,paste0 ("opponent",id),
                          selected = NULL,
                          choices = levels(unique(data()$Opponent)),
                          server=TRUE))
    observe_confirmation (session,input [[paste0 ("upload_d",id)]],
                          is.null (input [[paste0 ("game_date",id)]]) |
                          is.null (input [[paste0 ("opponent",id)]]) |
                          is.null (input [[paste0 ("file",id)]]),
                          paste0  ("confirm_d",id), "Are you sure to upload in the database?",
                          tags$ul (tags$li (paste ("Date:",input [[paste0 ("game_date",id)]])),
                                   tags$li (paste ("Opponent:",input [[paste0 ("opponent",id)]])),
                                   tags$li (paste ("File:",input [[paste0 ("file",id)]]$name))))


    observe_confirmation (session,input [[paste0 ("upload_l",id)]],
                          is.null (input [[paste0 ("game_date",id)]]) |
                          is.null (input [[paste0 ("opponent",id)]]) |
                          is.null (input [[paste0 ("file",id)]]),
                          paste0  ("confirm_l",id), "Are you sure to upload locally?",
                          tags$ul (tags$li (paste ("Date:",input [[paste0 ("game_date",id)]])),
                                   tags$li (paste ("Opponent:",input [[paste0 ("opponent",id)]])),
                                   tags$li (paste ("File:",input [[paste0 ("file",id)]]$name))))

    games <- reactive ({
        req(input [[paste0 ("file",id) ]])
        tryCatch(read.csv(input [[paste0 ("file",id)]]$datapath),
                 error = function(e)
                     stop(safeError(e)))})

    observeEvent (input [[paste0 ("confirm_d",id)]],
                  if (input [[paste0 ("confirm_d",id)]])
                      with_db ({
                          add <- cadd_games (games ())
                          if (add$bool){
                              add$fun (opponent = input [[paste0 ("opponent",id)]],
                                       date = input [[paste0 ("game_date",id)]])
                              showNotification (
                                  paste (input [[paste0 ("file",id)]]$name,
                                         "Uploaded successfully"),
                                  type ="message")}
                          else sendSweetAlert (
                                   session,title = "File format Error",
                                   text = "There are probably typos,Please check the template!",
                                   type = "error")}))

    output [[paste0 ("template_g",id)]] <-
        downloadHandler (filename = function () "template_game.csv",
                         content = function (file)
                             write.csv (games_template,file,row.names=FALSE))


    output [[paste0 ("contents",id)]] <-
        renderDataTable(games (),
                        options = c (scrollX = "true", scrollY= "true",
                                     scrollCollapse = "true",editable = T)
            )
    }

module_upload_game <- function (borf) if (borf) b_upload_game else f_upload_game
