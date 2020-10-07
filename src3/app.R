
run <- function()
{
    library(shiny)
    library(shinydashboard)
    source("./ui.r")
    source("./server.r")
    options(browser = "/usr/bin/firefox") ## set firefox as browser
    shinyApp(module_ui,module_server)

}

## runApp(list(ui = module_ui, server = module_server),launch.browser = TRUE,
##            host = getOption("shiny.host","192.168.1.109"))
