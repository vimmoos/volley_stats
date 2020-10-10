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
        front_selector (
            name = selector,
            title = title,
            create = FALSE,
            allowEmptyOption = allowEmptyOption,
            preload = preload,
            createFilter = createFilter))

module_backend (
    name = selector,
    args = alist (choices = ,
                  selected = NULL),
    body ={
        observe (back_selector (
            name = selector,
            choices  = choices (),
            selected = if (is.null (selected)) first (choices ())else selected))
        reactive (get_in (selector))})
