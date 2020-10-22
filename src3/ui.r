
library (shiny)
library (shinydashboard)
source("./modules/attack.r")
source ("./modules/block.r")
source("./modules/serve.r")
source("./modules/pass.r")
source("./modules/selector.r")
source("./modules/mode_sel.r")
source("./modules/dropmenu.r")
source("./modules/utils.r")
source ("./modules/upload_game.r")
source ("./modules/create_team.r")
source ("./modules/create_players.r")
source ("./modules/infograph.r")


OT_tab <-
    tabItem(tabName = "tstats",
            fixedPanel (
                style="z-index:100;",
                get_frontend (dropmenu,alist ("team_settings",
                                              title_sel ="Select Position",
                                              icon = icon ("gear"))),
                right = 20,
                up = 1),
            h1 ("Team Stats",style="text-align:center;font-size:300%;"),
            fluidRow(

                get_frontend (attack,alist ("team")),
                get_frontend (pass,alist ("team")),
                get_frontend (block,alist ("team")),
                get_frontend (serve,alist ("team"))))

OP_tab <-
    tabItem(tabName = "pstats",
            fixedPanel (
                style="z-index:100;",
                get_frontend (dropmenu,alist ("player_settings",
                                              title_sel ="Select Player",
                                              icon = icon ("gear"))),
                right = 10,
                up = 0),
            h1 ("Player Stats",style = "text-align:center;font-size:300%;"),
            fluidRow (
                      get_frontend (attack,alist ("player")),
                      get_frontend (pass,alist ("player")),
                      get_frontend (block,alist ("player")),
                      get_frontend (serve,alist ("player"))
                      )
            )


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
                          ),
                circleButton ("gna",icon=icon ("info"),size = "sm"),
                selectizeInput ("pippo",
                                choices = NULL, selected =NULL,
                                label = "dio",
                                options = list (create = TRUE,
                                                         allowEmptyOption = FALSE,
                                                         createOnBlur = TRUE,
                                                         preload = TRUE
                                                         )),
                          ),
        tabItem (tabName = "ttrends",
                           h2 ("Team Stats"),
                           box (title = "moc plot"),
                 plotOutput("mtcars")))
id <- "sidebar"
module_sidebar <-
    sidebarMenu (
        menuItem ("Overall Player",tabName = "pstats", icon = icon ("chart-bar")),
        menuItem ("Overall Team",tabName = "tstats", icon = icon ("volleyball-ball")),
        menuItem ("Upload",tabName = "upload", icon = icon ("globe")),
        menuItem ("Team Trends",tabName = "ttrends", icon = icon ("volleyball-ball")),
        menuItem ("Player Trends",tabName = "ptrends", icon = icon ("chart-bar")),
        get_frontend (selector,alist (
                                      "select_ass","Choose an Association")),
        get_frontend (selector,alist (
                                      "select_team","Choose a Team"))
        )
## '.nav-tabs-custom .nav-tabs li.active {
##     border-top-color: #d73925;
## }"'
module_ui <-
    dashboardPage(
        dashboardHeader(title = "Volley Stats",
                        tags$li (class="dropdown",
                                 get_frontend (infograph,alist ("player",icon = icon ("info"))),
                                 style="margin-left:-40%;margin-top:20%;"
                                 )
                        ),
                       dashboardSidebar(module_sidebar),

                       dashboardBody(
                                     tags$style(".nav  { padding:1%}"),
        module_body
        ),
        skin = "blue")
