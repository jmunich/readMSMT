#' Show the availability of requested variables across selected forms over years
#'
#' Using a map of variables, `get_variable_availability` returns a list of tibbles showing the availability of requested variables in time 
#' @param variables A character vector with requires variable names in lowercase.
#' @param map A folder map retrieved from map_folders. If left empty, the function will search the working directory for a map file. Can be also used to specify file path to the map file.
#' @param forms A character vector with forms of interest, in the following form c("v11","v12") etc., where the number specifies form number. If blank, all forms are used. For form numbers, consult forms_codes().
#' @param print_plots Logical indicating whether the function should print plots. Plots will be available in output even if not printed.
#' @return a list of tibbles with requested variables and identifiers, and a tibble with information about used sheets. To join into a single tibble, use bind_rows() on the tibble list.
#' @import tidyverse
#' @import readxl
#' @export
#' @examples
#' availability <- get_variable_availability(variables = c("r01010","r01011"), map = my_map, forms = "v03")
#' availability$plots$v03

get_variable_availability <- function(variables, map = NULL, forms = NULL, print_plots = FALSE){
  require(tidyverse, quietly = TRUE)
  if(is.null(map)){
    if("MSMT_data_map.RDATA"%in%list.files(getwd())){
      map <- readRDS(paste0(getwd(),"MSMT_data_map.RDATA"))
    }else{
      stop("No map object or location specified and the map file is not in the working directory")
    }
  }
  
  if(is.character(map)&(length(map)==1)){
    if("MSMT_data_map.RDATA"%in%list.files(getwd())){
      map <- readRDS(paste0(map,"MSMT_data_map.RDATA"))
    }else{
      stop("Map file is not in the specified directory")
    }
  }
  
  occu_vec <- t(sapply(map$varlist_lc,
                       FUN = function(x){variables %in% x}, 
                       simplify = "matrix")) %>%
    `colnames<-`(variables) 
  
  tib_list <- list()
  for(i in 1:length(forms)){
    tib_list[[i]] <- occu_vec %>%
      as_tibble() %>%
      mutate(year = map$meta_data$year) %>%
      filter(map$meta_data$form==forms[i]) %>%
      group_by(year) %>%
      summarise_all(function(x){sum(x)>0}) %>%
      ungroup() %>%
      mutate_at(-1, .funs = function(x){ifelse(x, "Yes", "No")})
  }
  names(tib_list) <- forms
  
  plot_list <- list()
  for(i in 1:length(forms)){
    plot_list[[i]] <- tib_list[[i]] %>%
      pivot_longer(-year) %>%
      ggplot(aes(y = ordered(name, variables), x = year, fill = as.factor(value))) +
      geom_tile(color = "black") +
      theme_classic() + labs(y = "Variable", x = "Year", fill = "Available") +
      scale_fill_manual(values = c(No="#801D1E", Yes="#69848D")) +
      ggtitle(label = paste0("Form: ",forms[i]))
  }
  
  names(plot_list) <- forms
  
  if(print_plots){
    invisible(lapply(plot_list, print))
  }
  
  output <- list(tables = tib_list,
                 plots = plot_list)
  
  return(output)
}
