library(shiny)
library(shinydashboard)
source ("./modules/selector.r")
source ("./modules/utils.r")

module_frontend (
    create_game,
    args = alist (accept=c ("csv",".csv","comma-separated-values")),
    title = "Upload Game",
    status = "info",
    width = 6,
    body = list (
        airDatepickerInput (paste0("game_date",id),
                            label = "Select the date of the game",
                            autoClose = TRUE,
                            startView= Sys.Date (),
                            maxDate = Sys.Date (),
                            addon = 'none'),
        fluidRow (
            column (width = 6,
                    front_selector ("team_ass","Select  Home Team Association"),
                    front_selector ("team_name","Select  Home Team name")),
            column (width = 6,
                    front_selector ("op_ass","Select  away Team Association"),
                    front_selector ("op_name","Select  away Team name"))),

        fluidRow (
            column (fileInput(paste0("file",id),
                              "Choose the csv file of the game", width = "60%",
                              multiple = FALSE, accept = accept),width=8),
            column (downloadButton (paste0 ("template_g",id),
                                    "Download Template"),width=4)),

        actionButton (paste0 ("upload_game",id),
                      label = "Upload Game",
                      icon = icon ("upload"))))
module_backend (
    create_game,
    body = {
        observe (updateAirDateInput (session,paste0 ("game_date",id),
                                 options = list (autoClose = 'true')))

        observe(back_selector ("team_ass",
                               with_db (
                                      get_all_associations ())))

        observeEvent (get_in ("team_ass"),
                      back_selector ("team_name",
                                     with_db (
                                         get_team_name(assoc = get_in ("team_ass")))))

        observe(back_selector ("op_ass",
                               with_db (get_all_associations ())))

        observeEvent ({get_in ("op_ass")
            get_in ("team_name")},
            back_selector ("op_name",
            (as_tibble (with_db (get_team_name(assoc = get_in ("op_ass")))) %>%
             filter (value != get_in ("team_name")))$value))



        observe_confirmation (
            session,
            what =get_in("upload_game"),
            bool_err =
                isnull (get_in("game_date"),get_in("team_name"),
                        get_in("team_ass"),get_in("op_name"),
                        get_in("op_ass"),get_in("file")),
            conf_id = "confirm_game",
            conf_title = "Are you sure to upload locally?",
            conf_text = tags$ul (tags$li (paste ("Date:",get_in("game_date"))),
                                   tags$li (paste ("Home Team:",get_in(
                                                                    "team_name"))),
                                   tags$li (paste ("Away Team:",get_in (
                                                                    "op_name"))),
                                 tags$li (paste ("File:",get_in("file")$name))),
            body ={
                team_id <- get_team_id (assoc = get_in ("team_ass"),
                                        name = get_in ("team_name"))
                op_id <- get_team_id (assoc = get_in ("op_ass"),
                                      name = get_in ("op_name"))
                game_id <- add_game (opp_id = op_id,
                                     team_id = team_id,
                                     date = get_in ("game_date"))
                add_stats (df = games (),
                                opp_id = op_id,
                                team_id = team_id,
                                game_id = game_id)})



        games <- reactive ({
            req(input [[paste0 ("file",id) ]])
            tryCatch(read.csv(get_in("file")$datapath),
                     error = function(e)
                         stop(safeError(e)))})

        output [[paste0 ("template_g",id)]] <-
            downloadHandler (filename = function () "template_game.csv",
                             content = function (file)
                                 write.csv (games_template,file,row.names=FALSE))


        output [[paste0 ("contents",id)]] <-
            renderDataTable(games (),
                            options = c (scrollX = "true", scrollY= "true",
                                         scrollCollapse = "true",editable = T))})
