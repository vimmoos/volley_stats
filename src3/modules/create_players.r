library(shiny)
library(shinydashboard)
source ("./modules/selector.r")
source ("./modules/utils.r")

module_frontend_box (
    create_players,
    args = alist (accept=c ("csv",".csv","comma-separated-values")),
    title = "Create Players",
    status = "warning",
    width = 6,
    body = list (
        get_frontend (selector,alist(ID (association),"Select an Association")),
        get_frontend(selector,alist(ID (team) ,"Select a Team")),

        tabBox (
            width = 12,
            id = ID (players_tabs),
            title = "Player Position",
            selected = ID (multiple) ,
            tabPanel ( "Single",
                      value = ID (single) ,

                      textInput(ID (player_name),
                                label = "insert the name of the player"),
                      selectInput(ID (player_pos),
                                  label = "Select the position",
                                  choices = list("Middle_Blocker", "Setter", "Outside_Hitter",
                                                 "Opposite","Libero"))),
            tabPanel ("Multiple",
                      value = ID (multiple) ,
                      fluidRow (column (fileInput(ID (position_f) ,
                                                  "Choose the csv file for the positions",
                                                  width = "70%", multiple = FALSE,
                                                  accept = accept),width=8),
                                column (downloadButton (ID (template_p),
                                                        "Download Template"),
                                        tags$p (paste ("Please use the same position that are in the template,\n",
                                                       "if there are typos the file will be rejected"),
                                                style="color: #dd4b39;")
                                       ,width=4)),
                      dataTableOutput (ID (contents)))),
        actionButton (ID (create_players),
                      label = "Create Players",
                      icon = icon ("upload"))))

module_backend (
    create_players,
    body={
        assoc <- get_backend (selector,alist (ID (association) ,
                                              choices =  with_db (get_all_associations ())))

        team <- get_backend (selector,alist (ID (team),
                                             reactive = TRUE,
                                             choices = reactive (with_db (get_team_name(assoc = assoc ())))))

        upload_confirmation (
            session,
            what = get_in(create_players),
            bool_err = isnull (get_in(team)) |
                (is.null (get_in(position_f)) &
                 (is.null (get_in(player_name)) |
                  get_in (player_name) == "" |
                  is.null (get_in(player_pos)))) ,
            conf_id = confirm_players,
            conf_title = "Are you sure to upload?",
            conf_text = tags$ul(tags$li (paste ("Team:",get_in (team))),
                                if (get_in(players_tabs) == ID (single))
                                    tags$div(tags$li (paste ("Player:",
                                                             get_in(player_name))),
                                                  tags$li (paste ("Position:",
                                                                  get_in(player_pos))))
                                else
                                    tags$li (paste ("File:",
                                                    get_in(position_f)$name))),
            body = {
                t_id <- get_team_id (assoc = get_in(association),
                                             name = get_in(team))
                if (get_in(players_tabs) == ID (single))
                    add_player (name=get_in(player_name),
                                     pos = get_in(player_pos),
                                     team_id = t_id)
                else{
                    add_players (poss = positions (),
                                 team_id = t_id)}})


        positions <- reactive ({
            req(get_in(position_f))
            tryCatch(read.csv(get_in(position_f)$datapath),
                     error = function(e)
                         stop(safeError(e)))})

        bind_output (template_p,downloadHandler (filename = function () "template_position.csv",
                             content = function (file)
                                 write.csv (position_template,file,row.names=FALSE)) )



        bind_output (contents,renderDataTable(positions (),
                                              options = list(scrollX = "true", scrollY= "true",
                                                             pageLength = 5,
                                                             scrollCollapse = "true",editable = "true")))
    })
