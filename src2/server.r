source("./body.r")
source ("./sidebar.r")

server <- function(input, output, session)
{

    login = FALSE
    USER <- reactiveValues(login = login)

    observe({
        if (USER$login == FALSE) {
            if (!is.null(input$login)) {
                if (input$login > 0) {
                    Username <- isolate(input$userName)
                    Password <- isolate(input$passwd)
                    if(length(which(credentials$username_id==Username))==1) {
                        pasmatch  <- credentials["passod"][which(credentials$username_id==Username),]
                        pasverify <- password_verify(pasmatch, Password)
                        if(pasverify) {
                            USER$login <- TRUE
                        } else {
                            shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
                            shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
                        }
                    } else {
                        shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
                        shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
                    }
                }
            }
        } else {
            updateTabItems(session,"tabs","collect")
        }
    })

    output$logoutbtn <- renderUI({
        req(USER$login)
        tags$li(a(icon("fa fa-sign-out"), "Logout",
                  href="javascript:window.location.reload(true)"),
                class = "dropdown",
                style = "background-color: #eee !important; border: 0;
                    font-weight: bold; margin:5px; padding: 10px;")
    })

    ## SIDEBAR
    output$sidebarpanel <-
        renderUI({
            if (USER$login == TRUE ){
                side_bar
            }
        })

    ## BODY
    output$body <- renderUI({
        if (USER$login == TRUE ) {
            body_page
        } else {
            loginpage
        }
    })

    ## moc example
    output$mtcars <- renderPlot(plot (mtcars$gear))

    ## output$results <-  DT::renderDataTable({
    ##     datatable(iris, options = list(autoWidth = TRUE,
    ##                                    searching = FALSE))
    ## })


}
