library(shiny)
library(shinydashboard)
source ("./modules/utils.r")



module_frontend(
    name = selector,
    args = alist(title = ,
                 create = FALSE,
                 allowEmptyOption = FALSE,
                 preload = TRUE,
                 createFilter = " [a-z]+"),
    body =
        selectizeInput (ID (selector),
                        choices = NULL, selected =NULL,
                        label = title,
                        options = list (create = create,
                                        allowEmptyOption = allowEmptyOption,
                                        preload = preload,
                                        createFilter = createFilter)))

module_backend (
    name = selector,
    args = alist (choices = ,
                  reactive = FALSE,
                  selected = NULL),
    body ={
        observe ({
            cs <- if (reactive) choices () else choices
            updateSelectizeInput (session,ID (selector),
                                          selected =if (is.null (selected)) first (cs) else selected,
                                          choices = cs,
                                          server=TRUE)})

        reactive (get_in (selector))})
