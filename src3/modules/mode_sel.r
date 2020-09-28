library(shiny)
library(shinydashboard)
library(shinyWidgets)

f_mode_sel <- function(id,title,status="primary",inline=FALSE)
{
    materialSwitch(inputId = paste0("switch",id),label = title,
                   status = status,inline=inline)
}

b_mode_sel <- function(input,output,session,id)
{
    reactive (input [[paste0 ("switch",id)]])

}

module_mode_sel <- function (borf) if (borf) b_mode_sel else f_mode_sel
