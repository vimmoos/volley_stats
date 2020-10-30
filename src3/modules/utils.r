
perc_se <- function(data, filt) {
  ## > > microbenchmark(filter(test,metric == "sr_er"),test[test$metric == "sr_er",],times = 10000)
  ## Unit: microseconds
  ##                             expr     min      lq     mean   median       uq
  ##  filter(test, metric == "sr_er") 605.736 618.390 661.0257 623.3995 636.3635
  ##   test[test$metric == "sr_er", ]  48.672  52.909  60.4047  60.0730  62.6870
  ##         max neval
  ##  139747.426 10000
  ##    3309.888 10000
  tmp <- data [data$metric == filt, ]
  paste0(
    round(tmp$val * 100), "% ±",
    round(tmp$se * 100))
}





isnull <- function(...) {
  is.null(reduce(list(...), function(acc, x) is.null(acc) | is.null(x)))
}


macro_defn <-
  defmacro(name, alist, body,
    expr = do.call(
      "<-",
      list(
        name,
        eval(
          call(
            "function", as.pairlist(alist),
            quote(body)),
          parent.frame()))))

ID <- defmacro(symb, expr = paste0(quote(symb), id))

get_in <- defmacro(symb, expr = input[[ID(symb)]])

bind_output <-
  defmacro(
    name, body,
    expr = output [[ID(name)]] <- body)




plot_mean <-
  defmacro(
    data, x, y, y_se,
    levels = ATT_LEVELS,
    expr = ggplot(data, aes(factor(x, levels = levels), y, fill = x)) +
      ## theme_dark ()+
      geom_col() +
      scale_x_discrete(labels = LABELLER) +
      geom_errorbar(aes(ymin = y - y_se, ymax = y + y_se, width = .2)) +
      scale_fill_manual(values = COLORS) +
      theme(legend.position = "none") +
      xlab("Event") +
      ylab("Probability"))

plot_dist <-
  defmacro(
    data, x, y,
    levels = ATT_LEVELS,
    expr = ggplot(data, aes(factor(x, levels = levels), y, fill = x)) +
      ## theme_dark ()+
      geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
      stat_summary(
        fun = median, geom = "point", shape = 20, size = 7,
        color = "black", fill = "black") +
      geom_point(alpha = .5) +
      scale_fill_manual(values = COLORS) +
      scale_x_discrete(labels = LABELLER) +
      theme(legend.position = "none") +
      xlab("Event") +
      ylab("Probability"))


observe_confirmation <-
  defmacro(
    session, what, req_objs, bool_err,
    conf_id, conf_title, conf_text,
    body,
    title_err = "Error missing values",
    text_err = "Please insert all needed values!",
    html = TRUE,
    expr = {
      observeEvent(what, {
        do.call(req, req_objs)
        if (bool_err) {
          sendSweetAlert(session,
            title = title_err,
            text = text_err,
            type = "error")
        } else {
          ask_confirmation(
            inputId = ID(conf_id),
            title = conf_title,
            text = conf_text,
            html = html)
        }})
      observeEvent(get_in(conf_id), {
        do.call(req, append(req_objs, get_in(conf_id)))
        if (get_in(conf_id)) {
          body
        }})})
upload_confirmation <-
  defmacro(
    session, what, req_objs, bool_err,
    conf_id, conf_title, conf_text,
    body,
    title_err = "Error missing values",
    text_err = "Please insert all needed values!",
    html = TRUE,
    expr = observe_confirmation(
      session = session,
      what = what,
      req_objs = req_objs,
      bool_er = bool_err,
      conf_id = conf_id,
      conf_title = conf_title,
      conf_text = conf_text,
      title_err = title_err,
      text_err = text_err,
      body = {
        res <- tryCatch(
          with_db(body),
          error = function(e) {
            sendSweetAlert(session,
              title = "Upload Error",
              text = tags$p(paste("Please contact the admin",
                "ERROR:",
                safeError(e),
                sep = "\n")),
              type = "error")
            return(FALSE)})
        if (res) {
          showNotification(
            "Uploaded successfully",
            type = "message")
        }}))

module_frontend <-
  defmacro(
    name,
    args = alist(), body,
    expr =
      macro_defn(
        paste0("f_", quote(name)),
        append(alist(id = ), args),
        body))


module_frontend_box <-
  defmacro(
    name, title, status, body,
    width = 6, args = alist(),
    solidHeader = TRUE, collapsible = TRUE,
    expr =
      module_frontend(
        name, args,
        do.call(
          "box", append(
            list(
              id = id,
              width = width,
              title = tags$p(title, style = "font-size:300%;"),
              status = status,
              solidHeader = solidHeader,
              collapsible = collapsible,
              useSweetAlert("dark")),
            body))
    ))



module_backend <-
  defmacro(
    name,
    args = alist(), body,
    expr =
      macro_defn(
        paste0("b_", quote(name)),
        append(alist(input = , output = , session = , id = ), args),
        body))

get_frontend <-
  defmacro(
    name, args,
    expr = do.call(paste0("f_", quote(name)), args))

get_backend <-
  defmacro(
    name, args,
    expr = do.call(paste0("b_", quote(name)), append(alist(
      input = input,
      output = output,
      session = session), args)))
