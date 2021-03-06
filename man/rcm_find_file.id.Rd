% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rcm_search.R
\name{rcm_find_file.id}
\alias{rcm_find_file.id}
\title{Search RCM for terms and return the file id}
\usage{
rcm_find_file.id(rcm, search, unit = NULL)
}
\arguments{
\item{search}{single string with search terms separated by a simple space. Search is not case sensitive. The best match will be returned. If there are multiple matches with the best match score, the user is prompted to select one.}
}
\value{
the id as a string
}
\description{
Search RCM for terms and return the file id
}
