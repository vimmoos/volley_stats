library (gtools)

bind_reactive <- defmacro(data_symb,at,body,expr= data_symb[[at]] <- reactive(body))


bind_filter <- defmacro(data_symb,at,data,column,regexp,
                        expr =  bind_reactive (data_symb,at,{
                            data %>%
                                filter (column %like% regexp)}))

binds_filter <- defmacro (data_symb,data,column,tuples,
                          expr = eval (bquote (
                          {data_symb <- reactiveValues ()
                              .. (map (tuples,function (x)
                                              bquote (bind_filter (data_symb,. (x [1]),data,column,. (x [2])))))

                          },splice=TRUE))
                          )


get_csv <- function(path) read.csv(path) %>%
                              as_tibble %>%
                              mutate_if(is.character,as.factor)


check_row <- function(data)
    data[,!names(data) %in% c("Set")]  %>%
        apply(1,FUN=
                    function(row)
                        all(as.numeric(row) == 0 | is.na(as.numeric(row))))


m <-function(x) mean(x[!is.na(x)])

s <- function(x) sd(x[!is.na(x)])

se <- function(x) sd(x[!is.na(x)])/sqrt(length(x[!is.na(x)]))


filter_attacker <- function (data) filter(data,!Position %in% c("Libero","Setter"))

filter_passer <- function (data) filter(data,!Position %in% c("Middle_Blocker","Setter","Opposite"))

filter_server <- function (data) filter(data,!Position %in% c("Libero"))


read_data <- function ()
{
    position <- get_csv("~/volley_stats/data/h1_position.csv")

    data <- get_csv("~/volley_stats/data/first_match.csv") %>% left_join(position)

    data[!check_row(data),]

}


pre_proc_data <- function (data)
{

    data %>%
        mutate(Set=1)%>%
        group_by(Team,Player,Opponent,Position,Set)%>%
        mutate(ServeR_tot = ServeR_P_Err + ServeR_P_P + ServeR_G_P + ServeR_E_P,
               Serve_tot = Serve_error + Serve_Ace + Serve_null)

}

sum_set <- function (data)
{
    data %>% summarise_each(funs=function(x)
        ifelse(is.factor(x),x,sum(x)))}



prob_data <- function (data)
{
    data %>%
        group_by (Player,Opponent,Position,Set) %>%
        summarise(
                  att_k = Attack_kills/Attack_n,
                  att_e = Attack_error/Attack_n,
                  att_n = (Attack_n - (Attack_kills+Attack_error) ) /Attack_n,
                  sr_er = ServeR_P_Err / ServeR_tot,
                  sr_p = ServeR_P_P / ServeR_tot,
                  sr_g = ServeR_G_P / ServeR_tot,
                  sr_ex = ServeR_E_P / ServeR_tot,
                  serve_k = Serve_Ace/Serve_tot,
                  serve_e = Serve_error/Serve_tot,
                  serve_n = Serve_null/Serve_tot) %>%
        gather ("metric","val",4:14)
}

mean_data <- function (data)
{
    data [,!names (data) %in% c ("Opponent")] %>%
        group_by (Player,Position,metric) %>%
        summarise_each (lst (m,se))
}

mean_team_data <- function (data)
{
    data [,!names (data) %in% c ("Opponent","Player")] %>%
        group_by (Position,metric) %>%
        summarise_each (lst (m,se))
}

gather_view <- function (con = R_CON_DB,tbl_name)
    get_tbl (con,table=tbl_name) %>%
        collect %>%
        gather("metric","val",-Player_id)

join_views_ms <- function(con=R_CON_DB,mean_name,se_name)
    gather_view(con,mean_name) %>%
        inner_join(gather_view(con,se_name) %>%
                   rename (se = val))
