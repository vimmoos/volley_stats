library(shiny)
library(shinydashboard)
source ("./modules/utils.r")



module_frontend_box(
    name = attack,
    args = alist(plot_height=325),
    title = "Attack",
    status = "danger",
    width = 5,
    body = list (
                 fluidRow(
                          valueBox(uiOutput(ID (att_e)),"Error",icon = icon("thumbs-down"),color = "red"),

                          valueBox(uiOutput(ID (att_n)),"In",icon = icon("thumbs-up"),color = "yellow"),

                          valueBox(uiOutput(ID (att_k)),"Kills",icon = icon("bomb"),color = "green")),
        withSpinner (plotOutput (ID (att_graph),height = plot_height))))


module_backend(
               name = attack,
               args = alist (data=,dist=),
               body =
               {
                ##    att_data <- reactive ({

                   ##        ## Unit: microseconds
                   ##        ## newtest == Plantgrowth but with group as character
                   ##        ##                                           expr     min      lq      mean
                   ##        ##      PlantGrowth %>% filter(group %like% "c*") 646.443 663.705 719.04139
                   ##        ##  newtest %>% filter(startsWith(group, "ctrl")) 627.677 642.500 674.60268
                   ##        ##   newtest[startsWith(newtest$group, "ctrl"), ]  28.042  34.094  40.42703
                   ##        ##    median       uq       max neval
                   ##        ##  669.5060 687.9200 204510.42 10000
                   ##        ##  648.1705 666.8455  16305.40 10000
                   ##        ##   40.9470  42.9100   4542.91 10000

                   ##        ## lapply (data (),function (x)
                   ##        ##              x %>%
                   ##        ##              filter (startsWith (metric,"att")))
                   ##        ## really faster
                   ##        ## in general with this method applied every where we get 20ms gain at the startup
                   ##                           list (data = data ()$data [startsWith (data ()$data$metric,"att"),],
                   ##                                        global = data ()$global [startsWith (data ()$global$metric,"att"),])})

                   ##    bind_output (att_e,renderUI (perc_se (att_data ()$data,"att_e")))
                   ## bind_output (att_k,renderUI (perc_se (att_data ()$data,"att_k")))
                   ##    bind_output (att_n,renderUI (perc_se (att_data ()$data,"att_n")))



                   ## bind_output (att_graph,renderPlot (
                   ##                                    if (dist ())
                   ##                                    plot_dist (att_data ()$global,metric,val)
                   ##                                    else
                   ##                                        plot_mean (att_data ()$data,metric,val,se)))

                bind_output (att_e,renderUI (perc_se (data ()$data,"att_e")))
                   bind_output (att_k,renderUI (perc_se (data ()$data,"att_k")))
                   bind_output (att_n,renderUI (perc_se (data ()$data,"att_n")))


                   bind_output (att_graph,renderPlot (
                                                      if (dist ())
                                                      plot_dist (data ()$global [startsWith (data ()$global$metric,"att"),],metric,val)
                                                      else
                                                      plot_mean (data ()$data [startsWith (data ()$data$metric,"att"),],metric,val,se)))
               })
