#' Assertions
#' 
#' @keywords internal
does_exist <- function(x){
  length(x) > 0
}

assertthat::on_failure(does_exist) <- function(call, env){
  "Cannot find path to npm, see `npm_path_set`"
}
