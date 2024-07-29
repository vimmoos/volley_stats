source("./global.R")
startup()

create_all_table()
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
