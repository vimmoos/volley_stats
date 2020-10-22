library(shiny)
library(shinydashboard)
library(shinyWidgets)

module_frontend(
    name = infograph,
    args = alist(
        icon = ,
        status=NULL,
        size = "sm"),
    body = circleButton (
        ID (info_button),
        icon = icon,
        status = status,
        size = size))

t_e_x_t_ <-  tags$div (tags$h3 ("Default graphs"),
                       tags$p (paste ("The default graphs are just cols,\n",
                                      "and if you have some stats knowledge they are\n",
                                      "quite trivial to read. On the other side if you dont,",
                                      "here is the fast explanation.",
                                      "The height of the col indicate the mean value of the event.",
                                      "The \"bars\" are the standard error which is:",
                                      "the standard deviation of the sample divided by the square root of size of the sample")),
                       tags$br (),
                       tags$p ("(if you are not familiar with those terms i suggest to look it up on internet! ",
                               "and if you are too lazy for that here is a quote from wikipedia:\"Put simply, ",
                               "the standard error of the sample mean is an estimate of how far the sample mean is ",
                               "likely to be from the population mean, whereas the standard deviation of the sample is",
                               "the degree to which individuals within the sample differ from the sample mean\")"),
                       tags$br (),
                       tags$h3 ("Distribution graphs"),
                       tags$p (paste ("Those graphs are a bit more complicated but they give you a better view on the data.",
                                      "Those graphs are generally refered as violin graphs and they show the distribution of the data mirrored,",
                                      "in order to have a vertical graph instead of an orizontal one which is usually the standard way to look at distribution.",
                                      "The lines in the graphs represent the different quantiles (as before if you are not familiar with that look it up on the internet!",
                                      "and if you too lazy they simply indicate the percentage of data until that line so for example the first line indicate that until it",
                                      "25% of the data can be found,the next one is 50% and finally 75%)",
                                      "Finally the big black point on the graph represent the median (which is more resiliant to the outliers compared to the mean),",
                                      " and the smaller points are litelly the data itself"))
                       )

module_backend (
                name = infograph,
                args = alist (),
                body =
                observeEvent (get_in (info_button),
                                     sendSweetAlert (session,
                                                     type = "info",
                                                     html = TRUE,
                                                     title= "How to read the graphs",
                                                     text =t_e_x_t_)))
