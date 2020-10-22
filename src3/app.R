
run <- function()
{
    library(shiny)
    library(shinydashboard)
    library(shinycssloaders)
    source("./ui.r")
    source("./server.r")
    options(browser = "/usr/bin/firefox") ## set firefox as browser
    shinyApp(module_ui,module_server)

}

runApp(list(ui = module_ui, server = module_server),launch.browser = TRUE,
           host = getOption("shiny.host","192.168.1.109"))
run_login <- function(wifi=FALSE)
{

                                        # Init DB using credentials data
    credentials <- data.frame(
        user = c("shiny", "shinymanager"),
        password = c("azerty", "12345"),
                                        # password will automatically be hashed
        admin = c(FALSE, TRUE),
        stringsAsFactors = FALSE
    )
    library(shiny)
    library(shinydashboard)
    library(shinymanager)
    source("./ui.r")
    source("./server.r")
    options(browser = "/usr/bin/firefox") ## set firefox as browser


                                        # Init the database
    create_db(
        credentials_data = credentials,
        sqlite_path = "/home/vimmoos/volley_stats/database_test.sqlite", # will
                                                                         # be
                                                                         # created
        passphrase = "passphrase_wihtout_keyring"
    )

                                        # Wrap your UI with secure_app, enabled admin mode or not
    ui <- secure_app(module_ui, enable_admin = TRUE)


    server <- function(input, output, session)
    {

                                        # check_credentials directly on sqlite db
        res_auth <- secure_server(
            check_credentials = check_credentials(
                "/home/vimmoos/volley_stats/database_test.sqlite",
                passphrase = "passphrase_wihtout_keyring"
            )
        )

        output$auth_output <- renderPrint({
            reactiveValuesToList(res_auth)
        })

                                        # your classic server logic
        module_server(input,output,session)
    }

    if (wifi)
        runApp(list(ui = ui, server = server),launch.browser = TRUE,
               host = getOption("shiny.host","192.168.1.109"))
    else  shinyApp(ui, server)
}
