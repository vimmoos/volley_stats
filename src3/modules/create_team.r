library(shiny)
library(shinydashboard)
source ("./modules/selector.r")
source ("./modules/utils.r")
source ("./modules/db_driver.r")

f_create_team <- function(id,accept)
{
    box(
        id = id,
        width = 4,
        title =  tags$p ("Create Team",style= "font-size: 300%;"),
        status = "success",
        solidHeader =  TRUE,
        collapsible =  TRUE,
        useSweetAlert ("dark"),
        selectizeInput (paste0 ("association",id),choices = NULL,
                        selected =NULL,
                        label = "Select/create the Association",
                        options = list (create = TRUE,
                                        allowEmptyOption = FALSE,
                                        placeholder = "Type an Association",
                                        preload = TRUE,
                                        createFilter = "[a-z]+")),

        radioButtons (paste0 ("gender",id),
                      label =  "Gender",
                      choices = list ("Female" = 0,"Male" = 1)),

        textInput(paste0 ("name_t",id),
                  label = "insert the name of the team"),

        actionButton (paste0 ("create_team",id),
                      label = "Create Team",
                      icon = icon ("upload"))

    )
}
b_create_team <- function(input,output,session,id)
{

    observe_confirmation (session, input [[paste0 ("create_team",id)]],
                          is.null (input [[paste0 ("association",id)]]) |
                          is.null (input [[paste0 ("name_t",id)]]) |
                          is.null (input [[paste0 ("gender",id)]]),
                          paste0 ("confirm_d",id), "Are you sure to upload?",
                          tags$ul(tags$li (paste ("Team:",input [[paste0 (
                                                                     "name_t",
                                                                     id)]])),
                                  tags$li (paste ("Gender:",
                                                  if (input [[paste0 ("gender",id)]] == 0)
                                                      "Female" else "Male")),
                                  tags$li (paste ("Association:",
                                                  input [[paste0 ("association",
                                                                  id)]]))))

}

module_create_team <- function (borf) if (borf) b_create_team else f_create_team
