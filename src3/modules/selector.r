library(shiny)
library(shinydashboard)

f_selector <- function(id)
{
    uiOutput(paste0("selection",id))
}

b_selector <- function(input,output,session,filter_group,data,title,id,filter=TRUE)
{
    options <- reactive(levels(unique(data()[[paste0(filter_group,"")]])))
    default_val <- reactive(sample (options(),1))
    observe(print(data()))

    output [[paste0 ("selection",id)]] <- renderUI(
        selectInput(paste0 ("selector",id),title,
                    selected = default_val() ,
                    choices =  options()))
    reactive ({
        id <- paste0 ("selector",id)
        selected <- ifelse (!is.null (input [[id]]),
                            input [[id]],
                            default_val())
        if (filter)
           list (selected = selected,
               data = data() %>%
                   filter(eval(filter_group) == selected) %>%
                   group_by (eval (filter_group)))
        else list(selected=selected,data=data())
    })




}

module_selector <- function (borf) if (borf) b_selector else f_selector
