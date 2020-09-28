library(shiny)
library(shinydashboard)

f_serve <- function(id,height)
{
    box(
        title=tags$p ("Serve",style= "font-size: 300%;"),
        status = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        fluidRow(
            valueBox(uiOutput(paste0 ("serve_e",id)),
                     "Error",
                     icon = icon("thumbs-down"),color = "red"),
            valueBox(uiOutput(paste0 ("serve_n",id)),
                     "In",icon = icon("thumbs-up"),color = "yellow"),
            valueBox(uiOutput(paste0 ("serve_k",id)),
                     "Ace",icon = icon("bomb"),color = "green")),
        plotOutput (paste0 ("serve_distribution",id),height = height))
}
b_serve <- function(input,output,session,data,dist_data,dist,id)
{
    bind_outputs (data (),c ("serve_e","serve_k","serve_n"))
    levels = c ("serve_e",
                "serve_n",
                "serve_k")

    output [[paste0 ("serve_distribution",id)]] <- renderPlot(
        if (dist ())
            plot_dist (dist_data (),metric,val,levels=levels)
        else plot_mean(data(),metric,m,se,levels=levels))
}

module_serve <- function (borf) if (borf) b_serve else f_serve
