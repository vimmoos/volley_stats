library(RMariaDB)
library(DBI)
library (gtools)
library (tidyverse)
source("./db_driver/sql_interface.r")
source("./db_driver/utils.r")


ddl_map = list(players='players_table',
               teams='teams_table',
               games='games_table',
               stats='stats_table')

ddl_source = lapply(FUN=load_sql_module,ddl_map)


create_table (players,ddl_source$players)

create_table (games,ddl_source$games)

create_table (teams,ddl_source$teams)

create_table (stats,ddl_source$stats)


create_all_table <- function (con = R_CON_DB)
{
    create_teams_table ()
    create_players_table()
    create_games_table ()
    create_stats_table ()
}
