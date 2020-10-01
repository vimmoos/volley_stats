library(RMariaDB)
library(DBI)
library (gtools)

R_CON_DB <- NULL




startup  <- function (host=dhost,database=ddatabase,password=dpassword)
    R_CON_DB <<- dbConnect(MariaDB(),host=host,dbname= database,password= password)

bye <- function(con=R_CON_DB) dbDisconnect(con)

with_db <- defmacro (body,expr={
    startup ()
    body
    bye ()})


check_position <- function (pos_df)
    all (names (pos_df) %in% c ("Position","Player") &
         all (pos_df$Position %in%
              c("Opposite","Middle_Blocker", "Setter",
                          "Libero","Outside_Hitter")) &
         apply (pos_df,1,is.character))

check_games <- function (games_df)
    all (names (games_df) %in% c ("Player","Set","Attack_n",
                                  "Attack_k","Attack_e","Block_t",
                                  "Block_k", "ServeR_er","ServeR_p",
                                  "ServeR_g", "ServeR_ex","Serve_e",
                                  "Serve_a", "Serve_n") &
         sapply (games_df$Player,is.character) &
         apply (games_df [,!names (games_df) %in% c ("Player")],
                1,is.integer ))

create_position_table <- function (con=R_CON_DB)
    dbExecute (con,
               paste("CREATE TABLE position (",
                     "Player VARCHAR(100) PRIMARY KEY,",
                     "Position VARCHAR(100) NOT NULL,",
                     "Team VARCHAR(100) NOT NULL);",sep="\n"))
create_games_table <- function (con=R_CON_DB)
    dbExecute (con,
               paste ("CREATE TABLE games (",
                      "Player VARCHAR(100) NOT NULL,",
                      "Opponent VARCHAR(100) NOT NULL,",
                      "Set_ TINYINT ZEROFILL NOT NULL,",
                      "Date DATE NOT NULL,",
                      "Attack_n TINYINT ZEROFILL,",
                      "Attack_k TINYINT ZEROFILL,",
                      "Attack_e TINYINT ZEROFILL,",
                      "Block_t TINYINT ZEROFILL,",
                      "Block_k TINYINT ZEROFILL,",
                      "ServeR_er TINYINT ZEROFILL,",
                      "ServeR_p TINYINT ZEROFILL,",
                      "ServeR_g TINYINT ZEROFILL,",
                      "ServeR_ex TINYINT ZEROFILL,",
                      "Serve_e TINYINT ZEROFILL,",
                      "Serve_a TINYINT ZEROFILL,",
                      "Serve_n TINYINT ZEROFILL,",
                      "CONSTRAINT PK_games PRIMARY KEY (Player,Opponent,Set_));",
                      sep = "\n"))

append_games <- function (con = R_CON_DB,games,opponent,date)
{
    getupdate_string <-
        dbSendQuery (con,
                     paste (sep="\n",
                            "SELECT GROUP_CONCAT( CONCAT(COLUMN_NAME,'=values(', COLUMN_NAME,')')",
                            "SEPARATOR ', ') FROM INFORMATION_SCHEMA.COLUMNS",
                            "WHERE TABLE_SCHEMA = 'volley' AND TABLE_NAME = 'games';"))
    update_s <- dbFetch (getupdate_string)
    dbClearResult (getupdate_string)
    dbExecute (con,
               paste (sep= "\n",
                      sqlAppendTable (con,"games",
                                      games %>%
                                                  mutate (Opponent = opponent,
                                                          Date = toString (date),
                                                          Set_ = Set,
                                                          Set = NULL) %>%
                                                  as.data.frame
                                      )@.Data,
                      "ON DUPLICATE KEY UPDATE",
                      update_s))
    }

append_position <- function (con=R_CON_DB,pos_df,n_team)
        dbExecute(con,
                  paste(sep = "\n",
                      sqlAppendTable(
                          con, "position", pos_df %>%
                                           mutate (Team = n_team) %>%
                                           as.data.frame)@.Data,
                      " ON DUPLICATE KEY UPDATE ",
                      "Position = values(Position), Team = values(Team)"))

read_position <- function (con= R_CON_DB) dbReadTable (con,"position")
read_games <- function (con= R_CON_DB) dbReadTable (con,"games")


cadd_position <- function (df) if (check_position (df))
                                   c(fun =  partial (append_position,pos_df=df),
                                     bool = TRUE) else c (fun =NULL,bool= FALSE)

cadd_games <- function (df) if (check_games (df))
                                   list(fun =  partial (append_games,games=df),
                                     bool = TRUE) else list (fun =NULL,bool= FALSE)

position_template <-
    as_tibble (
        list(Player = c("name1","name2",
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
