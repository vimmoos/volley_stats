library(shiny)
library (tidyverse)
library (shinydashboard)



OT_tab <- tabItem(tabName = "tstats",
                  h2 ("Team Stats"),
                  fluidRow(
                      box ( h2 ("Attack"),
                           fluidRow(
                               valueBox(uiOutput("t_atk_err"),"Error",icon = icon("thumbs-down"),color = "red"),
                               valueBox(uiOutput("t_atk_In"),"In",icon = icon("thumbs-up"),color = "yellow"),
                               valueBox(uiOutput("t_atk_kills"),"Kills",icon = icon("bomb"),color = "green")),
                           plotOutput ("ball_distribution",height = 325)),
                      box (
                          h2 ("Serve & Pass"),
                          fluidRow(
                              valueBox(uiOutput("t_serve_err"),"Serve Error",icon = icon("thumbs-down"),color = "red"),
                              valueBox(uiOutput("t_serve_In"),"Serve In",icon = icon("thumbs-up"),color = "yellow"),
                              valueBox(uiOutput("t_serve_kills"),"Serve Ace",icon = icon("bomb"),color = "green")),
                          fluidRow (
                              valueBox(uiOutput("t_pass_err"),"Pass Error",icon = icon("thumbs-down"),color = "red",width = 3),
                              valueBox(uiOutput("t_pass_pl"),"Playable Pass",icon = icon("thumbs-up"),color = "yellow",width = 3),
                              valueBox(uiOutput("t_pass_g"),"Good Pass",icon = icon("thumbs-up"),color = "lime",width = 3),
                              valueBox(uiOutput("t_pass_ex"),"Excelent Pass",icon = icon("bomb"),color = "green",width = 3)),
                          plotOutput ("pass_distribution",height = 325))),
                  fluidRow (
                      box ( width = 12,
                           h2 ("Graphs"),
                           uiOutput ("test"),
                           plotOutput ("mtcars",height = 500)))
                  )

OP_tab <- tabItem(tabName = "pstats",
                  h2 ("Player Stats")
                  )

ui <- dashboardPage(
    dashboardHeader(title = "Volley Stats"),
    dashboardSidebar(
        sidebarMenu (
            menuItem ("Player Trends",tabName = "ptrends", icon = icon ("chart-bar")),
            menuItem ("Team Trends",tabName = "ttrends", icon = icon ("volleyball-ball")),
            menuItem ("Overall Player",tabName = "pstats", icon = icon ("chart-bar")),
            menuItem ("Overall Team",tabName = "tstats", icon = icon ("volleyball-ball"))
        )),
    dashboardBody(
        tabItems (
            OT_tab,
            OP_tab,
            tabItem (tabName = "ptrends",
                     h2 ("Player Stats"),
                     box (title = "Collector",
                          actionButton ("plus","dio"),
                          actionButton ("minus","porco"))),
            tabItem (tabName = "ttrends",
                     h2 ("Team Stats"),
                     box (title = "moc plot"
                          )))
        ## valueBox(100, "Basic example"),
        ## tableOutput("mtcars")
    )
)

server <- function(input, output)
{
    output$t_atk_err <- renderUI("10%")
    output$t_atk_kills <- renderUI("45%")
    output$t_atk_In <- renderUI("45%")
    output$t_serve_err <- renderUI("8%")
    output$t_serve_kills <- renderUI("12%")
    output$t_serve_In <- renderUI("80%")
    output$t_pass_err <- renderUI("10%")
    output$t_pass_pl <- renderUI("42%")
    output$t_pass_g <- renderUI("35%")
    output$t_pass_ex <- renderUI("13%")
    output$ball_distribution <- renderPlot(plot (mtcars$gear))
    output$pass_distribution <- renderPlot(plot (mtcars$disp))
    output$test <- renderUI(selectInput("x","select only charter var",choices = c(1,2,3)))
    output$mtcars <- renderPlot(plot (mtcars$gear))
}

shinyApp(ui, server)
