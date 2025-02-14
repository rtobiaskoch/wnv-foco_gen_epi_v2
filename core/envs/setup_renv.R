# Ensure renv is installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("jsonlite")
  install.packages("renv")
}

# Initialize renv only if it hasn't been initialized
if (!dir.exists("renv")) {``
  renv::init()
  renv::activate()
} else {
  renv::activate()
}

# Define required packages
packages <- c(
  "tidyverse",
  "phytools",
  "ape",
  "here",
  "googledrive",
  "googlesheets4",
  "devtools"
)

# Install missing packages using renv::install()
installed <- installed.packages()[, "Package"]
packages_to_install <- setdiff(packages, installed)

if (length(packages_to_install) > 0) {
  renv::install(packages_to_install)
}

# Install PooledInfRate from GitHub if missing
if (!"PooledInfRate" %in% installed) {
  renv::install("CDCgov/PooledInfRate")
}

# Snapshot environment only if new packages were installed
renv::snapshot(prompt = FALSE)

message("renv setup complete!")
