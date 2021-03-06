#' set the validation date in the gdrive RCM
#' @param file.id the file id of the item to change
#' @param date the date to set it to. Must be of class "POSIXct".
#' @return returns nothing important
rcm_set_validation_date<-function(file.id,date=as.POSIXct(Sys.Date())){
  # stop if input no good:
  if(!("POSIXct" %in% class(date))){
    stop("date must be in POSIXct format")
  }

  if(is.null(file.id) | is.null(date)){stop("inputs can't be NULL")}

  date_text <- format(date, format="%d-%b-%y")
  if(length(date_text)!=1){stop("date not converted to single date text")}

  rcm_change_value(file.id,column = rcm_gsheet_column_letters$date.validated,value = date_text)


}

#' set the "feedback given" date in the gdrive RCM
#' @param file.id the file id of the item to change
#' @param date the date to set it to. Must be of class "POSIXct".
#' @return returns nothing important
rcm_set_withfield_date<-function(file.id,date=as.POSIXct(Sys.Date())){
  # stop if input no good:
  if(!("POSIXct" %in% class(date))){
    stop("date must be in POSIXct format")
  }

  if(is.null(file.id) | is.null(date)){stop("inputs can't be NULL")}

  date_text <- format(date, format="%d-%b-%y")
  if(length(date_text)!=1){stop("date not converted to single date text")}

  rcm_change_value(file.id,column = rcm_gsheet_column_letters$first.feedback.date,value = date_text)


}

#' set the "actual received" date in the gdrive RCM
#' @param file.id the file id of the item to change
#' @param date the date to set it to. Must be of class "POSIXct".
#' @return returns nothing important
rcm_set_withHQ_date<-function(file.id,date=as.POSIXct(Sys.Date())){
  # stop if input no good:
  if(!("POSIXct" %in% class(date))){
    stop("date must be in POSIXct format")
  }

  if(is.null(file.id) | is.null(date)){stop("inputs can't be NULL")}

  date_text <- format(date, format="%d-%b-%y")
  if(length(date_text)!=1){stop("date not converted to single date text")}

  rcm_change_value(file.id,column = rcm_gsheet_column_letters$submission.date,value = date_text)


}


