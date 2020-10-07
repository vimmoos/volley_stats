library(shiny)
library(shinydashboard)
source ("./modules/selector.r")
source ("./modules/utils.r")

module_frontend (
    create_players,
    args = alist (accept=c ("csv",".csv","comma-separated-values")),
    title = "Create Players",
    status = "warning",
    width = 6,
    body = list (
        front_selector ("association","Select a Association"),
        front_selector ("team","Select a team"),

        tabBox (
            width = 12,
            id = paste0 ("players_tabs",id),
            title = "Player Position",
            selected = paste0 ("multiple",id),
            tabPanel ( "Single",
                      value = paste0("single",id),

                      textInput(paste0 ("player_name",id),
                                label = "insert the name of the player"),
                      selectInput(paste0 ("player_pos",id),
                                  label = "Select the position",
                                  choices = list("Middle_Blocker", "Setter", "Outside_Hitter",
                                                 "Opposite","Libero"))),
            tabPanel ("Multiple",
                      value = paste0("multiple",id),
                      fluidRow (column (fileInput(paste0("position_f",id),
                                                  "Choose the csv file for the positions",
                                                  width = "60%", multiple = FALSE,
                                                  accept = accept),width=8),
                                column (downloadButton (paste0 ("template_p",id),
                                                        "Download Template"),
                                        tags$p (paste ("Please use the same position that are in the template,\n",
                                                       "if there are typos the file will be rejected"),
                                                style="color: #dd4b39;")
                                       ,width=4)),
                      dataTableOutput (paste0 ("contents",id)))),
        actionButton (paste0 ("create_players",id),
                      label = "Create Players",
                      icon = icon ("upload"))))

module_backend (
    create_players,
    body={
        observe(back_selector ("association",
                               with_db (get_all_associations ())))

        observeEvent (get_in ("association"),
            back_selector ("team",
                           with_db (get_team_name(assoc = get_in ("association")))))

        upload_confirmation (
            session,
            what = get_in("create_players"),
            bool_err = isnull (get_in("team")) |
                (is.null (get_in("position_f")) &
                 (is.null (get_in("player_name")) |
                  get_in ("player_name") == "" |
                  is.null (get_in("player_pos")))) ,
            conf_id = "confirm_players",
            conf_title = "Are you sure to upload?",
            conf_text = tags$ul(tags$li (paste ("Team:",get_in ("team"))),
                                if (get_in("players_tabs") == paste0 ("single",id))
                                    tags$div(tags$li (paste ("Player:",
                                                             get_in ("player_name"))),
                                             tags$li (paste ("Position:",
                                                             get_in ("player_pos"))))
                                else
                                    tags$li (paste ("File:",
                                                    get_in("position_f")$name))),
            body = {
                t_id <- get_team_id (assoc = get_in ("association"),
                                             name = get_in ("team"))
                if (get_in ("players_tabs") == paste0 ("single",id))
                    add_player (name=get_in ("ploayer_name"),
                                pos = get_in ("player_pos"),
                                team_id = t_id)
                else{
                    add_players (poss = positions (),
                                 team_id = t_id)}})


        positions <- reactive ({
            req(get_in ("position_f"))
            tryCatch(read.csv(get_in("position_f")$datapath),
                     error = function(e)
                         stop(safeError(e)))})

        output [[paste0 ("template_p",id)]] <-
            downloadHandler (filename = function () "template_position.csv",
                             content = function (file)
                                 write.csv (position_template,file,row.names=FALSE))

        output [[paste0 ("contents",id)]] <-
            renderDataTable(positions (),
                            options = list(scrollX = "true", scrollY= "true",
                                           pageLength = 5,
                                           scrollCollapse = "true",editable = "true"))})
