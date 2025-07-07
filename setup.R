# Run this script before working with this project.  It handles package installation and loading
# and sources local functions.
#
# A. check for CRAN available packages - install missing
# B. check for GITHUB available packages - install missing
# C. install any others
# D. load packages from library
# E. set the working directory
# F. source each file in subdir 'functions'

installed = rownames(installed.packages())

cran_packages = c("rlang", "dplyr", "readr", "ggplot2", "rappdirs", "mapr",
                  "ncmeta", "stars", "rlist", "RColorBrewer", "sf", "twinkle",
                  "here", "docstring", "agua", "butcher")
ix = (cran_packages %in% installed)
for (package in cran_packages[!ix]) {
  install.packages(package)
}


github_packages = c("cofbb" = "BigelowLab", 
                    "topotools" = "BigelowLab",
                    "charlier" = "BigelowLab")
ix = names(github_packages) %in% installed
for (package in names(github_packages[!ix])) {
  remotes::install_github(sprintf("%s/%s", github_packages[package], package))
}


suppressPackageStartupMessages({
  for (package in cran_packages) library(package, character.only = TRUE)
  for (package in names(github_packages)) library(package, character.only = TRUE)
})

here::i_am("setup.R")

DATAPATH = here::here("inst/ex_data")

for (f in list.files(here::here("R"), pattern = "^.*\\.R$", full.names = TRUE)){
  source(f)
}