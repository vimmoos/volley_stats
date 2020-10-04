source("./modules/attack.r")
source("./modules/serve.r")
source("./modules/pass.r")
source("./modules/selector.r")
source("./modules/mode_sel.r")
source("./modules/dropmenu.r")
source ("./modules/upload.r")
source ("./modules/create_team.r")
source ("./modules/create_players.r")
source ("./modules/db_driver.r")

source ("./utils.r")
library (tidyverse)
library(data.table)

get_csv <- function(path) read.csv(path) %>%
                              as_tibble %>%
                              mutate_if(is.character,as.factor)


check_row <- function(data)
    data[,!names(data) %in% c("Set")]  %>%
        apply(1,FUN=
                    function(row)
                        all(as.numeric(row) == 0 | is.na(as.numeric(row))))


m <-function(x) mean(x[!is.nan(x)])

s <- function(x) sd(x[!is.nan(x)])

se <- function(x) sd(x[!is.nan(x)])/sqrt(length(x[!is.nan(x)]))


filter_attacker <- function (data) filter(data,!Position %in% c("Libero","Setter"))

filter_passer <- function (data) filter(data,!Position %in% c("Middle_Blocker","Setter","Opposite"))

filter_server <- function (data) filter(data,!Position %in% c("Libero"))


read_data <- function ()
{
    position <- get_csv("~/volley_stats/data/h1_position.csv")

    data <- get_csv("~/volley_stats/data/first_match.csv") %>% left_join(position)

    data[!check_row(data),]

}


pre_proc_data <- function (data)
{

    data %>%
        mutate(Set=1)%>%
        group_by(Team,Player,Opponent,Position,Set)%>%
        mutate(ServeR_tot = ServeR_P_Err + ServeR_P_P + ServeR_G_P + ServeR_E_P,
               Serve_tot = Serve_error + Serve_Ace + Serve_null)

}

sum_set <- function (data)
{
    data %>% summarise_each(funs=function(x)
        ifelse(is.factor(x),x,sum(x)))}



prob_data <- function (data)
{
    data %>%
        group_by (Player,Opponent,Position,Set) %>%
        summarise(
                  att_k = Attack_kills/Attack_n,
                  att_e = Attack_error/Attack_n,
                  att_n = (Attack_n - (Attack_kills+Attack_error) ) /Attack_n,
                  sr_er = ServeR_P_Err / ServeR_tot,
                  sr_p = ServeR_P_P / ServeR_tot,
                  sr_g = ServeR_G_P / ServeR_tot,
                  sr_ex = ServeR_E_P / ServeR_tot,
                  serve_k = Serve_Ace/Serve_tot,
                  serve_e = Serve_error/Serve_tot,
                  serve_n = Serve_null/Serve_tot) %>%
        gather ("metric","val",4:14)
}

mean_data <- function (data)
{
    data [,!names (data) %in% c ("Opponent")] %>%
        group_by (Player,Position,metric) %>%
        summarise_each (lst (m,se))
}

mean_team_data <- function (data)
{
    data [,!names (data) %in% c ("Opponent","Player")] %>%
        group_by (Position,metric) %>%
        summarise_each (lst (m,se))
}







module_server <- function(input,output,session)
{
    raw <- pre_proc_data(read_data())

    datas <- reactiveValues()
    datas$raw_data <-  reactive( if(opt$game_set())
                                     sum_set(raw)
                                 else raw)
    datas$prob <- reactive (prob_data (datas$raw_data ()))
    datas$mean <- reactive (mean_data (datas$prob ()))
    datas$mean_team <- reactive (mean_team_data (datas$prob ()))

    opt <- module_dropmenu(TRUE)(input,output, session,
        quote(Player),datas$mean ,"Select Player","player",TRUE)


    observe(print(opt$selected ()$selected))
    observe(print(datas$raw_data()))
    ## observe(print(opt$selected ()$selected))
    ## observe(print(opt$selected ()$selected))


    filt_dist <- reactive( if (opt$dist())
                               datas$prob () %>%
                               filter(Player == opt$selected ()$selected) %>%
                               group_by(Player))



    module_upload_game (TRUE) (input,output,session,"upload",datas$raw_data)
    module_create_team (TRUE) (input,output,session,"create_team")
    module_create_players (TRUE) (input,output,session,"create_players")

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
