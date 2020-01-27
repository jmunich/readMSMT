#' Returns names of variables in MSMT files
#'
#' `get_varnames`Uses the output of get_locations function and returns the list of all variable names in available data.
#'
#' @param location A tibble from get_locations function. If left blank, uses get_location with no specified parameters.
#' @param forms A character vector with forms of interest, in the following form c("v11",v"12") etc., where the number specifies form number. For form numbers, consult forms_codes().
#' @param binary: print boolean (TRUE) or counts (FALSE) for repeated observations
#' @return a list of values indicating files with repeated rows
#' @import tidyverse
#' @import readxl
#' @export
#' @examples
#' mymap <- get_locations("E:/EDU/Data/data/MSMT/")
#' get_varnames(location = mymap, forms = "v11")

get_varnames <- function(location=NULL, forms=NULL, years=NULL){

  require(tidyverse, quietly = TRUE)
  require(readxl, quietly = TRUE)

  if(!(is_tibble(location)|is.character(location)|is.null(location))){
    stop("location must be a tibble, character or empty")
  }
  if(is.null(location)){
    location <- get_locations()
  }else{
    if(!is_tibble(location)){
    location <- get_locations(location)
    }
  }
  if(is.null(forms)){
    forms <- unique(location$form)
  }
  if(is.null(years)){
    years <- unique(location$year)
  }
  if(!all(forms%in%unique(location$form))){
    stop("One or more specified forms are not in the location tibble")
  }
  if(!all(years%in%unique(location$year))){
    stop("One or more specified years are not in the location tibble")
  }
  location_select <- location[(location$form%in%forms)&(location$year%in%years),]
  variables <- list()
  for(i in 1:nrow(location_select)){
    variables[[i]] <- names(read_excel(path = location_select$directory[i],
                               sheet = location_select$sheet_name[i], n_max = 0))
  }
  variables_lc<-lapply(variables, tolower)
  output <- list(meta_data = location_select, varlist = variables, varlist_lc = variables_lc)
  return(output)
}
