module_frontend(
  name = dropmenu,
  args = alist(
    title_sel = ,
    icon = ,
    title = "Settings",
    status = "danger",
    right = TRUE,
    tooltip = tooltipOptions(placement = "left", title = "Settings"),
    label = "Settings"),
  body = dropdownButton(
    status = status,
    right = right,
    icon = icon,
    tooltip = tooltip,
    label = label,
    tags$h3(title),

    get_frontend(selector, list(ID(sel), title_sel)),

    fluidRow(
      column(get_frontend(mode_sel, list(ID(distribution),
        "Distribution",
        inline = TRUE)),
      uiOutput(ID(warning)),
      width = 6),

      column(get_frontend(mode_sel, list(ID(set_game), "Game/Set", inline = TRUE)),
        tags$p("decide the context in which the probability of the event will be calculated"),
        width = 6))))

module_backend(
  name = dropmenu,
  args = alist(
    choices = ,
    reactive = FALSE,
    selected = NULL),
  body = {
    dist <- get_backend(mode_sel, list(ID(distribution)))

    bind_output(
      warning,
      renderUI(if (dist()) {
        tags$p("distribution mode need at least 3 data point for the given context",
          style = "color: #dd4b39;")
      } else {
        tags$p()
      }))




    list(
      game_set = get_backend(mode_sel, list(ID(set_game))),
      dist = dist,
      selected = if (reactive) {
        get_backend(
          selectorR,
          list(ID(sel),
            choices = choices,
            selected = selected))
      } else {
        get_backend(
          selectorS,
          list(ID(sel),
            choices = choices,
            selected = selected))
      })})
