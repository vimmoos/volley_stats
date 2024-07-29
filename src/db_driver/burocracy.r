library(RMariaDB)
library(DBI)
library(gtools)
library(tidyverse)
library(curl)

R_CON_DB <- NULL

## dhost <- "0.0.0.0"
dhost <- Sys.getenv("DB_HOST")
dhost <- nslookup(dhost)

## ddatabase <- "volley"
ddatabase <- Sys.getenv("DB_NAME")

duser <- Sys.getenv("DB_USER")

dpassword <- Sys.getenv("DB_PASSWORD")





print(dhost)
print(ddatabase)
print(duser)
print(dpassword)

startup <- function(host = dhost, database = ddatabase, password = dpassword,user = duser) {
  R_CON_DB <<- dbConnect(MariaDB(), host=host,dbname = database,user=user,password=password)
}

bye <- function(con = R_CON_DB) dbDisconnect(con)


with_db <- defmacro(body, expr = {
  startup()
  res <- tryCatch(body, error = function(e) {
    bye()
    stop(safeError(e))})
  bye()
  res})

get_tbl <- function(con = R_CON_DB, table) tbl(con, table)

position_template <-
  as_tibble(
    list(
      Name = c(
        "name1", "name2",
        "name3", "name4", "name5"),
      Position = c(
        "Opposite", "Middle_Blocker", "Setter",
        "Libero", "Outside_Hitter")))

games_template <-
  as_tibble(
    list(
      Name = c("name1"),
      Set = c(as.integer(1)),
      Attack_n = c(as.integer(0)),
      Attack_e = c(as.integer(0)),
      Attack_k = c(as.integer(0)),
      ServeR_er = c(as.integer(0)),
      ServeR_p = c(as.integer(0)),
      ServeR_g = c(as.integer(0)),
      ServeR_ex = c(as.integer(0)),
      Serve_p = c(as.integer(0)),
      Serve_a = c(as.integer(0)),
      Serve_n = c(as.integer(0)),
      Serve_e = c(as.integer(0)),
      Block_t = c(as.integer(0)),
      Block_e = c(as.integer(0)),
      Block_k = c(as.integer(0))))
