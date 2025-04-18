drifter
================

[drifter](https://github.com/kolive4/drifter) provide supplementary
tools for working with track data.

### Requirements

- [R v 4.1+](https://www.r-project.org/)
- [rlang](https://CRAN.R-project.org/package=rland)
- [dplyr](https://CRAN.R-project.org/package=dplyr)
- [sf](https://CRAN.R-project.org/package=sf)

### Installation

    remotes::install_github("kolive4/drifter")

## Usage

``` r
suppressPackageStartupMessages(
  {
    library(sf)
    library(dplyr)
    library(drifter)
  }
)
```

### Reading example data

``` r
# drift_tibble = read_gpx("inst/ex_data/cape_cod_complicated.GPX")
drift_sf = read_gpx("inst/ex_data/cape_cod_complicated.GPX", form = "sf")
drift_sf1 = read_gpx1("inst/ex_data/cape_cod_complicated.GPX", form = "sf")
```
