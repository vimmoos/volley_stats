library(RMariaDB)
library(DBI)
library (gtools)
source("./modules/sql_interface.r")

R_CON_DB <- NULL


startup  <- function (host=dhost,database=ddatabase,password=dpassword)
    R_CON_DB <<- dbConnect(MariaDB(),host=host,dbname= database,password= password)

bye <- function(con=R_CON_DB) dbDisconnect(con)

with_db <- defmacro (body,expr={
    startup ()
    body
    bye ()})

ddl_map = list(players='players_table',
               teams='teams_table',
               games='games_table',
               stats='stats_table')

ddl_source = lapply(FUN=load_sql_module,ddl_map)


# DONE
create_players_table <- function (con=R_CON_DB)
    dbExecute (con, ddl_source$players
               ## paste("CREATE TABLE Players (",
               ##       "Player_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,",
               ##       "Name VARCHAR(100) NOT NULL,",
               ##       "Position VARCHAR(100) NOT NULL,",
               ##       "Team_id MEDIUMINT NOT NULL,",
               ##       "CONSTRAINT fk_team_id ",
               ##       "FOREIGN KEY (Team_id) REFERENCES Teams (Team_id)",
               ##       "ON DELETE CASCADE", "ON UPDATE RESTRICT);",
               ##       sep="\n")
               )

# DONE
create_teams_table <- function (con=R_CON_DB)
    dbExecute (con, ddl_source$teams
               ## paste ("CREATE TABLE Teams (",
               ##        "Team_id MEDIUMINT NOT NULL AUTO_INCREMENT PRIMARY KEY,",
               ##        "Name VARCHAR(100) NOT NULL,", "Gender BOOL,",
               ##        "Association VARCHAR(100) NOT NULL,",
               ##        "CONSTRAINT unique_teams UNIQUE KEY (Name,Association,Gender));",
               ##        sep="\n")
               )


# DONE
create_games_table <- function (con=R_CON_DB)
    dbExecute (con, ddl_sources$games
               ## paste ("CREATE TABLE Games (",
               ##        "Game_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,",
               ##        "Opp_id MEDIUMINT NOT NULL,",
               ##        "Team_id MEDIUMINT NOT NULL,",
               ##        "Date DATE NOT NULL,",
               ##        "CONSTRAINT fk_opp_id FOREIGN KEY (Opp_id) REFERENCES Teams (Team_id)",
               ##        "ON DELETE CASCADE","ON UPDATE RESTRICT,",
               ##        "CONSTRAINT fk_t_id FOREIGN KEY (Team_id) REFERENCES Teams (Team_id)",
               ##        "ON DELETE CASCADE","ON UPDATE RESTRICT);",
               ##        sep = "\n")
               )

# DONE
create_stats_table <- function (con=R_CON_DB)
    dbExecute (con, ddl_sources$stats
               ## paste ("CREATE TABLE Stats(", "Game_id INT NOT NULL,",
               ##        "Player_id INT NOT NULL,",
               ##        "Set_ TINYINT(2) NOT NULL,",
               ##        "Attack_n TINYINT(2) ZEROFILL,",
               ##        "Attack_k TINYINT(2) ZEROFILL,",
               ##        "Attack_e TINYINT(2) ZEROFILL,",
               ##        "Block_t TINYINT(2) ZEROFILL,",
               ##        "Block_k TINYINT(2) ZEROFILL,",
               ##        "ServeR_er TINYINT(2) ZEROFILL,",
               ##        "ServeR_p TINYINT(2) ZEROFILL,",
               ##        "ServeR_g TINYINT(2) ZEROFILL,",
               ##        "ServeR_ex TINYINT(2) ZEROFILL,",
               ##        "Serve_e TINYINT(2) ZEROFILL,",
               ##        "Serve_a TINYINT(2) ZEROFILL,",
               ##        "Serve_n TINYINT(2) ZEROFILL,",
               ##        "PRIMARY KEY (Game_id,Player_id,Set_),",
               ##        "CONSTRAINT fk_game_id FOREIGN KEY (Game_id) REFERENCES Games (Game_id)",
               ##        "ON DELETE CASCADE","ON UPDATE RESTRICT,",
               ##        "CONSTRAINT fk_player_id FOREIGN KEY (Player_id) REFERENCES Players (Player_id)",
               ##        "ON DELETE CASCADE","ON UPDATE RESTRICT);",
               ##        sep="\n")
               )


sselect <- function (columns,from,where="")
    paste("SELECT",columns,"FROM",from,
            if (where != "")
                paste ("WHERE",where),
            ";")

ssel_unique <- function (columns,from,where="")
    sselect (paste ("DISTINCT",columns),from,where)

get_all_associations <- function (con = R_CON_DB)
    dbGetQuery (con,ssel_unique ("Association","Teams"))


get_team_name <- function (con = R_CON_DB,assoc = 'Kroton',gender = 0)
    dbGetQuery(con,
               sselect ("Name","Teams",
                        paste0("Association = '",assoc,"' ",
                               "AND Gender = ",gender)))

get_team_id <- function (con = R_CON_DB,assoc = 'Kroton',gender = 0,
                               name = "D1")
    dbGetQuery (con,
                sselect ("Team_id","Teams",
                         paste0 ("Association = '",assoc,"' ",
                                 "AND Gender = ",gender,
                                 " AND Name = '",name,"'")))

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

get_all_players_id <- function (con = R_CON_DB,team_id = 2)
    get_players (con,"Player_id",team_id)


get_all_players_name <- function (con = R_CON_DB,team_id =2)
    get_players (con,"Name",team_id)


get_players_name_pos <- function (con = R_CON_DB,team_id = 2,position = "Middle_Blocker")
    dbGetQuery (con,
                sselect ("Name","Players",
                         paste0 ("Team_id =", team_id,
                                 " AND Position = '",position,"'")))
