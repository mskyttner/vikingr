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
#' @importFrom dplyr mutate tbl_df tbl filter
#' @export
#' @examples
#' \dontrun{
#' download.file("http://www.aishub.net/downloads/nmea-sample.zip", destfile = "/tmp/nmea-sample.zip")
#' read_ais("/tmp/nmea-sample.zip")
#' }
read_ais <- function(file, ...) {

  if (Sys.which("python") == "")
    stop("python is required by this function to read AIS logs")
  
  cmd <- sprintf("%s %s -j -",
    Sys.which("python"), 
    system.file("python", "ais.py", package = "vikingr")
  )
  
  mess <- read_lines(file, ...)
  
  json <- system(cmd, intern = TRUE, input = mess)
  
  json_to_df <- function(x) {
    df <- fromJSON(x, simplifyDataFrame = TRUE, flatten = TRUE)
  }
  possibly_json_to_df <- possibly(
    .f = json_to_df, 
    otherwise = tibble(is_error = TRUE))
  
  res <- 
    map_df(json, possibly_json_to_df) %>%
    filter(is.na(is_error))

  problem_rowindices <- which(mess %in% setdiff(mess, res$message))
  problem_messages <- mess[problem_rowindices]
  
  if (length(problem_rowindices) > 0) {
    
    warning(sprintf("%s parsing failure(s) for a total of %s messages. Use readr::problems() for details.",
      length(problem_rowindices), length(mess)))
    
    attr(res, "problems") <- structure(
      data.frame(
        row = problem_rowindices, 
        col = "message", 
        expected = "ais.py-compliant data",
        actual = problem_messages,
        stringsAsFactors = FALSE
      ), class = c("tbl_df", "tbl", "data.frame")
    )
  }

  return (res)
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
    paste0("timestamp message is_error"))))

#' Get path to readr_ais example data
#'
#' vikingr comes bundled with sample files in its `inst/extdata`
#' directory. This function make them easy to access
#'
#' @param path Name of file. If `NULL`, the example files will be listed.
#' @export
#' @examples
#' vikingr_example()
#' vikingr_example("vikingr-visby-2019-ais")
#' vikingr_example("vikingr-visby-2019-ais-2")
vikingr_example <- function(path = NULL) {
  
  if (is.null(path)) {
    dir(system.file("extdata", package = "vikingr"))
  } else {
    system.file("extdata", path, package = "vikingr", mustWork = TRUE)
  }
}

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
#mymsg <- log$message[1:2] %>% paste0(collapse = "\n")
#mycon <- rawConnection(charToRaw(mymsg), "r+")
#read_ais(mycon)

