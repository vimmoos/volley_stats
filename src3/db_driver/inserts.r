library(RMariaDB)
library(DBI)
library (gtools)
library (tidyverse)
source("./db_driver/utils.r")

add_team <- function (con=R_CON_DB,name,gender,association)
    dbExecute (con,
               paste0("INSERT INTO Teams (Name,Gender,Association) ",
                      "VALUES ('",name,"',",gender, ",'",association,
                      "');"))
add_game <- function (con=R_CON_DB,opp_id,team_id,date)
{
    dbExecute (con,
               paste0 ("INSERT INTO Games (Opp_id,Team_id,Date) ",
                       "VALUES (",opp_id,",",team_id,",'",date,"');"))
    dbGetQuery (con,
                sselect ("Game_id","Games",
                         paste0("Opp_id = ",opp_id,
                                " AND Team_id = ",team_id,
                                " And Date = '",date,"'")))$Game_id
}


sub_player_id <- function (df,opp_id,team_id)
{
    team_pls <- get_players_nid (team_id = team_id)
    opp_pls <- get_players_nid (team_id = opp_id)
    df %>%
        group_by (Player) %>%
        mutate (Player_id =  get_id (Player,team_pls,opp_pls)) %>%
        ungroup %>%
        mutate (Set_ = Set,
                Set = NULL,
                Player = NULL) %>%
        as.data.frame
}


add_stats <- function (con=R_CON_DB,df,opp_id,team_id,game_id)
{
    print (sub_player_id (df,opp_id,team_id) %>%
                               mutate (Game_id = game_id))
    dbExecute (con,
               sqlAppendTable (con,"Stats",
                               sub_player_id (df,opp_id,team_id) %>%
                               mutate (Game_id = game_id)))
}

add_player <- function (con=R_CON_DB,name,pos,team_id)
    dbExecute (con,
               paste0 ("INSERT INTO Players (Name,Position,Team_id)",
                       " VALUES ('",name,"','",pos,"',",team_id,
                       ");"))

add_players <- function (con=R_CON_DB,poss,team_id)
    dbExecute (con,
               sqlAppendTable (con,"Players",
                               poss %>%
                               mutate (Team_id = team_id) %>%
                               as.data.frame))
