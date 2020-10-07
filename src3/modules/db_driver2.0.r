library(RMariaDB)
library(DBI)
library (gtools)
library (tidyverse)

R_CON_DB <- NULL

dhost <- "192.168.1.109"

ddatabase <- "volley"

dpassword <- Sys.getenv ("VOLLEY_DB_PASS")

startup  <- function (host=dhost,database=ddatabase,password=dpassword)
    R_CON_DB <<- dbConnect(MariaDB(),host=host,dbname= database,password= password)

bye <- function(con=R_CON_DB) dbDisconnect(con)

with_db <- defmacro (body,expr={
    startup ()
    res <- body
    bye ()
    res})


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

get_id <- function (name,team_df,opp_df)
{
    x <- team_df [grep (name,team_df$Name),]$Player_id
    y <- opp_df [grep (name,opp_df$Name),]$Player_id
    if (is_empty (x))
        if (is_empty (y)) stop (paste ("Unmatched Name",name))
        else y
    else x
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



create_players_table <- function (con=R_CON_DB)
    dbExecute (con,
               paste("CREATE TABLE Players (",
                     "Player_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,",
                     "Name VARCHAR(100) NOT NULL,",
                     "Position VARCHAR(100) NOT NULL,",
                     "Team_id MEDIUMINT NOT NULL,",
                     "CONSTRAINT unique_player UNIQUE KEY (Name,Team_id),",
                     "CONSTRAINT fk_team_id ",
                     "FOREIGN KEY (Team_id) REFERENCES Teams (Team_id)",
                     "ON DELETE CASCADE", "ON UPDATE RESTRICT);",
                     sep="\n"))

create_teams_table <- function (con=R_CON_DB)
    dbExecute (con,
               paste ("CREATE TABLE Teams (",
                      "Team_id MEDIUMINT NOT NULL AUTO_INCREMENT PRIMARY KEY,",
                      "Name VARCHAR(100) NOT NULL,", "Gender BOOL,",
                      "Association VARCHAR(100) NOT NULL,",
                      "CONSTRAINT unique_teams UNIQUE KEY (Name,Association));",
                      sep="\n"))


create_games_table <- function (con=R_CON_DB)
    dbExecute (con,
               paste ("CREATE TABLE Games (",
                      "Game_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,",
                      "Opp_id MEDIUMINT NOT NULL,",
                      "Team_id MEDIUMINT NOT NULL,",
                      "Date DATE NOT NULL,",
                      "CONSTRAINT unique_game UNIQUE KEY (Opp_id,Team_id,Date),",
                      "CONSTRAINT fk_opp_id FOREIGN KEY (Opp_id) REFERENCES Teams (Team_id)",
                      "ON DELETE CASCADE","ON UPDATE RESTRICT,",
                      "CONSTRAINT fk_t_id FOREIGN KEY (Team_id) REFERENCES Teams (Team_id)",
                      "ON DELETE CASCADE","ON UPDATE RESTRICT);",
                      sep = "\n"))


create_stats_table <- function (con=R_CON_DB)
    dbExecute (con,
               paste ("CREATE TABLE Stats(", "Game_id INT NOT NULL,",
                      "Player_id INT NOT NULL,",
                      "Set_ TINYINT(2) NOT NULL,",
                      "Attack_n TINYINT(2) ZEROFILL,",
                      "Attack_k TINYINT(2) ZEROFILL,",
                      "Attack_e TINYINT(2) ZEROFILL,",
                      "Block_t TINYINT(2) ZEROFILL,",
                      "Block_k TINYINT(2) ZEROFILL,",
                      "ServeR_er TINYINT(2) ZEROFILL,",
                      "ServeR_p TINYINT(2) ZEROFILL,",
                      "ServeR_g TINYINT(2) ZEROFILL,",
                      "ServeR_ex TINYINT(2) ZEROFILL,",
                      "Serve_e TINYINT(2) ZEROFILL,",
                      "Serve_a TINYINT(2) ZEROFILL,",
                      "Serve_n TINYINT(2) ZEROFILL,",
                      "PRIMARY KEY (Game_id,Player_id,Set_),",
                      "CONSTRAINT fk_game_id FOREIGN KEY (Game_id) REFERENCES Games (Game_id)",
                      "ON DELETE CASCADE","ON UPDATE RESTRICT,",
                      "CONSTRAINT fk_player_id FOREIGN KEY (Player_id) REFERENCES Players (Player_id)",
                      "ON DELETE CASCADE","ON UPDATE RESTRICT);",
                      sep="\n"))


sselect <- function (columns,from,where="")
    paste("SELECT",columns,"FROM",from,
            if (where != "")
                paste ("WHERE",where),
            ";")

ssel_unique <- function (columns,from,where="")
    sselect (paste ("DISTINCT",columns),from,where)

get_all_associations <- function (con = R_CON_DB)
    dbGetQuery (con,ssel_unique ("Association","Teams"))$Association



get_team_name <- function (con = R_CON_DB,assoc = 'Kroton')
    dbGetQuery(con,
               sselect ("Name","Teams",
                        paste0("Association = '",assoc,"'")))$Name

get_team_id <- function (con = R_CON_DB,assoc = 'Kroton',name = "D1")
    dbGetQuery (con,
                sselect ("Team_id","Teams",
                         paste0 ("Association = '",assoc,"' ",
                                 "AND Name = '",name,"'")))$Team_id


get_all_games_id <- function (con =R_CON_DB,team_id = 2)
    dbGetQuery (con,
                sselect ("Game_id","Games",
                         paste("Team_id =",team_id,
                               "OR Opp_id =",team_id)))

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


position_template <-
    as_tibble (
        list(Name = c("name1","name2",
                        "name3","name4","name5"),
             Position = c("Opposite","Middle_Blocker", "Setter",
                          "Libero","Outside_Hitter")))

games_template <-
    as_tibble (
        list (Player = c ("name1"),
              Set = c (as.integer(1)),
              Attack_n = c (as.integer(0)),
              Attack_e = c (as.integer(0)),
              Attack_k= c (as.integer(0)),
              ServeR_er= c (as.integer(0)),
              ServeR_p= c (as.integer(0)),
              ServeR_g= c (as.integer(0)),
              ServeR_ex= c (as.integer(0)),
              Serve_a= c (as.integer(0)),
              Serve_n= c (as.integer(0)),
              Serve_e= c (as.integer(0)),
              Block_t= c (as.integer(0)),
              Block_k= c (as.integer(0))))
