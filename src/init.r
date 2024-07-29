source("./global.R")
startup()

dbExecute(R_CON_DB,"
CREATE TABLE Teams
(Team_id
 MEDIUMINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 Name VARCHAR(100) NOT NULL,
 Gender BOOL,
 Association VARCHAR(100) NOT NULL,
 CONSTRAINT unique_teams
 UNIQUE KEY (Name,Association,Gender));")


dbExecute(R_CON_DB,"
CREATE TABLE Players
(Player_id
 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 Name VARCHAR(100) NOT NULL,
 Position VARCHAR(100) NOT NULL,
 Team_id MEDIUMINT NOT NULL,
 CONSTRAINT unique_player UNIQUE KEY (Name,Team_id),
 CONSTRAINT fk_team_id
 FOREIGN KEY (Team_id) REFERENCES Teams (Team_id)
 ON DELETE CASCADE
 ON UPDATE RESTRICT);")

dbExecute(R_CON_DB,"
CREATE TABLE Games
(Game_id
 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 Opp_id MEDIUMINT NOT NULL,
 Team_id MEDIUMINT NOT NULL,
 Date DATE NOT NULL,
 CONSTRAINT unique_games UNIQUE KEY (Opp_id,Team_id,Date),
 CONSTRAINT fk_opp_id FOREIGN KEY (Opp_id) REFERENCES Teams (Team_id)
 ON DELETE CASCADE
 ON UPDATE RESTRICT,
 CONSTRAINT fk_t_id FOREIGN KEY (Team_id) REFERENCES Teams (Team_id)
 ON DELETE CASCADE
 ON UPDATE RESTRICT);")

dbExecute(R_CON_DB, "
CREATE TABLE Stats
(Game_id INT NOT NULL,
	 Player_id INT NOT NULL,
	 Set_ TINYINT(2) NOT NULL,
	 Attack_n TINYINT(2) ZEROFILL,
	 Attack_k TINYINT(2) ZEROFILL,
	 Attack_e TINYINT(2) ZEROFILL,
	 Block_t TINYINT(2) ZEROFILL,
	 Block_k TINYINT(2) ZEROFILL,
	 Block_e TINYINT(2) ZEROFILL,
	 ServeR_e TINYINT(2) ZEROFILL,
	 ServeR_p TINYINT(2) ZEROFILL,
	 ServeR_g TINYINT(2) ZEROFILL,
	 ServeR_ex TINYINT(2) ZEROFILL,
	 Serve_e TINYINT(2) ZEROFILL,
	 Serve_p TINYINT(2) ZEROFILL,
	 Serve_a TINYINT(2) ZEROFILL,
	 Serve_n TINYINT(2) ZEROFILL,
	 PRIMARY KEY (Game_id,Player_id,Set_),
	 CONSTRAINT fk_game_id FOREIGN KEY (Game_id) REFERENCES Games (Game_id)
	 ON DELETE CASCADE
	 ON UPDATE RESTRICT,
	 CONSTRAINT fk_player_id FOREIGN KEY (Player_id) REFERENCES Players (Player_id)
	 ON DELETE CASCADE
	 ON UPDATE RESTRICT);")

create_all_views()
assoc = "Kroton"
team = "H1"
gender = 1

add_team(R_CON_DB,team,gender,assoc)

add_team(R_CON_DB,"H4",gender,"Veracles")

add_team(R_CON_DB,"H5",gender,"Veracles")

t_id <- get_team_id(assoc = assoc,name = team)

v4_id <- get_team_id(assoc = "Veracles",name="H4")

v5_id <- get_team_id(assoc = "Veracles",name="H5")

add_players(R_CON_DB,poss=read.csv("../data/h1_position.csv"),team_id =  t_id)



game_id <- add_game(R_CON_DB,opp_id = v4_id,team_id = t_id,date = "2020-07-03")

add_stats(R_CON_DB,df=read.csv("../data/veracles_h4.csv"),
          opp_id = v4_id,team_id = t_id,
          game_id = game_id)

game_id <- add_game(R_CON_DB,opp_id = v5_id,team_id = t_id,date = "2020-10-03")

add_stats(R_CON_DB,df=read.csv("../data/veracles_h5.csv"),
          opp_id = v5_id,team_id = t_id,
          game_id = game_id)

x <- dbGetQuery(R_CON_DB,"SELECT COLUMN_NAME FROM information_schema.columns WHERE table_name = 'Stats'")

for (item in x$COLUMN_NAME){
  str = paste0("UPDATE Stats SET ",item," = COALESCE(",item,",0);")
  dbExecute(R_CON_DB,str)
}
