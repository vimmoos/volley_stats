library(shiny)
library(shinydashboard)
library(DT)
library(shinyjs)
library(sodium)
source("./credentials.r")
source ("./login_page.r")
source ("./server.r")


                                        # Main login screen

header <- dashboardHeader(title = "Volley Stats", uiOutput("logoutbtn"))

sidebar <- dashboardSidebar(uiOutput("sidebarpanel"))

body <- dashboardBody(shinyjs::useShinyjs(), uiOutput("body"))

ui<-dashboardPage(header, sidebar, body, skin = "blue")


runApp(list(ui = ui, server = server), launch.browser = TRUE,
       host = getOption("shiny.host","192.168.1.109"))
