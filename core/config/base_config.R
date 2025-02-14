# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# F I L E   N A M E  I N P U T S
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
library(devtools)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# L O A D   I N  F U N C T I O N S
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
devtools::source_url("https://raw.githubusercontent.com/rtobiaskoch/wnv-s_data_tools/refs/heads/main/0_R/gsheet_pull_prompt.R")
devtools::source_url("https://raw.githubusercontent.com/rtobiaskoch/wnv-s_data_tools/refs/heads/main/0_R/calc_vi_stats.R")

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# F I L E   N A M E  I N P U T S
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
config <- list(
  fn_co_mdata = "mdata_co.csv",
  fn_co_fasta = "FortCollins_dataset_aligned.fasta",
  fn_data_zone = "data_zone_wk_stats.csv",
  fn_co_database = "wnv-s_database.csv",
  fn_co_zone = "data_zone_wk_stats.csv"
)

if ("config" %in% ls()) {
  config <- c(config, config)
} else {
  config <- config
}

# Assign the config object to a global variable for convenience
assign("config", config, envir = .GlobalEnv)
