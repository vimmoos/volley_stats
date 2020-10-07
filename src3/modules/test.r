library(RMariaDB)
library(DBI)
library (gtools)
library (tidyverse)


test <- tbl (R_CON_DB,"Stats")


test %>%
    group_by (Player_id,Game_id,Set) %>%
    summarize_each (lst (sum)) -> q1
