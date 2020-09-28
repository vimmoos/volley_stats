FROM archlinux

LABEL maintainer "vimmoos"

RUN pacman -Syyu --noconfirm devtools make cmake gcc r gsfonts

RUN R -e "install.packages(c('shiny','tidyverse','shinydashboard'),repos='https://cloud.r-project.org/')"

RUN R -e "install.packages(c('data.table'),type = 'source', repos='https://Rdatatable.gitlab.io/data.table')"

RUN mkdir /root/volley

COPY src3 /root/volley

RUN mkdir /root/data

COPY data /root/data

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R","-e","shiny::runApp('/root/volley',port = 3838,host = '0.0.0.0')"]
