FROM archlinux

# ARG DB_HOST
# ARG DB_USER
# ARG DB_PASSWORD
# ARG DB_NAME

# ENV DB_HOST $DB_HOST
# ENV DB_USER $DB_USER
# ENV DB_PASSWORD $DB_PASSWORD
# ENV DB_NAME $DB_NAME

LABEL maintainer "vimmoos"

RUN pacman -Syyu --noconfirm devtools make cmake gcc r gsfonts pkgconf mariadb

RUN R -e "install.packages(c('shiny','tidyverse','shinydashboard','shinymanager','shinyWidgets','gtools','shinycssloaders','RMariaDB','DBI'),repos='https://cloud.r-project.org/')"

RUN R -e "install.packages(c('data.table'),type = 'source', repos='https://Rdatatable.gitlab.io/data.table')"

RUN mkdir /root/volley

COPY src /root/volley

RUN mkdir /root/data

COPY data /root/data

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 8080


CMD bash -c "cd /root/volley && R -e 'source(\"./app.R\")'"

# CMD ls

# CMD ["cd","/root/volley","&&","R","-e","source('./app.R')"]

# RUN ls

# CMD ["R","-e","source('./app.R')"]

# CMD ["R","-e","shiny::runApp('/root/volley',port = 3838,host = '0.0.0.0')"]
# CMD ["R","-e","library(tidyverse)"]
