library(RMariaDB)
library(DBI)
library (gtools)
library (tidyverse)
source("./db_driver/utils.r")


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
            serve_n = round(mean(serve_n),2),
            -index)

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


qview_mean (set,Set_,Game_id)
qview_mean (game,Game_id,Set_)
qview_se (set,Set_,Game_id)
qview_se (game,Game_id,Set_)
qview_global (set,Set_,Game_id)
qview_global (game,Game_id,Set_)

create_view (set_mean,qview_set_mean ())
create_view (game_mean,qview_game_mean ())
create_view (set_se,qview_set_se ())
create_view (game_se,qview_game_se ())
create_view (set_global,qview_set_global ())
create_view (game_global,qview_game_global ())
