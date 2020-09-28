side_bar <-
    sidebarMenu (id = "tabs",
                 menuItem ("Collect Stats",tabName = "collect", icon = icon ("volleyball-ball")),
                 menuItem ("Player Stats",tabName = "pstats", icon = icon ("chart-bar")),
                 menuItem ("Team Stats",tabName = "tstats", icon = icon ("chart-bar")))
