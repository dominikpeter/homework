# ------------------------------------------------------------------------------------------------
# Title:  Webscraping and Tidying
# Autor:  Dominik Peter
# Date:   2016-12-04
# ------------------------------------------------------------------------------------------------

rm(list=ls())

library(data.table)
library(magrittr)
library(stringr)
library(ggplot2) 
library(rvest)

# Daten von Wikipedia extrahieren
# ------------------------------------------------------------------------------------------------

url <- 'https://de.wikipedia.org/wiki/Bern'

df <- url %>%
  read_html(.) %>%
  html_table(fill = TRUE, header = TRUE) %>% 
  .[[6]] %>% 
  na.omit(.) %>% 
  as.data.table(.) %>% 
  .[, 1:13, with = FALSE]

setnames(df, 1, "typ")

# Table bereinigen
# ------------------------------------------------------------------------------------------------
# convert value to numeric and eliminate NA columns
to_numeric <- function(x) {
  x <- str_replace_all(x, ",", "\\.")
  as.numeric(x)
}
months <- colnames(df)[-1]
# apply function
df[, months] <- lapply(df[, months, with = FALSE], to_numeric)


# tidy df
# ------------------------------------------------------------------------------------------------
tidy_df <- df[1:3] %>%
  melt(id.vars = "typ", variable.name = "Monat") %>% 
  dcast(Monat ~ typ)

col_names <- colnames(tidy_df)
setnames(tidy_df, col_names, c(col_names[1], c("Max", "Min", "Mittelwert")))

pander::pander(tidy_df)

# plotting 
# ------------------------------------------------------------------------------------------------
mean_temp <- mean(tidy_df$Mittelwert)
min <- scales::comma(tidy_df$Min)
max <- scales::comma(tidy_df$Max)

tidy_df  %>% 
  ggplot(aes(x = Monat, y = Mittelwert)) +
  geom_point(size = 1.5, color = "#444B54") +
  geom_hline(yintercept = mean_temp, color = "#2980B9", size = 1.5, alpha = 0.2, linetype = 2) +
  geom_errorbar(aes(ymin = Min, ymax = Max), width = .2, color = "#444B54", size = 5) +
  ylab("\nTemperatur (°C)") +
  xlab("\nMonat") +
  geom_text(aes(y=Min), label = min, vjust = 1.9) +
  geom_text(aes(y=Max), label = max, vjust = -1.1) +
  ylim(-8, 30) +
  ggtitle("Monatliche Durchschnittstemperaturen", subtitle = "für Bern 1981 – 2010") +
  theme(panel.background = element_blank(),
        # panel.grid.major = element_line(color = "#F0F1F5", size = 0.2),
        panel.grid.minor = element_blank()
        )


?pander

