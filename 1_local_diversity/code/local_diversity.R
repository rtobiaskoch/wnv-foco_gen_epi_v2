# HEADER THIS SCRIPT LOOKS AT LOCAL DIVERSITY OF WNV AND ITS ROLE IN VI 

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#-------------------------------- H E A D E R  ---------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rm(list = ls())


library(tidyverse)
library(phytools)
library(ape)
library(here)

#run config file to set the filenames and locations
#source(here("../", "core", "config", "base_config.R"))s

if (basename(getwd()) == "wnv-foco_gen_epi_v2") {
  data_path <- here()
} else {
  data_path <- here("../")
}
#load in the config file
source(file.path(data_path, "core", "config", "base_config.R"))

#use the config file to set the filenames and locations
fn_co_mdata <- file.path(data_path, "data", "raw", "metadata", config$fn_co_mdata)
fn_co_database <-  file.path(data_path, "data", "raw", "metadata", config$fn_co_database)
fn_co_fasta <-  file.path(data_path, "data", "processed", "sequences", config$fn_co_fasta)

#read in the data
df0 = read.csv(fn_co_mdata)
df_database = read.csv(fn_co_database)
fa0 = read.FASTA(fn_co_fasta)


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#------------------ C A L C   P A I R W I S E   D I S T  -----------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Ensure sequence names are accessible
seq_names <- names(fa0)

# Filter metadata to include only sequences present in fa0
df_list <- df0 %>%
  filter(accession %in% seq_names) %>%
  group_by(trap) %>%
  group_split() %>%
  setNames(unique(df0$trap)) %>% #name the items in the list with the trap name
  keep(~ nrow(.) > 2) #remove samples with 2 or less postive sequences from
                      #that pool # nolint


# Create a list splitting by trap and year
fa_list <- df_list %>%
  lapply(function(group) {
    # Extract relevant sequences from fa0
    fa0[names(fa0) %in% group$accession]
  })

# Function to calculate the average pairwise distance for each group
calculate_avg_pairwise_diff <- function(fa_group) {
  # Calculate the pairwise distance matrix
  dist_matrix <- ape::dist.dna(fa_group, model = "K80",
                              pairwise.deletion = TRUE)

  # Convert the distance matrix to a vector (excluding the diagonal)
  dist_vector <- as.vector(dist_matrix)
  dist_vector <- dist_vector[!is.na(dist_vector)] # Remove NA values (if any)

  # Return the average pairwise distance
  mean(dist_vector)
}

# Apply the function to each group in fa_list and store the results
avg_pairwise_diffs <- lapply(fa_list, calculate_avg_pairwise_diff)

df_diff <- enframe(avg_pairwise_diffs,
                   name = "trap",
                   value = "avg_pairwise_diff") %>%
  transmute(trap = trap,
            diff = as.numeric(avg_pairwise_diff))

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#-------------------------- C A L C   V I   ------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

df_no_database_seq = df0 %>%
  filter(!accession %in% df_database$csu_id)

df_no_database_seq %>%
  group_by(year) %>%
  count()

df_database_seq = df_database %>%
  filter(csu_id %in% df0$accession)


df_vi = calc_vi(df_database, c("trap_id"))


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#-------------------- C A L C  T R A P   N U M B E R  ----------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


#get stats from trap data 
df_trap = df0 %>%
  group_by(trap, zone) %>%
  reframe(n_pos_seq = n(),
            years = list(unique(year)))


df_diff2 = left_join(df_diff, df_trap, by = "trap") %>%
  left_join(df_vi, by = c("trap" = "trap_id")) %>%
  filter(!is.na(pir))


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#-------------------- C H E C K  N U M B E R  C O R R  ----------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
r = round(cor(df_diff2$diff, df_diff2$n_pos_seq),3)

ggplot(df_diff2, aes(x = n_pos_seq, y = diff)) +
  geom_point() +
  geom_smooth() +
  ggtitle(paste("Genetic Difference within Traps Across All Years r = ", r)) +
  theme_classic()

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#-------------------- P I R    V S   G E N   D I F F  ----------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
r = round(cor(df_diff2$diff, df_diff2$pir),3)

ggplot(df_diff2, aes(x = diff, y = pir)) +
  geom_point() +
  geom_smooth(method = "lm") +
  ggtitle(paste("Genetic Difference vs PIR r = ", r)) +
  theme_classic()

mod_pir = lm(diff ~  pir, data = df_diff2)
summary(mod_pir)

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#-------------------- A B U N D    V S   G E N   D I F F  ----------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
r = round(cor(df_diff2$diff, df_diff2$abund),3)

ggplot(df_diff2, aes(x = diff, y = abund)) +
  geom_point() +
  geom_smooth(method = "lm") +
  ggtitle(paste("Genetic Difference vs VI r = ", r)) +
  theme_classic()

mod_abund = lm(diff ~  abund, data = df_diff2)
summary(mod_abund)

