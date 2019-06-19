#' vikingr
#' 
#' Read AIS messages and work with example data in AIS format
#' 
#' @aliases vikingr
#' @name vikingr-package
#' @keywords package
NULL

# global reference to scipy (will be initialized in .onLoad)
#py <- NULL

.onLoad <- function(libname, pkgname) {
  if (!py_available(initialize = TRUE))
    stop("Is python installed? reticulate::py_available reports FALSE.")
#  py <<- py
}