source("./modules/attack.r")
source("./modules/serve.r")
source("./modules/pass.r")
source("./modules/selector.r")
source("./modules/mode_sel.r")
source("./modules/dropmenu.r")
source ("./modules/upload_game.r")
source ("./modules/create_team.r")
source ("./modules/create_players.r")
source("./modules/utils.r")
source ("./db_driver/driver.r")

source ("./utils.r")
library (tidyverse)
library(data.table)

module_server <- function(input,output,session)
{
    filtered_fun_team <- function (x){
        sel <- opt_team$selected ()
        if (sel == "All")
            x %>%
                select (-Position) %>%
                summarise_each (partial (mean,na.rm=TRUE))
        else
            x %>%
                filter (Position == sel)}

    assoc <- get_backend (selector,
                          alist(id ="select_ass",
                                choices = with_db ((team_with_stats ()%>% collect) $Association)))

    team <-
        get_backend (selector,
                     alist ("select_team",
                            reactive = TRUE,
                            choices =
                                reactive ({
                                    req (assoc ())
                                    get_choices (with_db (
                                    team_with_stats () %>%
                                    collect %>% filter (Association == assoc ())))})))


    opt <-
        get_backend (dropmenu,
                     alist ("player_settings",
                            reactive = TRUE,
                            choices= reactive ({
                                req (team ())
                                get_choices (with_db (
                                    get_players_nid (team_id =  team ())))})))


    data <- reactive ({
        req (team ())
        with_db (get_all_views (team_id = team ()))})


    select_data <- reactive ({
        if (opt$game_set ())
            list (data = data ()$by_set,
                  global = data ()$set_global)
        else
            list (data = data ()$by_game,
                  global = data ()$game_global)})


    filtered_data <- reactive ({
        req (opt$selected ())
        lapply (select_data (),
                function (x){
                    x %>%
                        filter (Player_id == opt$selected ())})})


    get_backend (attack,list ("player",filtered_data,opt$dist))
    get_backend (pass,list ("player",filtered_data,opt$dist))
    get_backend (serve,list ("player",filtered_data,opt$dist))


    opt_team <- get_backend (dropmenu,
                             alist ("team_settings",
                                    choices =  c("All","Opposite",
                                                 "Middle_Blocker",
                                                 "Setter", "Libero",
                                                 "Outside_Hitter")))
    data_team <- reactive (
        append (
            lapply (data () [1:2],function (x)
                x %>%
                select (-Player_id) %>%
                group_by (Position,metric) %>%
                summarise_each (partial (mean,na.rm = TRUE))),
            lapply (data () [3:4],function (x)
                x %>%
                select (-Player_id) %>%
                group_by (Position,metric,index) %>%
                summarise_each (partial (mean,na.rm = TRUE)))))

    select_data_team <- reactive ({
        if (opt_team$game_set ())
            list (data = data_team ()$by_set,
                  global = data_team ()$set_global)
        else
            list (data = data_team ()$by_game,
                  global = data_team ()$game_global)})

    filtered_data_team <- reactive ({
        req (opt_team$selected ())
        list (data =select_data_team ()$data %>%
                                         group_by (metric) %>%
                                         filtered_fun_team,
              global=
                  select_data_team ()$global %>%
                                     group_by (metric,index) %>%
                                     filtered_fun_team)})



    get_backend (attack,list ("team",filtered_data_team,opt_team$dist))
    get_backend (pass,list ("team",filtered_data_team,opt_team$dist))
    get_backend (serve,list ("team",filtered_data_team,opt_team$dist))




    get_backend (create_game,list("create_game"))
    get_backend (create_team,list ("create_team"))
    get_backend (create_players,list ("create_players"))


    output$test <- renderUI(selectInput("x","select only charter var",choices = c(1,2,3)))
    output$mtcars <- renderPlot(plot (mtcars$gear))}
