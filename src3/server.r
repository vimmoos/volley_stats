

module_server <- function(input, output, session, auth = NULL) {
  output$upload <- renderMenu({
    req(auth)
    if (as.logical(reactiveValuesToList(auth)$admin)) {
      menuItem("Upload", tabName = "upload", icon = icon("globe"))
    }})

  filtered_fun_team <- function(x, global = FALSE) {
    req(opt_team$selected())
    sel <- opt_team$selected()
    if (sel == "All") {
      x %>%
        {if (global) {
          . %>%
            group_by(metric, index)
        } else {
          . %>%
            group_by(metric)
        }
        }() %>%
        select(-Position) %>%
        summarise_each(partial(mean, na.rm = TRUE))
    } else {
      x %>%
        filter(Position == sel)
    }}

  assoc <- get_backend(
    selectorS,
    alist(
      id = "select_ass",
      choices = with_db((team_with_stats() %>% collect())$Association)))

  team <-
    get_backend(
      selectorR,
      alist("select_team",
        choices =
          reactive({
            req(assoc())
            get_choices(with_db(
              team_with_stats() %>%
                collect() %>% filter(Association == assoc())))})))


  player_choices <-
    reactive({
      req(team())
      get_choices(with_db(
        get_players_nid(team_id = team())))})

  opt <-
    get_backend(
      dropmenu,
      alist("player_settings",
        reactive = TRUE,
        choices = player_choices))


  data <- reactive({
    req(team())
    with_db(get_all_views(team_id = team()))})


  select_data <- reactive({
    if (opt$game_set()) {
      list(
        data = data()$by_set,
        global = data()$set_global)
    } else {
      list(
        data = data()$by_game,
        global = data()$game_global)
    }})


  filtered_data <- reactive({
    req(opt$selected())

    ## Unit: microseconds
    ##                           expr     min      lq      mean  median      uq
    ##  filter(test, Player_id == 10) 612.168 632.937 690.81701 641.007 699.848
    ##   test[test$Player_id == 10, ]  51.807  56.867  65.41083  63.980  67.176
    ##         max neval
    ##  146906.682 10000
    ##    3190.724 10000
    list(
      data = select_data()$data [select_data()$data$Player_id == opt$selected(), ],
      global = select_data()$global [select_data()$global$Player_id == opt$selected(), ])})



  get_backend(infograph, list("player", "sidebar"))
  get_backend(attack, list("player", filtered_data, opt$dist))
  get_backend(block, list("player", filtered_data, opt$dist))
  get_backend(pass, list("player", filtered_data, opt$dist))
  get_backend(serve, list("player", filtered_data, opt$dist))


  opt_team <- get_backend(
    dropmenu,
    alist("team_settings",
      choices = c(
        "All", "Opposite",
        "Middle_Blocker",
        "Setter", "Libero",
        "Outside_Hitter")))
  data_team <- reactive({
    append(
      lapply(data() [1:2], function(x) {
        x %>%
          select(-Player_id) %>%
          group_by(Position, metric) %>%
          summarise_each(partial(mean, na.rm = TRUE))
      }),
      lapply(data() [3:4], function(x) {
        x %>%
          select(-Player_id) %>%
          group_by(Position, metric, index) %>%
          summarise_each(partial(mean, na.rm = TRUE))
      }))})

  select_data_team <- reactive({
    if (opt_team$game_set()) {
      list(
        data = data_team()$by_set,
        global = data_team()$set_global)
    } else {
      list(
        data = data_team()$by_game,
        global = data_team()$game_global)
    }})

  filtered_data_team <- reactive({
    list(
      data = select_data_team()$data %>%
        filtered_fun_team(),
      global =
        select_data_team()$global %>%
          filtered_fun_team(global = TRUE))})



  get_backend(attack, list("team", filtered_data_team, opt_team$dist))
  get_backend(pass, list("team", filtered_data_team, opt_team$dist))
  get_backend(block, list("team", filtered_data_team, opt_team$dist))
  get_backend(serve, list("team", filtered_data_team, opt_team$dist))


  data_date <- reactive(data()$game_date_global)
  trends_opt <- get_backend(droptrends, list("trends_drop", choices = reactive(append("All", player_choices()))))

  filtered_data_date <- reactive({
    req(trends_opt$selected())
    if (trends_opt$selected() == "All") {
      data_date()
    } else {
      data_date() [data_date()$Player_id == trends_opt$selected(), ]
    }})


  get_backend(trends, list("trends_attack", filtered_data_date, "att"))
  get_backend(trends, list("trends_block", filtered_data_date, "block"))
  get_backend(trends, list("trends_pass", filtered_data_date, "sr"))
  get_backend(trends, list("trends_serve", filtered_data_date, "serve"))






  get_backend(create_game, list("create_game"))
  get_backend(create_team, list("create_team"))
  get_backend(create_players, list("create_players"))


}
