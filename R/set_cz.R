#' Sets locale to UTF-8 for working with czech characters
#'
#' @import tidyverse
#' @import readxl
#' @export
#' @examples
#' set_cz()

set_cz<-function(){
  if (.Platform$OS.type == 'windows') {
    Sys.setlocale(category = 'LC_ALL','English_United States.1250')
  } else {
    Sys.setlocale(category = 'LC_ALL','en_US.UTF-8')
  }
}
