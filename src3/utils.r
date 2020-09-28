library (gtools)

bind_reactive <- defmacro(data_symb,at,body,expr= data_symb[[at]] <- reactive(body))


bind_filter <- defmacro(data_symb,at,data,column,regexp,
                        expr =  bind_reactive (data_symb,at,{
                            data %>%
                                filter (column %like% regexp)}))

binds_filter <- defmacro (data_symb,data,column,tuples,
                          expr = eval (bquote (
                          {data_symb <- reactiveValues ()
                              .. (map (tuples,function (x)
                                              bquote (bind_filter (data_symb,. (x [1]),data,column,. (x [2])))))

                          },splice=TRUE))
                          )
