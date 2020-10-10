library(shiny)
library(shinydashboard)
source ("./modules/selector.r")
source ("./modules/utils.r")
source ("./modules/db_driver.r")

module_frontend_box (
                 create_team,
                 title = "Create Team",
                 status = "success",
                 width = 4,
                 body=list (
                            front_selector ("association","Select/create the Association",
                                            create=TRUE),

                            radioButtons (paste0 ("gender",id),
                                                 label =  "Gender",
                                                 choices = list ("Female" = 0,"Male" = 1)),

                            textInput(paste0 ("name_t",id),
                                             label = "insert the name of the team",
                                             value = NULL,
                                             placeholder = "H1"),

                            actionButton (paste0 ("create_team",id),
                                                 label = "Create Team",
                                                 icon = icon ("upload"))))

module_backend (
    create_team,
    body ={
        observe(back_selector ("association",
                               with_db (get_all_associations ())))

        upload_confirmation (
            session,
            what = get_in ("create_team") ,
            bool_err =
                isnull (get_in ("association"),get_in ("name_t"),
                        get_in ("gender")) |
                get_in ("name_t") == "",
            conf_id = "confirm_team",
            conf_title = "Are you sure to upload?",
            conf_text =tags$ul(tags$li (paste ("Team:",get_in ("name_t"))),
                               tags$li (paste ("Gender:",
                                               if (get_in ("gender") == 0)
                                                   "Female" else "Male")),
                               tags$li (paste ("Association:", get_in (
                                                                   "association")))),
            body = add_team (name = get_in ("name_t"),
                             gender = get_in ("gender"),
                             association = get_in ("association")))})
