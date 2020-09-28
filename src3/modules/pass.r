library(shiny)
library(shinydashboard)
source ("./modules/utils.r")

f_pass <- function(id,height)
{

    box (
        title=tags$p ("Pass",style= "font-size: 300%;"),
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        fluidRow (
            valueBox(uiOutput(paste0 ("sr_er",id)),"Error",
                     icon = icon("thumbs-down"),color = "red",width = 3),

            valueBox(uiOutput(paste0 ("sr_p",id)),"Playable",
                     icon = icon("thumbs-up"),color = "yellow",width = 3),

            valueBox(uiOutput(paste0 ("sr_g",id)),"Good",
                     icon = icon("thumbs-up"),color = "lime",width = 3),

            valueBox(uiOutput(paste0 ("sr_ex",id)),"Excelent",
                     icon = icon("bomb"),color = "green",width = 3)),

        plotOutput (paste0 ("pass_distribution",id),height = height))
}

b_pass <- function(input,output,session,data,dist_data,dist,id)
{

    bind_outputs (data (),c ("sr_er","sr_p","sr_g","sr_ex"))

    levels = c ("sr_er","sr_p","sr_g","sr_ex")

    fill = c ("#dd4b39", "#00a65a","#01ff70",
                                  "#f39c12")


    output [[paste0 ("pass_distribution",id)]] <- renderPlot(

        if (dist ())
            plot_dist (dist_data (),metric,val,levels=levels,fill=fill)
        else  plot_mean(data(),metric,m,se,levels=levels,
                          fill=fill))
}

module_pass <- function (borf) if (borf) b_pass else f_pass
