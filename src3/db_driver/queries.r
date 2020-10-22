library(RMariaDB)
library(DBI)
library (gtools)
library (tidyverse)
source("./db_driver/sql_interface.r")





sselect <- function (columns,from,where="")
    paste("SELECT",columns,"FROM",from,
            if (where != "")
                paste ("WHERE",where),
            ";")

ssel_unique <- function (columns,from,where="")
    sselect (paste ("DISTINCT",columns),from,where)

get_all_associations <- function (con = R_CON_DB)
(get_tbl (con,"Teams") %>%
 select (Association) %>%
 distinct %>%
 collect)$Association



get_team_name <- function (con = R_CON_DB,assoc = 'Kroton')
(get_tbl (con,"Teams") %>%
 filter (Association == assoc) %>%
 select (Name)%>% collect)$Name

get_teams <- function (con = R_CON_DB,assoc = 'Kroton')
(get_tbl (con,"Teams") %>%
 filter (Association == assoc) %>%
 select (Team_id,Name)%>% collect)

get_team_id <-
    function (con = R_CON_DB,assoc = 'Kroton',name = "D1")
(get_tbl (con,"Teams") %>%
 filter (Association == assoc & Name == name) %>%
 select (Team_id) %>%
 collect)$Team_id


get_all_games_id <- function (con =R_CON_DB,team_id = 2)
    get_tbl (con,"Games") %>%
        filter (Team_id == team_id | Opp_id == team_id) %>%
        select (Game_id) %>%
        collect


get_all_opp_id <- function (con =R_CON_DB,team_id =2)
    dbGetQuery (con,
                ssel_unique (paste ("IF (Opp_id =",team_id,
                                    ",Team_id,Opp_id) AS Opp_id"),
                             "Games",
                             paste ("Team_id = ",team_id,"OR Opp_id =",team_id)))

get_players <- function (con = R_CON_DB,column,team_id=2)
    dbGetQuery (con,
                sselect (column,"Players",
                         paste ("Team_id =",team_id)))


get_players_nid <- function (con = R_CON_DB,team_id)
    get_players (con,"Player_id,Name",team_id)


get_all_players_id <- function (con = R_CON_DB,team_id = 2)
    get_players (con,"Player_id",team_id)$Player_id


get_all_players_name <- function (con = R_CON_DB,team_id =2)
    get_players (con,"Name",team_id)


get_players_name_pos <- function (con = R_CON_DB,team_id = 2,position = "Middle_Blocker")
    dbGetQuery (con,
                sselect ("Name","Players",
                         paste0 ("Team_id =", team_id,
                                 " AND Position = '",position,"'")))

team_with_stats <- function (con = R_CON_DB)
    get_tbl (con,table ="Teams") %>%
        inner_join (get_tbl (con,table ="Players") %>%
                    select (Team_id,Player_id)) %>%
        semi_join (get_tbl (con,table ="Stats")) %>%
        select (Team_id,Name,Association) %>%
        distinct
