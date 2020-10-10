library(RMariaDB)
library(DBI)
library (gtools)
library (tidyverse)
source("./modules/sql_interface.r")

R_CON_DB <- NULL

dhost <- "192.168.1.109"

ddatabase <- "volley"

dpassword <- Sys.getenv ("VOLLEY_DB_PASS")

startup  <- function (host=dhost,database=ddatabase,password=dpassword)
    R_CON_DB <<- dbConnect(MariaDB(),host=host,dbname= database,password= password)

bye <- function(con=R_CON_DB) dbDisconnect(con)


with_db <- defmacro (body,expr={
    startup ()
    res <- tryCatch (body,error = function (e){
        bye ()
        stop (safeError (e))})
    bye ()
    res})

get_tbl <- function(con = R_CON_DB,table) tbl(con,table)

bench_query <- function(query,n = 100)
{
    bench_fun <- function () for (i  in c (1:n))
                                 query %>% collect ()
    startup ()
    print (system.time (result <- bench_fun ()))
    bye ()
}



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




team_with_stats <- function (con = R_CON_DB)
    get_tbl (con,table ="Teams") %>%
        inner_join (get_tbl (con,table ="Players") %>%
                    select (Team_id,Player_id)) %>%
        semi_join (get_tbl (con,table ="Stats")) %>%
        select (Team_id,Name,Association) %>%
        distinct

mutate_set <- function (tbl)
    tbl %>%
        mutate (Set_ = 1)

q_prob <- function (tbl)
    tbl %>%
        mutate(ServeR_tot = ServeR_er + ServeR_p + ServeR_g + ServeR_ex,
               Serve_tot = Serve_e + Serve_a + Serve_n) %>%
        group_by (Player_id,Set_,Game_id) %>%
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

q_mean <- function (tbl)
    tbl %>%
        summarise (
            att_k = round(mean (att_k),2),
            att_e = round(mean(att_e),2),
            att_n = round(mean(att_n),2),
            sr_er = round(mean(sr_er),2),
            sr_p = round(mean(sr_p),2),
            sr_g = round(mean(sr_g),2),
            sr_ex = round(mean(sr_ex),2),
            serve_k = round(mean(serve_k),2),
            serve_e = round(mean(serve_e),2),
            serve_n = round(mean(serve_n),2))

q_sum <- function (tbl)
    tbl %>%
        summarise_each (sum)

q_se <- function (tbl)
    tbl %>%
        summarise (
            att_k = round(sd (att_k) / sqrt (count (att_k)),2),
            att_e = round(sd (att_e) / sqrt (count (att_e)),2),
            att_n = round(sd (att_n) / sqrt (count (att_n)),2),
            sr_er = round(sd (sr_er) / sqrt (count (sr_er)),2),
            sr_p = round(sd (sr_p) / sqrt (count (sr_p)),2),
            sr_g = round(sd (sr_g) / sqrt (count (sr_g)),2),
            sr_ex = round(sd (sr_ex) / sqrt (count (sr_ex)),2),
            serve_k = round(sd (serve_k) / sqrt (count (serve_k)),2),
            serve_e = round(sd (serve_e) / sqrt (count (serve_e)),2),
            serve_n = round(sd (serve_n) / sqrt (count (serve_n)),2))


qview_mean (set,Set_)
qview_mean (game,Game_id)
qview_se (set,Set_)
qview_se (game,Game_id)
qview_global (set,Set_)
qview_global (game,Game_id)

create_view (set_mean,qview_set_mean ())
create_view (game_mean,qview_game_mean ())
create_view (set_se,qview_set_se ())
create_view (game_se,qview_game_se ())
create_view (set_global,qview_set_global ())
create_view (game_global,qview_game_global ())
