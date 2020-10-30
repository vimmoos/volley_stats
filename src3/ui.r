
OT_tab <-
  tabItem(
    tabName = "tstats",
    fixedPanel(
      style = "z-index:100;",
      get_frontend(dropmenu, alist("team_settings",
        title_sel = "Select Position",
        icon = icon("gear"))),
      right = 20,
      up = 1),
    h1("Team Stats", style = "text-align:center;font-size:300%;"),
    fluidRow(
      get_frontend(attack, alist("team")),
      get_frontend(pass, alist("team")),
      get_frontend(block, alist("team")),
      get_frontend(serve, alist("team"))))

OP_tab <-
  tabItem(
    tabName = "pstats",
    fixedPanel(
      style = "z-index:100;",
      get_frontend(dropmenu, alist("player_settings",
        title_sel = "Select Player",
        icon = icon("gear"))),
      right = 10,
      up = 0),
    h1("Player Stats", style = "text-align:center;font-size:300%;"),
    fluidRow(
      get_frontend(attack, alist("player")),
      get_frontend(pass, alist("player")),
      get_frontend(block, alist("player")),
      get_frontend(serve, alist("player"))))


Upload_tab <-
  tabItem(
    tabName = "upload",

    fluidRow(
      get_frontend(create_players, list("create_players")),
      get_frontend(create_game, list("create_game")),
      get_frontend(create_team, list("create_team"))), )
Trends_tab <-
  tabItem(
    tabName = "trends",

    fixedPanel(
      style = "z-index:100;",
      get_frontend(droptrends, alist("trends_drop",
        title_sel = "Select Player",
        icon = icon("gear"))),
      right = 10,
      up = 0),
    h1("Trends", style = "text-align:center;font-size:300%; "),
    fluidRow(
      get_frontend(trends, list("trends_attack", title = "Attack", status = "danger")),
      get_frontend(trends, list("trends_block", title = "Block", status = "warning")),
      get_frontend(trends, list("trends_serve", title = "Serve", status = "info")),
      get_frontend(trends, list("trends_pass", title = "Pass", status = "primary"))),
  )


module_body <-
  tabItems(
    OT_tab,
    OP_tab,
    Upload_tab,
    Trends_tab)

module_sidebar <-
  sidebarMenu(
    id = "sidebar",
    menuItem("Overall Team", tabName = "tstats", icon = icon("chart-pie")),
    menuItem("Overall Player", tabName = "pstats", icon = icon("chart-bar")),
    menuItemOutput("upload"),
    menuItem("Trends", tabName = "trends", icon = icon("chart-line")),
    get_frontend(selector, alist(
      "select_ass", "Choose an Association")),
    get_frontend(selector, alist(
      "select_team", "Choose a Team")))
## '.nav-tabs-custom .nav-tabs li.active {
##     border-top-color: #d73925;
## }"'
module_ui <-
  dashboardPage(
    dashboardHeader(
      title = "Volley Stats",
      tags$li(
        class = "dropdown",
        get_frontend(infograph, alist("player", icon = icon("info"))),
        style = "margin-left:-40%;margin-top:20%;")),
    dashboardSidebar(module_sidebar),
    dashboardBody(
      useShinyjs(),
      tags$style(".nav  { padding:1%}"),
      module_body),
    skin = "red")
