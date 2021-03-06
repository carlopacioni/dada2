% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/dada.R
\name{getDadaOpt}
\alias{getDadaOpt}
\title{Get DADA options}
\usage{
getDadaOpt(option = NULL)
}
\arguments{
\item{option}{(Optional). Character.
 The DADA option(s) to get.}
}
\value{
Named list of option/value pairs.
 Returns NULL if an invalid option is requested.
}
\description{
Get DADA options
}
\examples{
getDadaOpt("BAND_SIZE")
getDadaOpt()
}
\seealso{
\code{\link{setDadaOpt}}
}

