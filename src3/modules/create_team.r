module_frontend_box(
  create_team,
  title = "Create Team",
  status = "success",
  width = 4,
  body = list(
    get_frontend(selector, alist(ID(association), "Select/create the Association", create = TRUE)),

    radioButtons(ID(gender),
      label = "Gender",
      choices = list("Female" = 0, "Male" = 1)),

    textInput(ID(name_t),
      label = "insert the name of the team",
      value = NULL,
      placeholder = "H1"),

    actionButton(ID(create_team),
      label = "Create Team",
      icon = icon("upload"))))

module_backend(
  create_team,
  body = {
    assoc <-
      get_backend(
        selectorS,
        alist(ID(association),
          choices = with_db(get_all_associations())))

    upload_confirmation(
      session,
      req_objs = list(assoc(), get_in(name_t), get_in(gender)),
      what = get_in(create_team),
      bool_err =
        isnull(
          assoc(), get_in(name_t),
          get_in(gender)) |
          get_in(name_t) == "",
      conf_id = confirm_team,
      conf_title = "Are you sure to upload?",
      conf_text = tags$ul(
        tags$li(paste("Team:", get_in(name_t))),
        tags$li(paste(
          "Gender:",
          if (get_in(gender) == 0) {
            "Female"
          } else {
            "Male"
          })),
        tags$li(paste("Association:", assoc()))),
      body = add_team(
        name = get_in(name_t),
        gender = get_in(gender),
        association = assoc()))})
