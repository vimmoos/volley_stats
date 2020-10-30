read_sql_file <- function(x) paste(readLines(x), collapse = "\n")
load_sql_module <- function(x) {
  read_sql_file(paste0(
    "./db_driver/sql/", x, ".sql"))
}
