# Load packages
library(pdindicatoR)

library(sf)      # working with spatial objects
library(dplyr)   # data wrangling

ex_data <- retrieve_example_data()
tree <- ex_data$tree
cube <- ex_data$cube
grid <- ex_data$grid
pa <- ex_data$pa

options(width = 1000)
plot(tree, cex = 0.35, y.lim = 100)

head(cube)

matched <- taxonmatch(tree)
head(matched)

matched_nona <- matched %>%
  dplyr::filter(!is.na(gbif_id))

mcube <- append_ott_id(tree, cube, matched_nona)
head(mcube)

check_completeness(mcube)

mcube <- mcube %>%
  dplyr::filter(!is.na(ott_id))

PD_cube <- get_pd_cube(mcube, tree, metric = "faith")

PDindicator <- generate_map_and_indicator(PD_cube, grid, "Fagales")
PDindicator

PDindicator <- generate_map_and_indicator(
  PD_cube,
  grid,
  "Fagales",
  cutoff = 450)

plots <- PDindicator[[1]]
indicators <- PDindicator[[2]]
print(plots)

print(indicators)
