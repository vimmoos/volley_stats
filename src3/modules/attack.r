

module_frontend_box(
  name = attack,
  args = alist(plot_height = 325),
  title = "Attack",
  status = "danger",
  width = 5,
  body = list(
    fluidRow(
      valueBox(uiOutput(ID(att_e)), "Error", icon = icon("thumbs-down"), color = "red"),

      valueBox(uiOutput(ID(att_n)), "Inside", icon = icon("thumbs-up"), color = "yellow"),

      valueBox(uiOutput(ID(att_k)), "Kills", icon = icon("bomb"), color = "green")),
    withSpinner(plotOutput(ID(att_graph), height = plot_height))))


module_backend(
  name = attack,
  args = alist(data = , dist = ),
  body = {
    bind_output(att_e, renderUI(perc_se(data()$data, "att_e")))
    bind_output(att_k, renderUI(perc_se(data()$data, "att_k")))
    bind_output(att_n, renderUI(perc_se(data()$data, "att_n")))


    bind_output(
      att_graph,
      renderPlot(
        if (dist()) {
          plot_dist(
            data()$global [
              startsWith(
                data()$global$metric,
                "att"), ],
            metric, val)
        } else {
          plot_mean(
            data()$data [
              startsWith(
                data()$data$metric,
                "att"), ],
            metric, val, se)}))})
