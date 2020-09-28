library(shiny)
library (tidyverse)
library (shinydashboard)

tab_pippo <- tabPanel ("pippo",actionButton ("plus","+"))
tab_gna <- tabPanel ("gna",actionButton ("plus_gna","-"))

tabs_name <- c ("pippo","gna")

ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            do.call (tabsetPanel,list (id="tabset",tab_pippo,tab_gna))),
        mainPanel ()
    ))
server <- function (inp,out){}

shinyApp (ui,server)


ui <- dashboardPage(
    dashboardHeader(title = "Volley Stats"),
    dashboardSidebar(
        sidebarMenu (
            menuItem ("Collect Stats",tabName = "collect", icon = icon ("volleyball-ball")),
            menuItem ("Show Stats",tabName = "stats", icon = icon ("chart-bar"))
        )),
    dashboardBody(
        tabItems (
            tabItem (tabName = "collect",
                     h2 ("Do the collection part gne!"),
                     box (title = "Collector",
                          actionButton ("plus","dio"),
                          actionButton ("minus","porco"))),
            tabItem (tabName = "stats",
                     h2 ("Statistics and plots"),
                     box ( title = "moc plot",
                          plotOutput ("mtcars",height = 250))))
        ## valueBox(100, "Basic example"),
        ## tableOutput("mtcars")
    )
)

server <- function(input, output) {
    output$mtcars <- renderPlot(plot (mtcars$gear))
}

shinyApp(ui, server)
