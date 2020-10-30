module_frontend(
  name = trends,
  args = alist(title = , status = , plot_height = 600),
  body = box(
    id = id,
    title = tags$p(title, style = "font-size:300%;"),
    status = status,
    solidHeader =  TRUE,
    collapsible = TRUE,
    withSpinner(plotOutput(ID(trends_graph), height = plot_height))))

module_backend(
  name = trends,
  args = alist(data = , met = ),
  body = {

    fill <- if (met == "sr") {
      PASS_FILL
    } else if (met == "serve") {
      SERVE_FILL
    } else {
      c("#dd4b39", "#00a65a", "#f39c12")
    }


    bind_output(
      trends_graph,
      renderPlot(ggplot(
        data() [startsWith(data()$metric, met), ],
        aes(x = Date, y = val, color = metric, shape = metric)) +
        scale_fill_manual(values = fill) +
        scale_color_manual(values = fill) +
        facet_grid(metric ~ ., labeller = labeller(metric = LABELLER)) +
        theme(legend.position = "none") +
        geom_point() +
        geom_smooth(method = "glm", aes(fill = metric))))})
