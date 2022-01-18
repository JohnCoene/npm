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
#' @importFrom erratum bash resolve
#' 
#' @return Invisibly returns the output of the command.
#' 
#' @return Invisibly returns the output of the command
#' as a `character` vector.
#' 
#' @export
npm_run <- function(...){
  output <- bash(system_2(...))
  resolve(output)
  invisible(output)
}

#' @keywords internal
#' @importFrom cli cli_process_start cli_process_failed cli_process_done
#' @importFrom erratum bash w e resolve
npm_run_process <- function(..., s, d, f){
  cli_process_start(s, d, f)
  output <- bash(
    system_2(...),
    w = function(war){
      cli_process_done()
      w(war)
    },
    e = function(err){
      cli_process_failed()
      e(err)
    }
  )

  resolve(output)

  cli_process_done()
  
  invisible(output)
}

#' Wrapper on System Call
#' 
#' A soft wrapper on system call.
#' 
#' @keywords internal
system_2 <- function(..., stdout = "", stderr = ""){
  path <- npm_path_get()
  system2(path, c(...), stdout = stdout, stderr = stderr)
}

#' NPM Init
#' 
#' Initialise an NPM project.
#' 
#' @examples 
#' \dontrun{npm_init()}
#' 
#' @return Invisibly returns the output of the command
#' as a `character` vector.
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
#' This is ignored if no packages are passed to the three
#' dots construct (`...`).
#' 
#' @examples 
#' \dontrun{npm_install("browserify", scope = "global")}
#' 
#' @return Invisibly returns the output of the command
#' as a `character` vector.
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

  # override scope if no pkgs passed
  if(length(...) == 0)
    scope <- ""

  npm_run_process(
    "install", 
    scope,
    ..., 
    s = msgs$s, 
    d = msgs$d, 
    f = msgs$f
  )
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

  pkgs_out <- "packages from {.val `package.json`}"
  if(length(pkgs) > 0)
    pkgs_out <- sapply(pkgs, function(pak){
      sprintf("{.val `%s`}", pak)
    })

  paste0(pkgs_out, collapse = ", ")
}

#' NPM Audit Fix
#' 
#' Audit NPM packages and fix potential issues.
#' 
#' @param fix Whether to also fix issues.
#' 
#' @examples
#' \dontrun{npm_audit()} 
#' 
#' @return Invisibly returns the output of the command
#' as a `character` vector.
#' 
#' @export 
npm_audit <- function(fix = FALSE){
  fix_flag <- ""
  if(fix) fix_flag <- "fix"
  
  npm_run_process(
    "audit", 
    fix_flag,
    s = "Auditing packages",
    d = "Audited packages",
    f = "Failed to audit packages"
  )
}

#' Outdated Packages
#' 
#' Get outdated NPM packages.
#' 
#' @examples
#' \dontrun{npm_outdated()} 
#' 
#' @return The output of the command
#' as a `character` vector.
#' 
#' @export 
npm_outdated <- function(){
  system_2("outdated")
}

#' Update Packages
#' 
#' Update NPM packages.
#' 
#' @examples
#' \dontrun{npm_update()} 
#' 
#' @return Invisibly returns the output of the command
#' as a `character` vector.
#' 
#' @export 
npm_update <- function(){
  npm_run_process(
    "update",
    s = "Updating packages",
    d = "Updated packages",
    f = "Failed to update packages"
  )
}
