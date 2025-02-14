if (!requireNamespace("pacman", quietly = TRUE)) {install.packages("pacman")}

rm(list = ls())
pacman::p_load(here, ape, tidyverse)

source("../core/config/base_config.R")

df0 = read.csv(here("../", "data", "raw", "metadata", fn_co_mdata))
fa0 = read.FASTA(here("../", "data", "raw", "sequences", fn_co_fasta))


#edited names of fasta sequences to match metadata
names(fa0) = gsub("(^[^_]+_[^_]+).*", "\\1", names(fa0))
names(fa0) = gsub("_", "", names(fa0))
head(fa0)

write.FASTA(fa0, here("../", "data", "raw", "sequences", fn_co_fasta))

