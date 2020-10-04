library(shiny)
library(shinydashboard)
source ("./modules/selector.r")
source ("./modules/utils.r")
source ("./modules/db_driver.r")

f_create_players <- function(id,accept)
{
    box(
        id = id,
        title =  tags$p ("Create Players",style= "font-size: 300%;"),
        status = "warning",
        solidHeader =  TRUE,
        collapsible =  TRUE,
        useSweetAlert ("dark"),
        selectizeInput (paste0 ("team",id),choices = list ("pippo"),
                        selected =NULL, label = "Select a team",
                        options = list (create = FALSE,
                                        allowEmptyOption = FALSE,
                                        preload = TRUE,
                                        createFilter = "[a-z]+")),

        tabBox (
            width = 12,
            title = "Player Position",
            selected = paste0 ("multiple",id),
            tabPanel ( "Single",
                      value = paste0("single",id),

                      textInput(paste0 ("player_name",id),
                                label = "insert the name of the player"),
                      selectInput(paste0 ("player_pos"),
                                  label = "Select the position",
                                  choices = list("Middle_Blocker", "Setter", "Outside_Hitter",
                                                 "Opposite","Libero")),
                      ),
            tabPanel ("Multiple",
                      value = paste0("multiple",id),
                      fluidRow (column (fileInput(paste0("position_f",id),
                                                  "Choose the csv file for the positions",
                                                  width = "60%", multiple = FALSE,
                                                  accept = accept),width=8),
                                column (downloadButton (paste0 ("template_p",id),
                                                        "Download Template"),
                                        tags$p ("Please use the same position that are in the template, if there are typos the file will be rejected",
                                                style="color: #dd4b39;")
                                       ,width=4)),
                      dataTableOutput (paste0 ("contents",id)))),

        actionButton (paste0 ("create_players",id),
                      label = "Create Players",
                      icon = icon ("upload")))
}

b_create_players <- function(input,output,session,id)
{

    observe_confirmation (session, input [[paste0 ("create_players",id)]],
                          is.null (input [[paste0 ("team",id)]]) |
                          !xor(is.null (input [[paste0 ("position_f",id)]]),
                           (is.null (input [[paste0 ("player_name",id)]]) |
                            is.null (input [[paste0 ("player_pos",id)]])) ),
                          paste0 ("confirm_d",id), "Are you sure to upload?",
                          tags$ul(tags$li (paste ("Team:",input [[paste0 (
                                                                     "team",
                                                                     id)]])),
                                  if (is.null (input [[paste0 ("position_f")]])){
                                      tags$li (paste ("Player:",
                                                      input [[paste0 ("player_name",
                                                                      id)]]))
                                      tags$li (paste ("Position:",
                                                      input [[paste0 ("player_pos",id)] ]))}
                                  else
                                                          tags$li (paste ("File:",
                                                                          input [[paste0 ("position_f")]]$name))

                                  ))

    positions <- reactive ({
        req(input [[paste0 ("position_f",id) ]])
        tryCatch(read.csv(input [[paste0 ("position_f",id)]]$datapath),
                 error = function(e)
                     stop(safeError(e)))})

    ## observeEvent (input [[paste0 ("confirm_d",id)]],
    ##               if (input [[paste0 ("confirm_d",id)]])
    ##                   with_db ({add <- cadd_position (positions ())
    ##                       if (add$bool) {
    ##                           add$fun (n_team=input [[paste0 ("team",id)]])
    ##                           showNotification (
    ##                               paste (input [[paste0 ("position_f",id)]]$name,
    ##                                      "Uploaded successfully"),
    ##                               type="message")}
    ##                       else sendSweetAlert (
    ##                                session,title= "File format Error",
    ##                                text = "There are probably typos, Please check the template!",
    ##                                type = "error")}))


    output [[paste0 ("template_p",id)]] <-
        downloadHandler (filename = function () "template_position.csv",
                         content = function (file)
                             write.csv (position_template,file,row.names=FALSE))

    output [[paste0 ("contents",id)]] <-
        renderDataTable(positions (),
            options = c (scrollX = "true", scrollY= "true",
                         scrollCollapse = "true",editable = "true"))
}

module_create_players <- function (borf) if (borf) b_create_players else f_create_players
