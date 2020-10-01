library (gtools)

perc_se <- function (data,regexp,debug=FALSE)
{
    if (debug) {print (data)
        print (regexp)}
    tmp <-filter (data, metric %like% regexp)
    paste0 (round (tmp$m*100),"% ± ",
            round (tmp$se *100,digits = 0))
}


bind_output <- defmacro (data,name,
                   expr=
                       output [[paste0 (name,id)]] <- renderUI(
                           perc_se (data ,name)))

bind_outputs <- defmacro (data,names,
                          expr= eval (bquote (
                              {..(map (names,function (x)
                                  bquote (bind_output (data,. (x)))))
                              },splice=TRUE)))



plot_mean <- defmacro(data,x,y,y_se,levels=c ("att_e","att_n",
                                                      "att_k"),
                              fill=c ("#dd4b39", "#00a65a","#f39c12"),
                              expr = ggplot (data,aes(factor (x,levels=levels),y,fill=x)) +
                                  geom_col()+
                                  geom_errorbar(aes(ymin = y - y_se ,ymax = y + y_se,width=.2))+
                                  scale_fill_manual (values=fill)+
                                  theme (legend.position="none")+
                                  xlab ("Event") +
                                  ylab ("Probability"))

plot_dist <- defmacro(data,x,y,levels=c ("att_e","att_n",
                                                      "att_k"),
                      fill=c ("#dd4b39", "#00a65a","#f39c12"),
                      expr =  ggplot(data,aes(factor (x,levels=levels),y,fill=x))+
                          geom_violin()+
                          scale_fill_manual (values=fill)+
                          theme (legend.position="none")+
                          xlab ("Event") +
                          ylab ("Probability"))


observe_confirmation <- defmacro (session,what,bool_err,
                                          conf_id,conf_title,conf_text,
                                          title_err="Error missing values",
                                          text_err="Please insert all needed values!",
                                  html=TRUE,
                                  expr = observeEvent (what,
                                                       if (bool_err)
                                                           sendSweetAlert (session,
                                                                           title = title_err,
                                                                           text = text_err,
                                                                           type = "error")
                                                       else ask_confirmation (
                                                                inputId = conf_id,
                                                                title = conf_title,
                                                                text= conf_text,
                                                                html=html)))
