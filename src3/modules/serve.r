library(shiny)
library(shinydashboard)



module_frontend_box(
    name = serve,
    args = alist(plot_height=325),
    title = "Serve",
    status = "info",
    body = list (
        fluidRow(
            valueBox(uiOutput(ID(serve_e)),
                     "Error",
                     icon = icon("thumbs-down"),color = "red"),
            valueBox(uiOutput(ID (serve_n)),
                     "In",icon = icon("thumbs-up"),color = "yellow"),
            valueBox(uiOutput(ID (serve_k)),
                     "Ace",icon = icon("bomb"),color = "green")),
        plotOutput (ID (serve_graph),height = plot_height)))


module_backend(
               name = serve,
               args = alist (data=,dist=),
               body =
               {
                serve_data <- reactive (lapply (data (),function (x)
                                                     x %>%
                                                     filter (metric %like% "serve")))

                bind_output (serve_e,renderUI (perc_se (serve_data ()$data,"serve_e")))
                bind_output (serve_k,renderUI (perc_se (serve_data ()$data,"serve_k")))
                bind_output (serve_n,renderUI (perc_se (serve_data ()$data,"serve_n")))


                levels = c ("serve_e",
                            "serve_n",
                            "serve_k")

                bind_output (serve_graph,renderPlot (
                                                    if (dist ())
                                                    plot_dist (serve_data ()$global,metric,val,levels = levels)
                                                    else
                                                    plot_mean (serve_data ()$data,metric,val,se,levels = levels)))})
