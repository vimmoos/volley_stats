library(RMariaDB)
library(DBI)
library (gtools)
library (tidyverse)
source("./modules/db_driver.r")


test <- tbl (R_CON_DB,"Stats")


test %>%
    group_by (Player_id,Game_id,Set_) %>%
    summarize_each (lst (sum)) -> q1

test %>%
    group_by(Player_id,Game_id,Set_) %>%
    mutate (pippo = 1) %>% show_query() -> q2

q1_query <- q1



## test for different "View"

startup ()

stats <- tbl (R_CON_DB,"Stats")
teams <- tbl (R_CON_DB,"Teams")
games <- tbl (R_CON_DB,"Games")
players <- tbl (R_CON_DB,"Players")



enhanced_stats <- stats %>%
    mutate(ServeR_tot = ServeR_er + ServeR_p + ServeR_g + ServeR_ex,
           Serve_tot = Serve_e + Serve_a + Serve_n)

prob_stats <- enhanced_stats %>%
    group_by (Player_id,Game_id,Set_) %>%
    summarise(
                  att_k = Attack_k/Attack_n,
                  att_e = Attack_e/Attack_n,
                  att_n = (Attack_n - (Attack_k+Attack_e) ) /Attack_n,
                  sr_er = ServeR_er / ServeR_tot,
                  sr_p = ServeR_p / ServeR_tot,
                  sr_g = ServeR_g / ServeR_tot,
                  sr_ex = ServeR_ex / ServeR_tot,
                  serve_k = Serve_a/Serve_tot,
                  serve_e = Serve_e/Serve_tot,
        serve_n = Serve_n/Serve_tot)

stats_game <- prob_stats %>%
    mutate (Set_ =1 ) %>%
    group_by (Player_id,Game_id) %>%
    mutate (Set_ = sum (Set_)) %>%
    summarise_each (fun = mean)

stats_sum_all <- enhanced_stats %>%
    mutate (Set_ = 1) %>%
    group_by (Player_id) %>%
    summarise_each (funs = sum,- Game_id)


team_id <- teams %>%
    filter (Name == "H1" & Association == "Kroton") %>% select (Team_id)

team_idc <- collect (team_id)


players_team <- players %>%
    filter (Team_id == !!team_idc$Team_id)



se <- function(x) { print (x)
                          sd(x[!is.na(x)])/sqrt(length(x[!is.na(x)]))}
m <- function (x) mean (x,na.rm=TRUE)
my_sd <- partial (sd,na.rm=TRUE)

## my_sd <- function (x,mean)
## {
##     sum <- 0
##     for (el in x){
##         (el - mean)^2
##     }
##     sqrt (sum/length (x))

## }


## stats_gather_m <-
##     defmacro (name,tbl,gather_col,
##               expr = do.call ("<-",list (paste0 (quote (name),"_gathered"),
##                                          tbl %>%
##                                          gather ("metric","val",gather_col))))

## stats_gather_m (sset,stats_set,3:16)

## stats_mean_m <-
##     defmacro (name,tbl,
##               expr = do.call ("<-",list (paste0 (quote (name),"_mean"),
##                                          tbl %>%
##                                          summarise_each (lst (m,se)))))






prob_data <- function (data)
{
    data %>%
        group_by (Player,Opponent,Position,Set) %>%
         %>%
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
