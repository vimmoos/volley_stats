library(shiny)
library(shinydashboard)
source ("./modules/utils.r")



module_frontend_box(
    name = attack,
    args = alist(plot_height=325),
    title = "Attack",
    status = "danger",
    body = list (
                 fluidRow(
                          valueBox(uiOutput(ID (att_e)),"Error",icon = icon("thumbs-down"),color = "red"),

                          valueBox(uiOutput(ID (att_n)),"In",icon = icon("thumbs-up"),color = "yellow"),

                          valueBox(uiOutput(ID (att_k)),"Kills",icon = icon("bomb"),color = "green")),
                 plotOutput (ID (att_graph),height = plot_height)))


module_backend(
    name = attack,
    args = alist (data=,dist=),
    body =
        {
            att_data <- reactive (lapply (data (),function (x)
                x %>%
                filter (metric %like% "att*")))
            bind_output (att_e,renderUI (perc_se (att_data ()$data,"att_e")))
            bind_output (att_k,renderUI (perc_se (att_data ()$data,"att_k")))
            bind_output (att_n,renderUI (perc_se (att_data ()$data,"att_n")))


            bind_output (att_graph,renderPlot (
                                       if (dist ())
                                           plot_dist (att_data ()$global,metric,val)
                                       else
                                           plot_mean (att_data ()$data,metric,val,se)))})
