source("./modules/attack.r")
source("./modules/serve.r")
source("./modules/pass.r")
source("./modules/selector.r")
source("./modules/mode_sel.r")
source("./modules/dropmenu.r")
source ("./modules/upload.r")
source ("./modules/create_team.r")
source ("./modules/create_players.r")
source("./modules/utils.r")
source ("./modules/db_driver.r")

source ("./utils.r")
library (tidyverse)
library(data.table)


module_server <- function(input,output,session)
{
    id <- "sidebar"

    observe (back_selector ("select_ass",with_db (team_with_stats ()$Association)))
    observe (back_selector ("select_team",with_db ((team_with_stats () %>%
                                                    filter (Association == get_in ("select_ass")))$Name)))

    ## all_data <- with_db (gather_all_data (prob_all_data))


    raw <- pre_proc_data(read_data())

    datas <- reactiveValues()
    datas$raw_data <-  reactive( if(opt$game_set())
                                     sum_set(raw)
                                 else raw)
    datas$prob <- reactive (prob_data (datas$raw_data ()))
    datas$mean <- reactive (mean_data (datas$prob ()))
    datas$mean_team <- reactive (mean_team_data (datas$prob ()))


    observe (print (datas$prob))
    observe (print (datas$mean))
    observe (print (datas$mean_team))




    opt <- module_dropmenu(TRUE)(input,output, session,
        quote(Player),datas$mean ,"Select Player","player",TRUE)



    filt_dist <- reactive( if (opt$dist())
                               datas$prob () %>%
                               filter(Player == opt$selected ()$selected) %>%
                               group_by(Player))



    get_backend (create_game,list(input,output,session,"create_game"))
    get_backend (create_team,list (input,output,session,"create_team"))
    get_backend (create_players,list (input,output,session,"create_players"))

    binds_filter (dist,filt_dist (),metric,
                  list (c ("attack","att*"),
                        c ("serve","serve*"),
                        c ("pass","sr")))

    binds_filter (data,opt$selected ()$data,metric,
                  list (c ("attack","att*"),
                        c ("serve","serve*"),
                        c ("pass","sr")))

    module_attack(TRUE) (input,output,session, data$attack,dist$attack,opt$dist,"player")

    module_pass (TRUE) (input,output,session, data$pass,dist$pass,opt$dist,"player")

    module_serve (TRUE) (input,output,session,data$serve,dist$serve,opt$dist,"player")

    opt_team <- module_dropmenu(TRUE)(input,output, session,
        quote(Position),datas$mean_team ,"Select Position","team",TRUE)

    filt_team <- reactive( if (opt_team$dist())
                               datas$prob () %>%
                               filter(Position == opt_team$selected ()$selected) %>%
                               group_by(Position))




    binds_filter (team_dist,filt_team (),metric,
                  list (c ("attack","att*"),
                        c ("serve","serve*"),
                        c ("pass","sr")))

    binds_filter (team_data,opt_team$selected ()$data,metric,
                  list (c ("attack","att*"),
                        c ("serve","serve*"),
                        c ("pass","sr")))

    module_attack(TRUE) (input,output,session, team_data$attack,team_dist$attack,opt_team$dist,"team")

    module_pass (TRUE) (input,output,session, team_data$pass,team_dist$pass,opt_team$dist,"team")

    module_serve (TRUE) (input,output,session,team_data$serve,team_dist$serve,opt_team$dist,"team")




    output$test <- renderUI(selectInput("x","select only charter var",choices = c(1,2,3)))
    output$mtcars <- renderPlot(plot (mtcars$gear))}
