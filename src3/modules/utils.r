library (gtools)

perc_se <- function (data,regexp,debug=FALSE)
{
    if (debug) {print (data)
        print (regexp)}
    tmp <-filter (data, metric %like% regexp)
    paste0 (round (tmp$m*100),"% ± ",
            round (tmp$se *100,digits = 0))
}

isnull <- function (...)
    is.null (reduce (list (...),function (acc,x) is.null (acc) | is.null (x)))


get_in <- defmacro(string,expr = input[[paste0(string,id)]])

bind_output <-
    defmacro (
        data,name,
        expr=
            output [[paste0 (name,id)]] <- renderUI(
                perc_se (data ,name)))

bind_outputs <-
    defmacro (
        data,names,
        expr= eval (bquote (
        {..(map (names,function (x)
            bquote (bind_output (data,. (x)))))
        },splice=TRUE)))



plot_mean <-
    defmacro(
        data,x,y,y_se,levels=c ("att_e","att_n",
                                "att_k"),
        fill=c ("#dd4b39", "#00a65a","#f39c12"),
        expr = ggplot (data,aes(factor (x,levels=levels),y,fill=x)) +
            geom_col()+
            geom_errorbar(aes(ymin = y - y_se ,ymax = y + y_se,width=.2))+
            scale_fill_manual (values=fill)+
            theme (legend.position="none")+
            xlab ("Event") +
            ylab ("Probability"))

plot_dist <-
    defmacro(
        data,x,y,levels=c ("att_e","att_n",
                           "att_k"),
        fill=c ("#dd4b39", "#00a65a","#f39c12"),
        expr =  ggplot(data,aes(factor (x,levels=levels),y,fill=x))+
            geom_violin()+
            scale_fill_manual (values=fill)+
            theme (legend.position="none")+
            xlab ("Event") +
            ylab ("Probability"))


observe_confirmation <-
    defmacro (
        session,what,bool_err,
        conf_id,conf_title,conf_text,
        body,
        title_err="Error missing values",
        text_err="Please insert all needed values!",
        html=TRUE,
        expr = {
            observeEvent (what,
                          if (bool_err)
                              sendSweetAlert (session,
                                              title = title_err,
                                              text = text_err,
                                              type = "error")
                          else ask_confirmation (
                                   inputId = paste0 (conf_id,id),
                                   title = conf_title,
                                   text= conf_text,
                                   html=html))
            observeEvent (get_in (conf_id),
                          if (get_in (conf_id))
                              body)})
upload_confirmation <-
    defmacro (
        session,what,bool_err,
        conf_id,conf_title,conf_text,
        body,
        title_err="Error missing values",
        text_err="Please insert all needed values!",
        html=TRUE,
        expr = observe_confirmation (
            session = session,
            what = what,
            bool_er= bool_err,
            conf_id = conf_id,
            conf_title = conf_title,
            conf_text = conf_text,
            title_err = title_err,
            text_err =text_err,
            body = {
                res <- tryCatch (
                    with_db (body),
                    error = function (e){
                        sendSweetAlert (session,
                                        title= "Upload Error",
                                        text = tags$p (paste ("Please contact the admin",
                                                              "ERROR:",
                                                              e,
                                                              sep="\n")),
                                        type = "error")
                        return (FALSE)})
                if (res)
                    showNotification (
                        "Uploaded successfully",
                        type="message")}))


module_frontend <-
    defmacro (
        name,args=alist (),title,status,width,body,
        expr =
            do.call("<-",
                    list(paste0("f_",quote (name)),
                         eval (call (
                             "function",
                             as.pairlist (append (alist(id=),args)),
                             quote (
                                 do.call (
                                     "box",append (
                                               list (id = id,
                                                     width = width,
                                                     title = tags$p (title,style = "font-size:300%;"),
                                                     status = status,
                                                     solidHeader =TRUE,
                                                     collapsible = TRUE,
                                                     useSweetAlert ("dark")),
                                               body)))),
                             parent.frame ()))))



module_backend <-
    defmacro (
        name,args=alist (),body,
        expr =
            do.call("<-",
                    list(paste0("b_",quote (name)),
                         eval (call (
                             "function",
                             as.pairlist (append (args,alist(input=,output=,session=,id=))),
                             quote ({body})),
                             parent.frame ()))))

get_frontend <-
    defmacro (
        name,args,
        expr = do.call (paste0 ("f_",quote (name)),args))

get_backend <-
    defmacro (
        name,args,
        expr = do.call (paste0 ("b_",quote (name)),args))

front_selector <-
    defmacro (
        name,
        title,
        create = FALSE,
        allowEmptyOption = FALSE,
        preload = TRUE,
        createFilter = "[a-z]+",
        expr = selectizeInput (paste0 (name,id),
                               choices = NULL, selected =NULL,
                               label = title,
                               options = list (create = create,
                                               allowEmptyOption = allowEmptyOption,
                                               preload = preload,
                                               createFilter = createFilter)))
back_selector <-
    defmacro (
        name,
        choices,
        selected = NULL,
        expr =  updateSelectizeInput (session,paste0 (name,id),
                              selected =selected,
                              choices = choices,
                              server=TRUE))
