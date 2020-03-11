#' Return a list of tibbles with requested MSMT data
#'
#' Using a map of variables, `get_variables` returns tibbles with required variables and identifiers from specified years and forms.
#' @param variables A character vector with requires variable names in lowercase.
#' @param joint A character vector including case identifiers to look for in the data. Uses a vector of default identifiers.
#' @param map A folder map retrieved from map_folders. If left empty, the function will search the working directory for a map file. Can be also used to specify file path to the map file.
#' @param forms A character vector with forms of interest, in the following form c("v11","v12") etc., where the number specifies form number. If blank, all forms are used. For form numbers, consult forms_codes().
#' @param years A character vector with years of interest, in the following form c("12", "13") etc., where the number specify the last two numerics of a given year. If blank, all years are used.
#' @return a list of tibbles with requested variables and identifiers, and a tibble with information about used sheets. To join into a single tibble, use bind_rows() on the tibble list.
#' @import tidyverse
#' @import readxl
#' @export
#' @examples
#' mymap <- get_locations("E:/EDU/Data/data/MSMT/")
#' get_variables(variables = c("r01010","r01011"), map = my_map, forms = "v03", years = c("12","13"))

get_variables<-function(variables, joint=c("red_izo","izo","p_izo","izonew"), map=NULL, forms=NULL, years=NULL){
  require(tidyverse, quietly = TRUE)

  if(is.null(map)){
    if("MSMT_data_map.RDATA"%in%list.files(getwd())){
    map <- readRDS(paste0(getwd(),"/MSMT_data_map.RDATA"))
    }else{
      stop("No map object or location specified and the map file is not in the working directory")
    }
  }

  if(is.character(map)&(length(map)==1)){
    if("MSMT_data_map.RDATA"%in%list.files(getwd())){
      map <- readRDS(paste0(map,"/MSMT_data_map.RDATA"))
    }else{
      stop("Map file is not in the specified directory")
    }
  }

  locations <- map$meta_data

  if(!is_tibble(locations)){
    stop("Location tibble could not be found in the map")
  }

  if(is.null(forms)){
    forms <- unique(locations$form)
  }
  if(is.null(years)){
    years <- unique(locations$year)
  }
  if(!all(forms%in%unique(locations$form))){
    stop("One or more specified forms are not in the location tibble")
  }
  if(!all(years%in%unique(locations$year))){
    stop("One or more specified years are not in the location tibble")
  }

  variable_maps<-map

  sel_mat_joint<-sapply(variable_maps$varlist_lc, simplify = "vector", function(x){joint%in%x})
  sel_mat<-sapply(variable_maps$varlist_lc, simplify = "vector", function(x){variables%in%x})
  if(!is.matrix(sel_mat)){
    sel_mat<-matrix(sel_mat, nrow=1)
  }
  if(sum(sel_mat)==0){
    stop(paste0("No variables called ",variables," found"))
  }
  varlist<-apply(rbind(sel_mat_joint, sel_mat),2,function(x){c(joint,variables)[x]})
  names(varlist)<-as.character(c(1:nrow(variable_maps$meta_data)))

  variable_maps$meta_data$id<-as.character(c(1:nrow(variable_maps$meta_data)))

  location_select<-variable_maps$meta_data[colSums(sel_mat)>0,] %>% filter((form%in%forms)&(year%in%years)) %>% distinct(sheet_name, .keep_all = TRUE)

  if(max(location_select$occurrences)>1){
    warning(paste0("File(s) ",paste(location_select$sheet[location_select$occurrences>1], collapse = ", ")," have two or more occurrences. Using the first file."))
  }
  varlist<-varlist[location_select$id]

  variables<-list()
  for(i in 1:nrow(location_select)){
    subtibble<-read_excel(path=location_select$directory[i],
                                     sheet=location_select$sheet_name[i], .name_repair = tolower)[,varlist[[i]]]
    subtibble$year<-location_select$year[i]
    variables[[i]]<-subtibble[,c(ncol(subtibble),c(1:(ncol(subtibble))-1))]
  }
  names(variables)<-location_select$sheet
  output<-list(meta_data=location_select, variables=variables)
  return(output)
}
