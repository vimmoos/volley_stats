library (gtools)

gather_global_view <- function (tbl)
    tbl %>%
        collect %>%
        gather("metric","val",-Player_id,-Position,-index)

gather_view <- function (tbl)
    tbl %>%
        collect %>%
        gather("metric","val",-Player_id,-Position)

join_views_ms <- function(con = R_CON_DB,mean_tbl,se_tbl,team_id)
    get_tbl (table = mean_tbl) %>%
        tfilter_view (con = con,team_id = team_id) %>%
        gather_view() %>%
        inner_join(gather_view(get_tbl (table = se_tbl)) %>%
                   rename (se = val))

tfilter_view <- function (tbl,team_id,con=R_CON_DB)
    tbl %>%
        semi_join (get_tbl (con,table="Players") %>%
                   filter (Team_id == team_id))


# ugly as fuck but does the job
get_choices <- function(table)
{
    res <- alist ()
    as_tibble (table) %>%
        pwalk (function (...){
            row <- c (...)
            tmplist <- alist ()
            tmplist [row [2]] <- as.numeric (row [1])
            res <<- append (tmplist,res)})
    res
}


get_all_views <- function (con=R_CON_DB,team_id)
    list (
        by_set = join_views_ms (con,mean_tbl = "set_mean",se_tbl = "set_se",team_id),
          by_game = join_views_ms(con,mean_tbl = "game_mean",se_tbl = "game_se",team_id),
        set_global = get_tbl (con,table = "set_global") %>%
            tfilter_view (con = con,team_id = team_id) %>%
            gather_global_view ,
        game_global = get_tbl (con,table = "game_global") %>%
            tfilter_view (con = con,team_id = team_id)%>%
            gather_global_view)
