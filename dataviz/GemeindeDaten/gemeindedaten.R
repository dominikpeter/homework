
rm(list=ls())

# data.table version
# -----------------------------------------------------
library(data.table)
library(magrittr)

path <- "dataviz/GemeindeDaten/gemeindedaten.csv"

start <- Sys.time()
df <- fread(path)

df %>% setkey(sprachregionen)
df[, rank := frank(-bev_total, ties.method = "dense"), by = key(df)]
df[rank == 1, .(bfsid, gmdename,
                kantone, grossregionen,
                sprachregionen, stadt_land)]

end <- Sys.time()
time <- (end - start)[[1]] %>% as.numeric

# dplyr version
# -----------------------------------------------------

library(tidyverse)

start <- Sys.time()

df <- read_csv(path)

df <- df %>% 
  group_by(sprachregionen) %>% 
  mutate(rank = dense_rank(-bev_total)) %>% 
  filter(rank == 1) %>% 
  select(bfsid, gmdename,kantone, grossregionen,sprachregionen, stadt_land)

end <- Sys.time()

time_2 <- (end - start) %>% .[[1]] %>%  as.numeric


