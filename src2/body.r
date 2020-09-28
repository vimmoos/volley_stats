## * TODO
## ** add different body for the different type of access

body_page <-
    tabItems (
        tabItem (tabName = "collect",
                 h2 ("Do the collection part gne!"),
                 box (title = "Collector",
                      actionButton ("plus","dio"),
                      actionButton ("minus","porco"))),
        tabItem (tabName = "pstats",
                 h2 ("Player stats"),
                 box (title = "moc plot",
                      plotOutput ("mtcars",height = 250))),
        tabItem (tabName = "tstats",
                 h2 ("Team stats"),
                 box (title = "moc plot",
                      plotOutput ("mtcars",height = 250))))


body_page_basic <-
    tabItem (tabName = "stats",
             h2 ("Statistics and plots"),
             box (title = "moc plot",
                  plotOutput ("mtcars",height = 250)))


## body_page_advanced <-




## tabItem(tabName ="dashboard", class = "active",
##         fluidRow(
##             box(width = 12, dataTableOutput('results'))
##         ))
