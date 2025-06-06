% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gpx.R
\name{import_gpx}
\alias{import_gpx}
\title{Read a GPX file}
\usage{
import_gpx(
  filename = "cape_cod_complicated.GPX",
  form = c("table", "sf")[2],
  crs = 4326
)
}
\arguments{
\item{filename}{chr the name of the file to read}

\item{form}{chr one of "table" or "sf"}

\item{crs}{when casting to "sf", use this crs}
}
\value{
a 4 element list with filename, routes, tracks and waypoints
One or more of the last three might be NULL.
}
\description{
This is inspired by the \href{https://cran.r-project.org/web/packages/gpx/index.html}{gpx R package}
}
