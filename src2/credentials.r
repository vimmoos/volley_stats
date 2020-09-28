

## * TODO
## make a struct to add users

users_id <- c("myuser", "myuser1","gna")

passod <- c("mypass", "mypass1","gna")

permission <- c("basic", "basic","advanced")




credentials = data.frame(
    username_id = users_id,
    passod   = sapply(passod,password_store),
    permission  = permission,
    stringsAsFactors = F
)
