#' Creates a map of MSMT data for future reference
#'
#' `map_folders` maps sheets containing form data in MSMT folder: their locations and variables. The function saves the map in an .RDATA format for future use, but can be also used to create a workspace object.
#'
#' @param location A single character with file path to the directory containing MSMT data. If left blank, working directory is used as a default.
#' @param save_map If TRUE, the function saves a map in the working directory. Can be set to FASLE, or replaced with a single character specifying path to the folder to save the map.
#' @param return_map If TRUE, the function returns the map, so it can be used in the workspace.
#' @return A list containing locations of excel sheets and variable names occurring in the sheets.
#' @import tidyverse
#' @import readxl
#' @export
#' @examples
#' map_folders(location = "E:/EDU/Data/data/MSMT/")

map_folders <- function(location = NULL, save_map = TRUE, return_map = FALSE){

  require(tidyverse, quietly = TRUE)
  require(readxl, quietly = TRUE)

  if(!((length(location)==1&is.character(location))|is.null(location))){
    stop("location must be a character of length 1 or empty")
  }

  if(!(length(save_map)==1&is.character(save_map))|is.logical(save_map)){
    stop("location must be a character of length 1 or a logical")
  }

  if(is.null(location)){
    location <- getwd()
  }

  save_to<-NULL

  if(is.logical(save_map)){
    if(save_map){
      save_to <- getwd()
    }
  }

  if(is.character(save_map)){
    save_to <- save_map
  }

  output <- get_varnames(location = locs)

  if(!is.null(save_to)){
    saveRDS(output, paste0(save_to,"MSMT_data_map.RDATA"))
  }
  if(return_map){
    return(output)
  }
}
