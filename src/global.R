## for production
## library(compiler)
## enableJIT(3)
library(shiny)
## library(semantic.dashboard)
library(shinydashboard)
library(shinymanager)
library(shinyWidgets)
library(gtools)
library(tidyverse)
library(data.table)
library(shinycssloaders)
source("./utils.r")
source("./modules/utils.r")
source("./db_driver/driver.r")
source("./modules/attack.r")
source("./modules/serve.r")
source("./modules/pass.r")
source("./modules/selector.r")
source("./modules/mode_sel.r")
source("./modules/dropmenu.r")
source("./modules/upload_game.r")
source("./modules/create_team.r")
source("./modules/create_players.r")
source("./modules/infograph.r")
source("./modules/block.r")
source("./modules/trends.r")
source("./modules/trends_menu.r")
source("./ui.r")
source("./server.r")

## for testing
options(browser = "/usr/bin/firefox") ## set firefox as browser
options(shiny.legacy.datatable = TRUE)

ATT_LEVELS <- c(
  "att_e", "att_n", "att_k")

BLOCK_LEVELS <- c(
  "block_e",
  "block_n",
  "block_k"
)

PASS_LEVELS <- c("sr_er", "sr_p", "sr_g", "sr_ex")

SERVE_LEVELS <- c(
  "serve_e",
  "serve_n",
  "serve_p",
  "serve_k")

LABELLER <- unlist(alist(
  "block_e" = "Error", "block_n" = "Touch", "block_k" = "Kill",
  "att_e" = "Error", "att_n" = "Inside", "att_k" = "Kill",
  "sr_er" = "Error", "sr_p" = "Playable", "sr_g" = "Good", "sr_ex" = "Execellent",
  "serve_e" = "Error", "serve_n" = "Inside", "serve_p" = "Good", "serve_k" = "Ace"))


COLORS <- alist(
  "block_e" = "#dd4b39", "block_n" = "#f39c12", "block_k" = "#00a65a",
  "att_e" = "#dd4b39", "att_n" = "#f39c12", "att_k" = "#00a65a",
  "serve_e" = "#dd4b39", "serve_n" = "#f39c12", "serve_p" = "#01ff70", "serve_k" = "#00a65a",
  "sr_er" = "#dd4b39", "sr_p" = "#f39c12", "sr_g" = "#01ff70", "sr_ex" = "#00a65a")
