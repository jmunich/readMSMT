#' Returns meta data on MSMT files
#'
#' `get_locations` returns a meta data map of relevant MSMT files in a given folder.
#'
#' @param location specify path to the folder where MSMT data can be found. The function uses recursive search, so a higher level directory can be specified as well. If left blank, the function uses the current working directory.
#' @return a tibble with all sheets, specifying their location, names, lowercased name, form they are from, year and frequency of occurences in the folders.
#' @import tidyverse
#' @import readxl
#' @export
#' @examples
#' get_locations("E:/EDU/Data/data/MSMT/")

get_locations <- function(location = NULL){

  require(tidyverse, quietly = TRUE)
  require(readxl, quietly = TRUE)

  if(is.null(location)){
    location <- getwd()
  }

  all_files <- list.files(location, recursive = TRUE)
  adresses <- paste0(location,"/", all_files[grepl(".xlsx|.xls",all_files)&
                                         (!grepl("\\~\\$",all_files))])
  filename <- gsub(paste0(location,".+\\/"),"", adresses)
  all_sheets_list <- lapply(adresses, function(x){excel_sheets(x)})
  all_sheets <- unlist(all_sheets_list)
  all_sheets_op <- tolower(all_sheets)

  floc_per_sheet <- rep(adresses,lengths(all_sheets_list))
  flnm_per_sheet <- rep(filename,lengths(all_sheets_list))
  sheets_in_file <- rep(lengths(all_sheets_list),lengths(all_sheets_list))

  form <- tolower(substr(all_sheets,1,3))
  year <- substr(all_sheets,4,5)

  meta_data <- tibble(directory=floc_per_sheet,
                    sheet_name=all_sheets,
                    sheet=all_sheets_op,
                    form=form,
                    year=year)
  meta_data <- meta_data[grepl("^v[0-9]{4}",meta_data$sheet),]
  meta_data <- meta_data %>% group_by(sheet) %>% mutate(occurrences = n())
  return(meta_data)
}
