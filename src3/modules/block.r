library(shiny)
library(shinydashboard)
source ("./modules/utils.r")



module_frontend_box(
    name = block,
    args = alist(plot_height=325),
    title = "Block",
    status = "warning",
    width = 5,
    body = list (
                 fluidRow(
                          valueBox(uiOutput(ID (block_e)),"Error",icon = icon("thumbs-down"),color = "red"),

                          valueBox(uiOutput(ID (block_n)),"Touch",icon = icon("thumbs-up"),color = "yellow"),

                          valueBox(uiOutput(ID (block_k)),"Kills",icon = icon("bomb"),color = "green")),
                 withSpinner(plotOutput (ID (block_graph),height = plot_height))))


module_backend(
               name = block,
               args = alist (data=,dist=),
               body =
               {
                   block_data <- reactive ({
                       req(data())
                       lapply (data (),function (x)
                                    x %>%
                                    filter (metric %like% "block*"))})

                                 bind_output (block_e,renderUI (perc_se (block_data ()$data,"block_e")))
                bind_output (block_k,renderUI (perc_se (block_data ()$data,"block_k")))
                bind_output (block_n,renderUI (perc_se (block_data ()$data,"block_n")))

                levels = c ("block_e",
                            "block_n",
                            "block_k")


                bind_output (block_graph,renderPlot (
                                                     if (dist ())
                                                     plot_dist (block_data ()$global,metric,val,levels=levels)
                                                     else
                                                     plot_mean (block_data ()$data,metric,val,se,levels=levels)))})
