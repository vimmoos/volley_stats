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
                       # put in global.r
                   levels = c ("block_e",
                               "block_n",
                               "block_k")
                       bind_output (block_e,renderUI (perc_se (data ()$data,"block_e")))
                   bind_output (block_k,renderUI (perc_se (data ()$data,"block_k")))
                   bind_output (block_n,renderUI (perc_se (data ()$data,"block_n")))



                   bind_output (block_graph,renderPlot (
                                                if (dist ())
                                                    plot_dist (data ()$global [startsWith (data ()$global$metric,"block"),],metric,val,levels=levels)
                                                else
                                                    plot_mean (data ()$data [startsWith (data ()$data$metric,"block"),],metric,val,se,levels=levels)))
               })
