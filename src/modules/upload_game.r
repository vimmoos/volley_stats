module_frontend_box(
  create_game,
  args = alist(accept = c("csv", ".csv", "comma-separated-values")),
  title = "Upload Game",
  status = "info",
  width = 6,
  body = list(
    airDatepickerInput(ID(game_date),
      label = "Select the date of the game",
      autoClose = TRUE,
      startView = Sys.Date(),
      maxDate = Sys.Date(),
      addon = "none"),
    fluidRow(
      column(
        width = 6,
        get_frontend(selector, alist(ID(team_ass), "Select  Home Team Association")),
        get_frontend(selector, alist(ID(team_name), "Select  Home Team name"))),
      column(
        width = 6,
        get_frontend(selector, alist(ID(op_ass), "Select  away Team Association")),
        get_frontend(selector, alist(ID(op_name), "Select  away Team name")))),

    fluidRow(
      column(fileInput(ID(file),
        "Choose the csv file of the game",
        width = "60%",
        multiple = FALSE, accept = accept), width = 8),
      column(downloadButton(
        ID(template_g),
        "Download Template"), width = 4)),

    actionButton(ID(upload_game),
      label = "Upload Game",
      icon = icon("upload"))))
module_backend(
  create_game,
  body = {
    observe(updateAirDateInput(session, ID(game_date),
      options = list(autoClose = "true")))

    team_ass <- get_backend(selectorS, alist(ID(team_ass),
      choices =
        with_db(
          get_all_associations())))
    team_name <- get_backend(selectorR, alist(ID(team_name),
      choices = reactive({
        req(team_ass())
        with_db(
          get_team_name(assoc = team_ass()))})))
    op_ass <- get_backend(selectorS, alist(ID(op_ass),
      choices = with_db(get_all_associations())))
    op_name <- get_backend(selectorR, alist(ID(op_name),
      choices =
        reactive({
          req(op_ass(), team_ass(), team_name())
          names <- with_db(get_team_name(assoc = op_ass()))
          if (team_ass() == op_ass()) {
            (as_tibble(names) %>%
              filter(value != team_name()))$value
          } else {
            names
          }})))


    upload_confirmation(
      session,
      what = get_in(upload_game),
      req_objs = list(
        get_in(game_date), team_name(), team_ass(), op_name(),
        op_ass(), get_in(file)),
      bool_err =
        isnull(
          get_in(game_date), team_name(),
          team_ass(), op_name(),
          op_ass(), get_in(file)),
      conf_id = confirm_game,
      conf_title = "Are you sure to upload locally?",
      conf_text = tags$ul(
        tags$li(paste("Date:", get_in(game_date))),
        tags$li(paste("Home Team:", team_name())),
        tags$li(paste("Away Team:", op_name())),
        tags$li(paste("File:", get_in(file)$name))),
      body = {
        team_id <- get_team_id(
          assoc = team_ass(),
          name = team_name())
        op_id <- get_team_id(
          assoc = op_ass(),
          name = op_name())

        sub_player_id(games(), op_id, team_id)

        game_id <- add_game(
          opp_id = op_id,
          team_id = team_id,
          date = get_in(game_date))
        add_stats(
          df = games(),
          opp_id = op_id,
          team_id = team_id,
          game_id = game_id)
        cols <- dbGetQuery(R_CON_DB,
                        "SELECT COLUMN_NAME FROM information_schema.columns WHERE table_name = 'Stats'")

        for (col in cols$COLUMN_NAME){
          str = paste0("UPDATE Stats SET ",col," = COALESCE(",col,",0);")
          dbExecute(con,str)
        }})



    games <- reactive({
      req(get_in(file))
      tryCatch(read.csv(get_in(file)$datapath),
        error = function(e) {
          stop(safeError(e))
        })})

    bind_output(template_g, downloadHandler(
      filename = function() "template_game.csv",
      content = function(file) {
        write.csv(games_template, file, row.names = FALSE)
      }))})
