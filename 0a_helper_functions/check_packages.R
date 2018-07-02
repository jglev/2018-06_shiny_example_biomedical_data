#' Load (or install and then load) a package
#'
#' @param package_names  A character vector of package names.
#'
#' @return  A list: For each package in \code{package_names}, TRUE or FALSE,
#' reflecting whether the library was (installed and ultimately) loaded.
#'
#' @export
#'
#' @examples
check_packages <- function(package_names){
  for (package_name in package_names) {
    if (!require(package_name, character.only = TRUE)) {
      install.packages(
        package_name,
        repos = 'https://cloud.r-project.org'
      )
    }
    
    require(package_name, character.only = TRUE)
  }
}
