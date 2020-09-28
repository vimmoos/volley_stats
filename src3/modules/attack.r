library(shiny)
library(shinydashboard)
source ("./modules/utils.r")


f_attack <- function(id,height)
{
    box (
        id = id,
        title=tags$p ("Attack",style= "font-size: 300%;"),
        status = "danger",
        solidHeader = TRUE,
        collapsible = TRUE,
        fluidRow(
            valueBox(uiOutput(paste0("att_e",id)),"Error",icon = icon("thumbs-down"),color = "red"),

            valueBox(uiOutput(paste0 ("att_n",id)),"In",icon = icon("thumbs-up"),color = "yellow"),

            valueBox(uiOutput(paste0 ("att_k",id)),"Kills",icon = icon("bomb"),color = "green")),

        plotOutput (paste0 ("ball_distribution",id),height = height))
}




b_attack <- function(input,output,session,data,dist_data,dist,id)
{
    bind_outputs (data (),c ("att_e","att_k","att_n"))


    output [[paste0 ("ball_distribution",id)]] <-renderPlot(
        if (dist ())
            plot_dist (dist_data (),metric,val)
        else plot_mean(data(),metric,m,se)
    )

}


module_attack <- function(borf)  if (borf) b_attack else f_attack
