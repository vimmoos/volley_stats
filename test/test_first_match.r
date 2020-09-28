library(tidyverse)
library(data.table)



get_csv <- function(path) read.csv(path) %>%
                              as_tibble %>%
                              mutate_if(is.character,as.factor)


check_row <- function(data)
    data[,!names(data) %in% c("Set")]  %>%
        apply(1,FUN=
                    function(row)
                        all(as.numeric(row) == 0 | is.na(as.numeric(row))))


m <-function(x) mean(x[!is.nan(x)])

s <- function(x) sd(x[!is.nan(x)])

se <- function(x) sd(x[!is.nan(x)])/sqrt(length(x[!is.nan(x)]))


filter_attacker <- function (data) filter(data,!Position %in% c("Libero","Setter"))

filter_passer <- function (data) filter(data,!Position %in% c("Middle_Blocker","Setter","Opposite"))

filter_server <- function (data) filter(data,!Position %in% c("Libero"))





position <- get_csv("~/volley_stats/data/position.csv")

data <- get_csv("~/volley_stats/data/first_match.csv") %>% left_join(position)

clean_data <- data[!check_row(data),]

sum_set <- clean_data%>%
    mutate(Set=1)%>%
    group_by(Player,Opponent,Position)%>%
    summarise_each(funs=function(x) ifelse(is.factor(x),x,sum(x))) %>%
    mutate(ServeR_tot = ServeR_P_Err + ServeR_P_P + ServeR_G_P + ServeR_E_P,
           Serve_tot = Serve_error + Serve_Ace + Serve_null)

add_prob <-  sum_set %>%
    group_by(Player,Opponent,Position) %>%
    summarise(set =Set
              att_k = Attack_kills/Attack_n,
              att_e = Attack_error/Attack_n,
              att_n = (Attack_n - (Attack_kills+Attack_error) ) /Attack_n,
              sr_er = ServeR_P_Err / ServeR_tot,
              sr_p = ServeR_P_P / ServeR_tot,
              sr_g = ServeR_G_P / ServeR_tot,
              sr_ex = ServeR_E_P / ServeR_tot,
              serve_k = Serve_Ace/Serve_tot,
              serve_e = Serve_error/Serve_tot,
              serve_n = Serve_null/Serve_tot)

mean_all <- add_prob[,!names(add_prob) %in% c("Opponent")] %>%
    group_by(Player,Position) %>%
    summarise_each(lst(m,s,se))

mean_team <- add_prob[,names(add_prob) %like%  "prob*"] %>%
    gather("metric","val") %>%
    group_by(metric) %>%
    summarise(se = se(val),
              val = m(val))

sum_ball <- sum(sum_set$Attack_n)

ball_distribution <- sum_set[,names(sum_set) %like%
                              "Attack_n|Position|Player"] %>%
    filter(!Position %in% c("Libero","Setter")) %>%
    group_by(Position,Player) %>%
    summarise(prob_ball = sum(Attack_n)/sum_ball)

ball_dist_pos <- ball_distribution %>%
    group_by(Position) %>%
    summarise(prob_ball = sum(prob_ball)



mean_position <- add_prob[,names(add_prob) %like% "prob*|Position"] %>%
    gather("metric","val",2:11) %>%
    group_by(Position,metric) %>%
    summarise(se = se(val),
              val = m(val))

ball_count <- ggplot(ball_distribution,aes(Player,prob_ball*100,fill=Player,label= round(prob_ball*100,digits = 2)))+
    geom_col() +
    geom_text(vjust = -.5)



position <- ggplot(filter(filter_attacker(mean_position),metric %like% c("*a|*sn|*sk|*se")),
                   aes(Position,val,fill=Position,group=metric))+
    geom_col()+
    geom_errorbar(aes(ymin=val - se,ymax=val + se,width=.4))+
    facet_grid(. ~ metric)

team <- ggplot(mean_team,aes(metric,val,fill=metric))+
    geom_col()+
    geom_errorbar(aes(ymin=val - se,ymax=val + se,width=.4))


attack_kills <- ggplot(filter_attacker(mean_all),
                       aes(Player,prob_ak_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_ak_m - prob_ak_se,ymax=prob_ak_m + prob_ak_se,width=.4))
## facet_grid(Opponent ~ . )

attack_error <- ggplot(filter_attacker(mean_all)
                      ,aes(Player,prob_ae_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_ae_m - prob_ae_se,ymax=prob_ae_m + prob_ae_se,width=.4))


serve_ace <- ggplot(filter_server(mean_all),
                    aes(Player,prob_sk_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_sk_m - prob_sk_se,ymax=prob_sk_m + prob_sk_se,width=.4))


serve_error <- ggplot(filter_server(mean_all),
                      aes(Player,prob_se_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_se_m - prob_se_se,ymax=prob_se_m + prob_se_se,width=.4))


serve_null <- ggplot(filter_server(mean_all),
                     aes(Player,prob_sn_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_sn_m - prob_sn_se,ymax=prob_sn_m + prob_sn_se,width=.4))


receive_error <- ggplot(filter_passer(mean_all),
                        aes(Player,prob_srer_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_srer_m - prob_srer_se,ymax=prob_srer_m + prob_srer_se,width=.4))


receive_playable <- ggplot(filter_passer(mean_all),
                           aes(Player,prob_srp_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_srp_m - prob_srp_se,ymax=prob_srp_m + prob_srp_se,width=.4))


receive_good <- ggplot(filter_passer(mean_all),
                       aes(Player,prob_srg_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_srg_m - prob_srg_se,ymax=prob_srg_m + prob_srg_se,width=.4))


receive_excelent <- ggplot(filter_passer(mean_all),
                           aes(Player,prob_srex_m,fill=Player))+
    geom_col()+
    geom_errorbar(aes(ymin=prob_srex_m - prob_srex_se,ymax=prob_srex_m + prob_srex_se,width=.4))


pippo <- prob %>%
    filter(Player == "Dusan" & metric != "set" & metric %like% "att") %>%
    ggplot(aes(x=metric,y=val,fill=metric))+
    geom_violin()

pdf("test_plots.pdf")
print(ball_count)
print(team)
print(position)
print(attack_kills)
print(attack_error)
print(serve_ace)
print(serve_error)
print(serve_null)
print(receive_error)
print(receive_playable)
print(receive_good)
print(receive_excelent)
dev.off()
