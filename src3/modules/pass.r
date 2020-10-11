library(shiny)
library(shinydashboard)
source ("./modules/utils.r")


module_frontend_box(
    name = pass,
    args = alist(plot_height=325),
    title = "Pass",
    status = "primary",
    body = list (
        fluidRow (
            valueBox(uiOutput(ID (sr_er)),"Error",
                     icon = icon("thumbs-down"),color = "red",width = 3),

            valueBox(uiOutput(ID (sr_p)),"Playable",
                     icon = icon("thumbs-up"),color = "yellow",width = 3),

            valueBox(uiOutput(ID (sr_g)),"Good",
                     icon = icon("thumbs-up"),color = "lime",width = 3),

            valueBox(uiOutput(ID (sr_ex)),"Excelent",
                     icon = icon("bomb"),color = "green",width = 3)),

        plotOutput (ID (pass_graph),height = plot_height)))


module_backend(
               name = pass,
               args = alist (data=,dist=),
               body =
               {
                sr_data <- reactive (lapply (data (),function (x)
                                                  x %>%
                                                  filter (metric %like% "sr")))

                bind_output (sr_er,renderUI (perc_se (sr_data ()$data,"sr_er")))
                bind_output (sr_p,renderUI (perc_se (sr_data ()$data,"sr_p")))
                bind_output (sr_g,renderUI (perc_se (sr_data ()$data,"sr_g")))
                bind_output (sr_ex,renderUI (perc_se (sr_data ()$data,"sr_ex")))

                levels = c ("sr_er","sr_p","sr_g","sr_ex")

                fill = c ("#dd4b39", "#00a65a","#01ff70",
                          "#f39c12")


                bind_output (pass_graph,renderPlot (
                                                   if (dist ())
                                                   plot_dist (sr_data ()$global,metric,val,levels = levels,fill=fill)
                                                   else
                                                   plot_mean (sr_data ()$data,metric,val,se,levels = levels, fill=fill)))})
