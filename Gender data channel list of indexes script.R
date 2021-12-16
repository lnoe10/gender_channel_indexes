library(tidyverse)
setwd("C:/Users/lnoe/Documents/R")

# About ####
# Script to collect four relevant indexes for assessing gender-relevant statistical capacity

# 1. OECD Social Institutions and Gender Index ####
# Latest year is 2019
# Background https://www.genderindex.org/
# Data from https://stats.oecd.org/Index.aspx?DataSetCode=SIGI2019
# Overall SIGI value transformed to rank equivalence (Best value, i.e. lowest, will have rank 120, or whatever max number of countries is)
# Then ranks transformed to percent rank, so best value will be 100, worst will be 0.
sigi <- readxl::read_excel("Data/Input Data/Indexes.xlsx", sheet = "SIGI2019") %>%
  select(iso3c = LOCATION, country = Country, sigi_pct_rank = `Percent rank`)

#2. Women, Business and the Law ####
# Latest year is 2021
# Background https://wbl.worldbank.org/en/wbl
# Data from https://datacatalog.worldbank.org/dataset/women-business-and-law > Dataset (1971-2021) > sheet "WBL2021"
wbl <- readxl::read_excel("Data/Input Data/Indexes.xlsx", sheet = "WBL2021") %>%
  select(iso3c = wbcodev2, country = economy, wbl_index = `WBL INDEX`) %>%
  mutate(iso3c = case_when(
    iso3c == "KSV" ~ "XKX",
    iso3c == "ROM" ~ "ROU",
    iso3c == "TMP" ~ "TLS",
    iso3c == "WBG" ~ "PSE",
    iso3c == "ZAR" ~ "COD",
    TRUE ~ iso3c
  ))

# 3. ODIN Open Gender Data Index ####
# Latest year is 2020
# Developed for ODIN 2020/2021 report
# Background https://odin.opendatawatch.com/Report/annualReport2020#sec3-6
# Data (not publicly available) from ODW Teams ODIN > ODIN Open Gender Data Index > ODIN OGDI 2020 rev.xlsx > sheet "OGDI Recalculated" > Column R "Overall score"
ogdi <- readxl::read_excel("Data/Input Data/Indexes.xlsx", sheet = "OGDI2020") %>%
  select(iso3c = `Country Code`, country = Country, ogdi = `Overall score`) %>%
  mutate(iso3c = case_when(
    iso3c == "ADO" ~ "AND",
    TRUE ~ iso3c
  ))

# 4. Statistical Performance Indicators (SPI) ####
# Latest year is 2019
# Background https://worldbank.github.io/SPI/ and https://www.worldbank.org/en/programs/statistical-performance-indicators
# From https://github.com/worldbank/SPI > Folder 03_output_data
spi <- read_csv("https://raw.githubusercontent.com/worldbank/SPI/master/03_output_data/SPI_index_labelled.csv") %>%
  filter(!is.na(country), date == 2019) %>%
  janitor::clean_names() %>%
  mutate(spi_index = as.numeric(spi_index)) %>%
  select(iso3c, country, spi_index_overall = spi_index)

# Supplemental A: World Bank Lending Status ####
# Latest iteration is FY2022
# Used to filter number of countries to just IDA-eligible countries (74 for IDA 19)
# Data from https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups
# File "current classification by income in XLSX format"
ida_status <- readxl::read_excel("Data/Input Data/FY2022 World Bank Groups.xlsx") %>%
  filter(!is.na(Region)) %>%
  select(iso3c = Code, lending_cat = `Lending category`)

# Create combined file ####
gender_indexes <- spi %>%
  full_join(wbl %>% select(-country)) %>%
  full_join(ogdi %>% select(-country)) %>%
  full_join(sigi %>% select(-country)) %>%
  full_join(ida_status) %>%
  # Keep just IDA-eligible countries (IDA-only countries, as well as countries with access to both IDA and IBRD)
  filter(lending_cat %in% c("Blend", "IDA")) %>%
  arrange(iso3c) %>%
  select(country, iso3c, ogdi, spi_index_overall, wbl_index, sigi_pct_rank) %>%
  mutate(across(ogdi:sigi_pct_rank, ~round(.x, 1)))

# Export
gender_indexes %>%
  write_csv("Data/Output Data/data_genderindexes.csv", na = "")

# Determine max value (for IDA countries) for each indicator for data dictionary
gender_indexes %>% 
  summarize(across(ogdi:sigi_pct_rank, ~max(.x, na.rm = TRUE)))

# Create Data Dictionary ####
indexes_data_dictionary <- tibble(
  `Field Name` = c("country", "iso3c", "ogdi", "spi_index_overall", "wbl_index", "sigi_pct_rank"),
  `Data Type` = c("VARCHAR", "VARCHAR", "DOUBLE", "DOUBLE", "DOUBLE", "DOUBLE"),
  Description = c("Country Name", "ISO 3166-1 alpha-3 country codes", "ODIN Open Gender Data Index", "Statistical Performance Indicator", "Women, Business and the Law Index", "OECD Social Institutions and Gender Index*"),
  `Maximum Value` = c(NA, NA, 60.6, 78.6, 91.9, 75.6),
  `Most Recent Year` = c(NA, NA, 2020, 2019, 2021, 2019),
  Notes = c(NA_character_, NA_character_, "Overall Score", "Overall Score", "Overall Score", "Overall Score, *Score converted to percentile rank among 120 countries worldwide with scores")
)

# Export
indexes_data_dictionary %>%
  write_csv("Data/Output Data/data_dictionary_genderindexes.csv", na = "")
