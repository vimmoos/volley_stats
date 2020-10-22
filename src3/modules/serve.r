library(shiny)
library(shinydashboard)



module_frontend_box(
    name = serve,
    args = alist(plot_height=325),
    title = "Serve",
    status = "info",
    width = 7,
    body = list (
                 fluidRow (
                           valueBox(uiOutput(ID (serve_e)),"Error",
                                            icon = icon("thumbs-down"),color = "red",width = 3),

                           valueBox(uiOutput(ID (serve_n)),"In",
                                            icon = icon("thumbs-up"),color = "yellow",width = 3),

                           valueBox(uiOutput(ID (serve_p)),"Good",
                                            icon = icon("thumbs-up"),color = "lime",width = 3),

                           valueBox(uiOutput(ID (serve_k)),"Ace",
                                            icon = icon("bomb"),color = "green",width = 3)),
        withSpinner (plotOutput (ID (serve_graph),height = plot_height))))


module_backend(
               name = serve,
               args = alist (data=,dist=),
               body =
                   {
                       # put in global.R
                   levels = c ("serve_e",
                               "serve_n",
                               "serve_p",
                               "serve_k")

                   fill = c ("#dd4b39", "#00a65a","#01ff70",
                             "#f39c12")

                   bind_output (serve_k,renderUI (perc_se (data ()$data,"serve_k")))
                   bind_output (serve_n,renderUI (perc_se (data ()$data,"serve_n")))
                   bind_output (serve_p,renderUI (perc_se (data ()$data,"serve_p")))



                   bind_output (serve_graph,renderPlot (
                                                        if (dist ())
                                                        plot_dist (data ()$global[startsWith (data ()$global$metric,"serve"),],metric,val,levels = levels,fill=fill)
                                                        else
                                                        plot_mean (data ()$data [startsWith (data ()$data$metric,"serve"),],metric,val,se,levels = levels,fill=fill)))
                   })
