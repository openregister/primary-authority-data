library(tidyverse)
library(rvest)
library(here)

# Hardcoded to the number of pages that I checked existed in the browser
urls <- paste0("https://primary-authority.beis.gov.uk/par?keywords=&page=", 0:125)

x <- read_html("https://primary-authority.beis.gov.uk/par?keywords=&page=1")

read_page <- function(url) {
  cat("Reading ", url, "\n")
  read_html(url) %>%
    html_table %>%
    .[[1]]
}

all_pages <- map_df(urls, read_page)

all_primary_authorities <- 
  all_pages %>%
  mutate(`Regulatory Functions` = map(`Regulatory Functions`, ~ str_split(.x, "\n[\n, ]*"))[[1]])

all_primary_authorities %>%
  mutate(`Regulatory Functions` = map_chr(`Regulatory Functions`, paste, collapse = ";")) %>%
  write_tsv(here("lists", "beis.tsv"))

all_primary_authorities %>%
  select(`Regulatory Functions`) %>%
  unnest() %>%
  distinct() %>%
  arrange(`Regulatory Functions`) %>%
  write_tsv(here("lists", "beis-regulatory-functions.tsv"))
