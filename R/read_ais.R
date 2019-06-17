#' Decode ais messages
#' 
#' `read_ais` wraps `readr::read_lines()` and reads AIS messages 
#' making use of the ais.py code from \url{https://gist.github.com/ieb/9c337d68a4492db1571e} 
#' which has been bundled into the package. This function therefore 
#' has a dependency on python as stated in the SystemRequirements entry 
#' in the DESCRIPTION file.
#' 
#' Use the same parameters as for `readr::read_lines()`
#' @param file a path to a file, connection or literal data
#' @param ... params sent on to read_lines
#' @return a tibble with AIS data
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map_df possibly
#' @importFrom tibble tibble
#' @export
read_ais <- function(file, ...) {

  if (Sys.which("python") == "")
    stop("python is required by this function to read AIS logs")
  
  cmd <- sprintf("%s %s -j -",
    Sys.which("python"), 
    system.file("python", "ais.py", package = "vikingr")
  )
  
  mess <- read_lines(file, ...)
  
  json <- system(cmd, intern = TRUE, input = mess)
  
  json_to_df <- function(x) 
    fromJSON(x, simplifyDataFrame = TRUE, flatten = TRUE)
  
  possibly_json_to_df <- possibly(
    .f = json_to_df, 
    otherwise = tibble(is_error = TRUE))
  
  map_df(json, possibly_json_to_df)
}

#' Read a log file with lines containing comma separated Unix timestamps and AIS messages
#' 
#' Takes a log file and parses valid rows into a tibble of timestamps and AIS messages

#' @param file a path to a file, connection or literal data
#' @param ... params sent on to readr::read_lines
#' @return a tibble with the timestamp and the encoded AIS message
#' @importFrom readr read_lines read_tsv
#' @importFrom stringr str_detect str_replace_all
#' @importFrom tibble as_tibble
#' @importFrom lubridate as_datetime
#' @importFrom dplyr mutate %>%
#' @export
read_ais_log <- function(file, ...) {
  
  log <- readr::read_lines(file, ...)
  valid_rows <- log %>% stringr::str_detect("\\d+, ")

  log[valid_rows] %>%  
  stringr::str_replace_all(", ", "\t") %>%
  read_tsv(col_names = c("timestamp", "message")) %>%
  mutate(timestamp = lubridate::as_datetime(timestamp)) %>%
  as_tibble()
}

#' @importFrom utils globalVariables
if (getRversion() >= "2.15.1")
  globalVariables(names = unlist(strsplit(split = " ",
    paste0("timestamp"))))

# library(reticulate)
# library(readr)
# library(here)
# 
# mess <- read_lines("data-raw/nmea-sample", n_max = 2)
# 
# #read_ais <- py_to_r(parse_ais_messages)
# #res <- read_ais(mess, FALSE, TRUE, FALSE)
# #str(res)
# 
# # parse ais message using Python ais.py
# library(jsonlite)
# 
# cat(json)
# 
# library(purrr)

