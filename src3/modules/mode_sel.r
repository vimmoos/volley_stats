library(shiny)
library(shinydashboard)
library(shinyWidgets)


module_frontend(
    name = mode_sel,
    args = alist(title=,status="primary",inline = FALSE),
    body =  materialSwitch(inputId = ID (switch),label = title,
                                     status = status,inline=inline))

module_backend (
    name = mode_sel,
    body = reactive (get_in (switch)))
