module_frontend_box(
  name = pass,
  args = alist(plot_height = 325),
  title = "Pass",
  status = "primary",
  width = 7,
  body = list(
    fluidRow(
      valueBox(uiOutput(ID(sr_er)), "Error",
        icon = icon("thumbs-down"), color = "red", width = 3),

      valueBox(uiOutput(ID(sr_p)), "Playable",
        icon = icon("thumbs-up"), color = "yellow", width = 3),

      valueBox(uiOutput(ID(sr_g)), "Good",
        icon = icon("thumbs-up"), color = "lime", width = 3),

      valueBox(uiOutput(ID(sr_ex)), "Excelent",
        icon = icon("bomb"), color = "green", width = 3)),

    withSpinner(plotOutput(ID(pass_graph), height = plot_height))))


module_backend(
  name = pass,
  args = alist(data = , dist = ),
  body = {
    bind_output(sr_er, renderUI(perc_se(data()$data, "sr_er")))
    bind_output(sr_p, renderUI(perc_se(data()$data, "sr_p")))
    bind_output(sr_g, renderUI(perc_se(data()$data, "sr_g")))
    bind_output(sr_ex, renderUI(perc_se(data()$data, "sr_ex")))



    bind_output(
      pass_graph,
      renderPlot(
        if (dist()) {
          plot_dist(data()$global[
            startsWith(
              data()$global$metric,
              "sr"), ],
          metric, val,
          levels = PASS_LEVELS)
        } else {
          plot_mean(data()$data [
            startsWith(
              data()$data$metric,
              "sr"), ],
          metric, val, se,
          levels = PASS_LEVELS)
        }))
})
