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
  packages_to_install <- package_names[
    which(!package_names %in% installed.packages())
    ]
  
  if (length(packages_to_install) > 0) {
    install.packages(
      packages_to_install,
      repos = 'https://cloud.r-project.org'
    )
  }
  
  if (length(package_names) > 0) {
    lapply(package_names, require, character.only = TRUE)
  }
}
