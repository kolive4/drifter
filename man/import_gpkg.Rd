% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gpkg.R
\name{import_gpkg}
\alias{import_gpkg}
\title{function to import geopackages (.gpkg)}
\usage{
import_gpkg(filename, coords = "date_time", tz = "UTC")
}
\arguments{
\item{filename}{name of the file}

\item{coords}{date time coordinate column name}

\item{tz}{chr, time zone}
}
\value{
sf table
}
\description{
function to import geopackages (.gpkg)
}
