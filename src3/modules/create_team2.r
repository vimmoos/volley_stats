
f_create_team <- function(id,accept)
{
    box(
        id = id,
        title =  tags$p ("Create Team",style= "font-size: 300%;"),
        status = "success",
        solidHeader =  TRUE,
        collapsible =  TRUE,
        useSweetAlert ("dark"),
        textInput(paste0 ("team",id),
                  label = "insert the name of the team"),
        fluidRow (column (fileInput(paste0("position_f",id),
                                    "Choose the csv file of team name and position",
                                    width = "60%", multiple = FALSE, accept = accept),width=8),
                  column (downloadButton (paste0 ("template_p",id),
                                          "Download Template"),
                          tags$p ("Please use the same position that are in the template,if there are typos the file will be rejected",
                                  style="color: #dd4b39;")
                         ,width=4)),
        dataTableOutput (paste0 ("contents",id)),
        actionButton (paste0 ("upload_l",id),
                      label = "Upload locally",
                      icon = icon ("upload")),
        actionButton (paste0 ("upload_d",id),
                      label = "Upload in database",
                      icon = icon ("globe"))


    )
}
b_create_team <- function(input,output,session,id)
{

    observe_confirmation (session, input [[paste0 ("upload_d",id)]],
                          is.null (input [[paste0 ("team",id)]]) |
                          is.null (input [[paste0 ("position_f",id)]]),
                          paste0 ("confirm_d",id), "Are you sure to upload?",
                          tags$ul(tags$li (paste ("Team:",input [[paste0 (
                                                                     "team",
                                                                     id)]])),
                                  tags$li (paste ("Position:",
                                                  input [[paste0 ("position_f",id)]]$name))))

    observe_confirmation (session, input [[paste0 ("upload_l",id)]],
                          is.null (input [[paste0 ("team",id)]]) |
                          is.null (input [[paste0 ("position_f",id)]]),
                          paste0 ("confirm_l",id), "Are you sure to upload?",
                          tags$ul(tags$li (paste ("Team:",input [[paste0 (
                                                                     "team",
                                                                     id)]])),
                                  tags$li (paste ("Position:",
                                                  input [[paste0 ("position_f",id)]]$name))))


    positions <- reactive ({
        req(input [[paste0 ("position_f",id) ]])
        tryCatch(read.csv(input [[paste0 ("position_f",id)]]$datapath),
                 error = function(e)
                     stop(safeError(e)))})

    observeEvent (input [[paste0 ("confirm_d",id)]],
                  if (input [[paste0 ("confirm_d",id)]])
                      with_db ({add <- cadd_position (positions ())
                          if (add$bool) {
                              add$fun (n_team=input [[paste0 ("team",id)]])
                              showNotification (
                                  paste (input [[paste0 ("position_f",id)]]$name,
                                         "Uploaded successfully"),
                                  type="message")}
                          else sendSweetAlert (
                                   session,title= "File format Error",
                                   text = "There are probably typos, Please check the template!",
                                   type = "error")}))


    output [[paste0 ("template_p",id)]] <-
        downloadHandler (filename = function () "template_position.csv",
                         content = function (file)
                             write.csv (position_template,file,row.names=FALSE))

    output [[paste0 ("contents",id)]] <-
        renderDataTable(positions (),
            options = c (scrollX = "true", scrollY= "true",
                         scrollCollapse = "true",editable = "true"))
}

module_create_team <- function (borf) if (borf) b_create_team else f_create_team
