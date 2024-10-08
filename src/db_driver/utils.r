library(gtools)
source("./db_driver/burocracy.r")
source("./modules/utils.r")

execute_sql <-
  defmacro(
    name, sql_string,
    args = alist(),
    expr =
      macro_defn(
        if (is.symbol(quote(name))) paste0(quote(name)) else name,
        append(alist(con = R_CON_DB), args),
        dbExecute(con, sql_string)))

create_table <- defmacro(
  name, sql_string,
  expr = execute_sql(paste0("create_", quote(name), "_table"), sql_string))



preproc <- defmacro(group, deselect, expr = get_tbl(table = "Stats") %>%
  group_by(Player_id, group) %>%
  q_sum() %>%
  q_prob() %>%
  rename(index = group) %>%
  inner_join(get_tbl(table = "Players")) %>%
  select(-Name, -Team_id) %>%
  group_by(Player_id, Position) %>%
  select(-deselect))

qview_global <-
  defmacro(
    name, group, deselect,
    expr = macro_defn(
      paste0("qview_", quote(name), "_global"),
      alist(),
      preproc(group, deselect)))

qview_mean <-
  defmacro(
    name, group, deselect,
    expr =
      macro_defn(
        paste0("qview_", quote(name), "_mean"),
        alist(),
        q_mean(preproc(group, deselect))))

qview_se <-
  defmacro(
    name, group, deselect,
    expr =
      macro_defn(
        paste0("qview_", quote(name), "_se"),
        alist(),
        q_se(preproc(group, deselect))))

create_view <- defmacro(
  name_view, query,
  expr = execute_sql(
    paste0("create_", quote(name_view), "_view"),
    paste0("CREATE VIEW ", quote(name_view), " AS ", toString(dbplyr::sql_render(query)))))


bench_query <- function(query, n = 100) {
  bench_fun <- function() {
    for (i in c(1:n)) {
      query %>% collect()
    }
  }
  startup()
  print(system.time(result <- bench_fun()))
  bye()
}

get_id <- function(name, team_df, opp_df) {
  name <- str_trim(name, side = "both")
  x <- team_df [grep(first(name), team_df$Name), ]$Player_id
  y <- opp_df [grep(first(name), opp_df$Name), ]$Player_id
  if (is_empty(x)) {
    if (is_empty(y)) {
      stop(paste("Unmatched Name", name, "names", team_df$Name, opp_df$Name))
    } else {
      y
    }
  } else {
    x
  }
}
