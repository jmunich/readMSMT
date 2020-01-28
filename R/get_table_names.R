#' Creates variable name matrix for easier use of form indices
#'
#' `get_table_names` facilitates the reconstruction of cell names from MSMT forms. The format of cell indices takes the following format: xxyyz. "xx" is the table prefix common to all values in table. yy indicates the row and y (usually only one, but can be longer) stands for the column. 
#' @param table_ind A single character indicating the table prefix
#' @param row_inds A numeric vector indicating requested row indices. If some rows are indexed using a letter, use `extra_row` parameter
#' @param col_inds A numeric vector indicating requested column indices. If some column are indexed using a letter, use `extra_col` parameter
#' @param extra_row A character vector indicating rows indexed with a character. If the index starts with 0, include it in the character vector, e.g. c("07a","07b")
#' @param extra_col A character vector indicating columns indexed with a character. If the index starts with 0, include it in the character vector, e.g. c("07a","07b")
#' @param omits If you would like to replace some cells with NA, include a list of matrix indices (e.g. list(c(1,1),c(1,2))) of requested cells. Cell indices reflect values of all entered row/column index names, including extra_ as they would appear in the form
#' @param prefix As variable names start with "r", prefix defaults to that value, but can be replaced
#' @param column_names A character vector (optional) where names of columns can be manually assigned. Order of columns will reflect column indices sorted as they would appear in the form, including those from extra_col 
#' @param rows_names A character vector (optional) where names of rows can be manually assigned. Order of rows will reflect sorted row indices sorted as they would appear in the form, including those from extra_row 
#' @return a matrix of cell names that can be used to call indexed groups of cells from MSMT data
#' @export
#' @examples
#' get_table_names(table_ind = "3B", row_inds = 1:14, col_inds = 2:10, extra_col = c("10a","10b"))

get_table_names <- function(table_ind, row_inds, 
                            col_inds, extra_col = NULL, 
                            extra_row = NULL, omits = NULL, 
                            prefix = "r", column_names = NULL, 
                            rows_names = NULL){
  
  row_inds <- as.numeric(row_inds)
  col_inds <- as.numeric(col_inds)
  
  if(is.numeric(table_ind)){
    table_ind_mod <- ifelse(table_ind<10,paste0(0,table_ind),as.character(table_ind))
  }else{
    table_ind_mod <- table_ind
  }
  
  row_ind_mod <- c(ifelse(row_inds<10,paste0(0,row_inds),as.character(row_inds)), extra_row)
  col_ind_mod <- c(as.character(col_inds), extra_col)
  
  row_ind_ord <- tolower(row_ind_mod)
  for(i in 1:20){
    temp_locs <- grepl(letters[i], row_ind_ord)
    row_ind_ord <- gsub(letters[i], "", row_ind_ord)
    row_ind_ord[temp_locs] <- as.numeric(row_ind_ord[temp_locs])+(1/i)
  }
  row_ind_mod <- row_ind_mod[order(as.numeric(row_ind_ord))]   
  
  col_ind_ord <- tolower(col_ind_mod)
  for(i in 1:20){
    temp_locs <- grepl(letters[i], col_ind_ord)
    col_ind_ord <- gsub(letters[i], "", col_ind_ord)
    col_ind_ord[temp_locs] <- as.numeric(col_ind_ord[temp_locs])+(1/i)
  }
  
  col_ind_mod <- col_ind_mod[order(as.numeric(col_ind_ord))]   
  
  rows_r <- paste0("r", table_ind_mod, row_ind_mod)
  cols_r <- sapply(col_ind_mod, function(x){paste0(rows_r, x)})
  
  colnames(cols_r) <- column_names
  rownames(cols_r) <- rows_names
  
  if(!is.null(omits)){
    cols_r[t(as.data.frame(omits))] <- NA
  }
  
  output <- tolower(cols_r)
  
  return(output)
}
