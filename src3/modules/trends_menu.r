module_frontend(
  name = droptrends,
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

    get_frontend(selector, list(ID(sel), title_sel))

))

module_backend(
  name = droptrends,
  args = alist(
    choices = ,
    reactive = TRUE,
    selected = NULL),
  body = {

    list(
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
