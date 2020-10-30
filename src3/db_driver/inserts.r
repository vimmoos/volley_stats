library(RMariaDB)
library(DBI)
library(gtools)
library(tidyverse)
source("./db_driver/utils.r")

execute_sql(
  add_team,
  args = alist(name = , gender = , association = ),
  sql_string =
    sqlInterpolate(con, paste0(
      "INSERT INTO Teams (Name,Gender,Association) ",
      "VALUES (?name, ?gender, ?assoc);"),
    name = name, gender = gender, assoc = association))

add_game <- function(con = R_CON_DB, opp_id, team_id, date) {
  dbExecute(
    con,
    sqlInterpolate(
      "INSERT INTO Games (Opp_id,Team_id,Date) VALUES (?opp,?team,?date);",
      opp = opp_id, team = team_id, date = date))
  (get_tbl(con, table = "Games") %>%
    filter(Opp_id == opp_id &
      Team_id == team_id &
      Date == date) %>% collect())$Game_id

}


sub_player_id <- function(df, opp_id, team_id) {
  team_pls <- get_players_nid(team_id = team_id)
  opp_pls <- get_players_nid(team_id = opp_id)
  df %>%
    group_by(Player) %>%
    mutate(Player_id = get_id(Player, team_pls, opp_pls)) %>%
    ungroup() %>%
    mutate(
      Set_ = Set,
      Set = NULL,
      Player = NULL) %>%
    as.data.frame()
}


execute_sql(
  add_stats,
  args = alist(df = , opp_id = , team_id = , game_id = ),
  sql_string =
    sqlAppendTable(
      con, "Stats",
      sub_player_id(df, opp_id, team_id) %>%
        mutate(Game_id = game_id)))


execute_sql(
  add_player,
  args = alist(name = , pos = , team_id = ),
  sql_string =
    sqlInterpolate(con,
      paste(
        "INSERT INTO Players (Name,Position,Team_id)",
        "VALUES (?name,?pos,?team) ON DUPLICATE KEY UPDATE ",
        "Name=?name,Position=?pos,Team_id=?team;"),
      name = name, pos = pos,
      team = team_id))


execute_sql(
  add_players,
  args = alist(poss = , team_id = ),
  sql_string =
    paste0(
      sqlAppendTable(
        con, "Players",
        poss %>%
          mutate(Team_id = team_id) %>%
          as.data.frame())@.Data,
      "ON DUPLICATE KEY UPDATE Name = values(Name),",
      "Position= values(Position), Team_id = values(Team_id);"))
