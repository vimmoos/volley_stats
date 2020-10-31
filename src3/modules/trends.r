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



          bind_output(
                      trends_graph,
                      renderPlot(ggplot(
                                        data() [startsWith(data()$metric, met), ],
                                        aes(x = Date, y = val, color = metric, shape = metric)) +
                                       scale_fill_manual(values = COLORS) +
                                       scale_color_manual(values = COLOR) +
                                       facet_grid(metric ~ ., labeller = labeller(metric = LABELLER)) +
                                       theme(legend.position = "none") +
                                       geom_point() +
                                       geom_smooth(method = "glm", aes(fill = metric))))})
