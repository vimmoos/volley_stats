module_frontend(
  name = infograph,
  args = alist(
    icon = ,
    status = NULL,
    size = "sm"),
  body = circleButton(
    ID(info_button),
    icon = icon,
    status = status,
    size = size))

t_e_x_t_ <- tags$div(
  tags$h3("Default graphs"),
  tags$p(paste(
    "The default graphs are just cols,\n",
    "on the x-axis represent the event we are considering and ",
    "on the y-axis the probability value of that event.",
    "if you have some stats knowledge they are\n",
    "quite trivial to read. On the other side if you dont,",
    "here is the fast explanation.",
    "The height of the col indicate the mean probability value of the event. ",
    "(you can also read it as percentage if make more sense to you (just multiply the value by 100)) ",
    "The black \"bars\" are the standard error which is:",
    "the standard deviation of the sample divided by the square root of size of the sample")),
  tags$br(),
  tags$p(
    "(if you are not familiar with those terms i suggest to look it up on internet! ",
    "and if you are too lazy for that here is a quote from wikipedia:\"Put simply, ",
    "the standard error of the sample mean is an estimate of how far the sample mean is ",
    "likely to be from the population mean, whereas the standard deviation of the sample is",
    "the degree to which individuals within the sample differ from the sample mean\")"),
  tags$br(),
  tags$h3("Distribution graphs"),
  tags$p(paste(
    "Those graphs are a bit more complicated but they give you a better view on the data.",
    "the x-axis and y-axis are the same as the default graphs.",
    "Those graphs are generally refered as violin graphs and they show the distribution of the data mirrored,",
    "in order to have a vertical graph instead of an orizontal one which is usually the standard way to look at distribution.",
    "The lines in the graphs represent the different quantiles (as before if you are not familiar with that look it up on the internet!",
    "and if you too lazy they simply indicate the percentage of data until that line so for example the first line indicate that until it",
    "25% of the data can be found,the next one is 50% and finally 75%)",
    "Finally the big black point on the graph represent the median (which is more resiliant to the outliers compared to the mean),",
    " and the smaller points are literally the data itself"))
)

t_e_x_t_trends <- tags$div(
  tags$h3("Trends Graphs"),
  tags$p(
    paste(
      "Those graphs aim to show the progression over time of the team and players.",
      "The x-axis represent the time (each point on the x-axis represent a game)",
      "The y-axis represent as before the probability value of event.",
      "Lastly the each graph is spilt in multiple section each section representing a particular event,",
      "the name of the event is on the right of the graph",
      "The lines in the graphs represent what's usually in stats is refered as regression.",
      "If you are not familiar with it unfortunately is not that easy to explain it in few lines",
      "so look it up on internet, to have a really basic intuition of what it does, you can see the regression as the",
      "line which approximate better the data ",
      "(although this is not completely correctly but should be enough to get the point)",
      "Those methods (regressions) are usually used to predict future data and ",
      "to create a model which fits those data (but not only)",
      "There are a lots of those methods but here we are using the Generalized Liner Model (GLM)",
      "which is usually really good if you dont know from which distribution the data comes."),
    tags$br(),
    tags$p(paste(
      "The take away from the ones who dont know those stats methods is that you can look at that line and based on the",
      "slope you can asses whether you or team are inproving during time or not."))))

module_backend(
  name = infograph,
  args = alist(tabs = ),
  body =
    observeEvent(
      get_in(info_button),
      sendSweetAlert(session,
        type = "info",
        html = TRUE,
        title = "How to read the graphs",
        text = if (input [[tabs]] == "trends") t_e_x_t_trends else t_e_x_t_)))
