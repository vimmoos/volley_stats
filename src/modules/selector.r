module_frontend(
  name = selector,
  args = alist(
    title = ,
    create = FALSE,
    allowEmptyOption = FALSE,
    preload = TRUE,
    createFilter = "[a-z]+"),
  body =
    selectizeInput(ID(selector),
      choices = NULL, selected = NULL,
      label = title,
      options = list(
        create = create,
        allowEmptyOption = allowEmptyOption,
        createOnBlur = create,
        preload = preload,
        createFilter = createFilter)))


module_backend(
  name = selectorR,
  args = alist(
    choices = ,
    selected = NULL),
  body = {
    observe(
      updateSelectizeInput(session, ID(selector),
        selected = if (is.null(selected)) first(choices()) else selected,
        choices = choices(),
        server = TRUE))
    reactive(get_in(selector))})

module_backend(
  name = selectorS,
  args = alist(
    choices = ,
    selected = NULL),
  body = {
    updateSelectizeInput(session, ID(selector),
      selected = if (is.null(selected)) first(choices) else selected,
      choices = choices,
      server = TRUE)
    reactive(get_in(selector))})
