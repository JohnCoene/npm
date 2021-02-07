#' Set Path to NPM Installation
#' 
#' Define the path to the NPM installation. By default,
#' this should not be necessary, parcel will find the path
#' by itself if NPM was installed correctly.
#' 
#' @param path Path to NPM binary.
#' 
#' @name npm_path
#' @export
npm_path_set <- function(path = Sys.getenv("NPM_PATH")){
  assert_that(does_exist(path))
  npm_path_env_set(path)
}

#' @describeIn npm_path Get NPM path
#' @importFrom assertthat assert_that
#' @export 
npm_path_get <- function(){
  found <- npm_find()
  env <- npm_path_env_get()

  if(!is.null(env))
    return(env)

  assert_that(does_exist(found))
  found
}

#' NPM Path Environment
#' @keywords internal
npm_path_env_set <- function(path){
  Sys.setenv(NPM_PATH = path)
}

#' @keywords internal
npm_path_env_get <- function(){
  path <- Sys.getenv("NPM_PATH")

  if(path == "")
    return()

  path
}

#' Find NPM
#' 
#' Find path to NPM installation
#' 
#' @keywords internal
npm_find <- function(){
  Sys.which("npm")
}

#' NPM Run
#' 
#' @param ... arguments to pass to the `npm` command.
#' 
#' @keywords internal
#' 
#' @importFrom erratum jab enforce w e
npm_run <- function(...){
  path <- npm_path_get()
  output <- jab(
    system2(path, c(...), stdout = TRUE, stderr = TRUE),
    w = w("failed to run command"),
    e = e("failed to run command")
  )
  enforce(output)
  invisible(output)
}

#' @keywords internal
#' @importFrom cli cli_process_start cli_process_failed cli_process_done
#' @importFrom erratum jab w e is.e is.w
npm_run_process <- function(..., s, d, f){
  path <- npm_path_get()

  cli_process_start(s, d, f)
  output <- jab(
    system2(path, c(...), stdout = TRUE, stderr = TRUE),
    w = function(w){
      cli_process_failed()
      w("failed to run command")
    },
    e = function(e){
      cli_process_failed()
      e("failed to run command")
    }
  )
  
  if(is.e(output) || is.w(output))
    return()

  cli_process_done()
  
  invisible(output)
}

#' NPM Init
#' 
#' @export 
npm_init <- function(){
  npm_run_process(
    "init", "-y",
    s = "Initialising npm",
    d = "Initialised npm",
    f = "Failed to initialise npm"
  )
}

#' NPM Install
#' 
#' @param ... Names of packages to install.
#' @param scope Scope of the installation of the packages.
#' 
#' @export 
npm_install <- function(
  ..., 
  scope = c(
    "dev", 
    "prod", 
    "exact",
    "global",
    "optional"
  )
){

  msgs <- package_message(...)
  scope <- scope2flag(scope)
  npm_run_process("install", scope, ..., s = msgs$s, d = msgs$d, f = msgs$f)
}

#' @keywords internal
scope2flag <- function(scope = c("dev", "prod", "global")){
  scope <- match.arg(scope)

  switch(
    scope,
    dev = "--save-dev",
    prod = "--save",
    global = "--global",
    optional = "--save-optional",
    exact = "--save-exact"
  )
}

#' Package Installation Messages
#' 
#' Creates messages for installation process.
#' 
#' @keywords internal
package_message <- function(...){
  pkgs_flat <- packages_flat(...)

  list(
    s = sprintf("Installing %s", pkgs_flat),
    d = sprintf("Installed %s", pkgs_flat),
    f = sprintf("Failed to installed %s", pkgs_flat)
  )
}

#' Flatten Packages
#' 
#' Flatten packages for creating the message.
#' 
#' @keywords internal
packages_flat <- function(...){
  pkgs <- c(...)

  if(length(pkgs) == 0)
    pkgs <- "packages from {.val `package.json`}"
  else 
    pkgs <- sapply(pkgs, function(pak){
      sprintf("{.val `%s`}", pak)
    })

  paste0(pkgs, collapse = ", ")
}
