

source("./global.R")

##                                     # Init DB using credentials data
credentials <- data.frame(
    user = c("shiny", "shinymanager"),
    password = c("azerty", "12345"),
                                    # password will automatically be hashed
    admin = c(FALSE, TRUE),
    stringsAsFactors = FALSE
)


##                                     # Init the database
create_db(
    credentials_data = credentials,
    sqlite_path = "./database_test.sqlite", # will
                                                                     # be
                                                                     # created
    passphrase = "passphrase_wihtout_keyring"
)

run_login <- function(wifi = FALSE,init_fake = TRUE)
{
  source("./global.R")
  if (init_fake){
    startup()
    tables_ <- length(dbGetQuery(R_CON_DB,"show tables;")[['Tables_in_"volley"']])
    if(tables_ < 2){
      source("./init.r")
    }
  } else {
    create_all_table()
    create_all_views()
  }

  # Wrap your UI with secure_app, enabled admin mode or not
  ui <- secure_app(module_ui, enable_admin = TRUE)


  server <- function(input, output, session) {

    # check_credentials directly on sqlite db
    res_auth <- secure_server(
      check_credentials = check_credentials(
        "./database_test.sqlite",
        passphrase = "passphrase_wihtout_keyring"))

    module_server(input, output, session, res_auth)}

  if (wifi) {
    runApp(list(ui = ui, server = server),
           launch.browser = TRUE,
           port = getOption ("shiny.port",8080),
           host = getOption("shiny.host", "0.0.0.0"))
  } else {
    shinyApp(ui, server)
  }}



run_login(TRUE)
