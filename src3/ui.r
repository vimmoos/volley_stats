
library (shiny)
library (shinydashboard)
source("./modules/attack.r")
source("./modules/serve.r")
source("./modules/pass.r")
source("./modules/selector.r")
source("./modules/mode_sel.r")
source("./modules/dropmenu.r")
source ("./modules/upload.r")
source ("./modules/create_team.r")
source ("./modules/create_players.r")


OT_tab <-
    tabItem(tabName = "tstats",
            fixedPanel (
                style="z-index:100;",
                module_dropmenu (0) ("team","Distribution"),
                right = 20,
                up = 1),
            h1 ("Team Stats",style="text-align:center;font-size:300%;"),
            fluidRow(
                module_attack (0) ("team",325),
                module_serve (0) ("team",325),
                module_pass (0) ("team",325))
            )

OP_tab <-
    tabItem(tabName = "pstats",
            fixedPanel (
                style="z-index:100;",
                module_dropmenu (0) ("player","Distribution"),
                right = 20,
                up = 1),
            h1 ("Player Stats",style = "text-align:center;font-size:300%;"),
            fluidRow (
                      module_attack (0) ("player",325),
                      module_pass (0) ("player",325),
                      module_serve (0) ("player",325)))


Upload_tab <-
    tabItem (
        tabName = "upload",
        fluidRow (
            get_frontend (create_players,list ("create_players")),
            get_frontend (create_game,list ("create_game")),
            get_frontend(create_team,list ("create_team"))
        ),

    )



module_body <-
    tabItems (
        OT_tab,
        OP_tab,
        Upload_tab,

        tabItem(tabName = "ptrends", h4("test floating button"),

                          fixedPanel(
                                     actionButton("test", label = "test"),
                                     right = 10,
                                     bottom = 10
                                     )
                          ),
        ## tabItem (tabName = "ptrends",
        ##                    h2 ("Player Stats"),
        ##                    box (title = "Collector",
        ##                                 actionButton ("plus","dio"),
        ##                                 actionButton ("minus","porco"))),
        tabItem (tabName = "ttrends",
                           h2 ("Team Stats"),
                           box (title = "moc plot"),
                           plotOutput("mtcars")))
module_sidebar <-
    sidebarMenu (
                 menuItem ("Overall Player",tabName = "pstats", icon = icon ("chart-bar")),
                 menuItem ("Overall Team",tabName = "tstats", icon = icon ("volleyball-ball")),
                 menuItem ("Player Trends",tabName = "ptrends", icon = icon ("chart-bar")),
                 menuItem ("upload",tabName = "upload", icon = icon ("chart-bar")),
                 menuItem ("Team Trends",tabName = "ttrends", icon = icon ("volleyball-ball")))
## '.nav-tabs-custom .nav-tabs li.active {
##     border-top-color: #d73925;
## }"'
module_ui <-
    dashboardPage(
        dashboardHeader(title = "Volley Stats"
                                ),
        dashboardSidebar(module_sidebar),

        dashboardBody(
        tags$style(".nav  { padding:1%}"),
                      module_body),
        skin = "blue")
