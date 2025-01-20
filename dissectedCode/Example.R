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
"
  year   eeacellcode specieskey           species establishmentmeans degreeofestablishment pathway occurrences distinctobservers
1 2024 1kmE3996N3087    2880539     Quercus rubra                                       NA      NA           1                 1
2 2024 1kmE3997N3088    3054357     Juglans nigra                                       NA      NA           2                 1
3 2024 1kmE3997N3090    3054368     Juglans regia                                       NA      NA           1                 1
4 2024 1kmE3997N3100    2880539     Quercus rubra                                       NA      NA           1                 1
5 2024 1kmE3997N3104    5333294   Castanea sativa                                       NA      NA           1                 1
6 2024 1kmE3997N3104    8313153 Quercus palustris                                       NA      NA           1                 1
"
matched <- taxonmatch(tree)
head(matched)
"
 search_string               unique_name approximate_match score  ott_id is_synonym  flags number_matches gbif_id             orig_tiplabel
1     alfaroa costaricensis     Alfaroa costaricensis             FALSE     1  199041      FALSE                     1 7310550     Alfaroa costaricensis
2    alfaroa guanacastensis    Alfaroa guanacastensis             FALSE     1  199043      FALSE                     2      NA    Alfaroa guanacastensis
3         alfaroa manningii         Alfaroa manningii             FALSE     1  199049      FALSE                     1 4205554         Alfaroa manningii
4        alfaroa williamsii        Alfaroa williamsii             FALSE     1 1064109      FALSE                     1 7310534        Alfaroa williamsii
5                alfaropsis                Alfaropsis             FALSE     1  200433      FALSE barren              2      NA                Alfaropsis
6 allocasuarina acutivalvis Allocasuarina acutivalvis             FALSE     1  769753      FALSE                     1 2891875 Allocasuarina acutivalvis
>
"

matched_nona <- matched %>%
  dplyr::filter(!is.na(gbif_id))
head(matched_nona)
"
                search_string                 unique_name approximate_match score  ott_id is_synonym flags number_matches gbif_id
1       alfaroa costaricensis       Alfaroa costaricensis             FALSE     1  199041      FALSE                    1 7310550
2           alfaroa manningii           Alfaroa manningii             FALSE     1  199049      FALSE                    1 4205554
3          alfaroa williamsii          Alfaroa williamsii             FALSE     1 1064109      FALSE                    1 7310534
4   allocasuarina acutivalvis   Allocasuarina acutivalvis             FALSE     1  769753      FALSE                    1 2891875
5 allocasuarina brachystachya Allocasuarina brachystachya             FALSE     1  769751      FALSE                    1 2891867
6    allocasuarina campestris    Allocasuarina campestris             FALSE     1  769759      FALSE                    1 2891864

                orig_tiplabel
1       Alfaroa costaricensis
2           Alfaroa manningii
3          Alfaroa williamsii
4   Allocasuarina acutivalvis
5 Allocasuarina brachystachya
6    Allocasuarina campestris
"

mcube <- append_ott_id(tree, cube, matched_nona)
head(mcube)
"
  year   eeacellcode specieskey           species establishmentmeans degreeofestablishment pathway occurrences distinctobservers  ott_id
1 2024 1kmE3996N3087    2880539     Quercus rubra                                       NA      NA           1                 1  791115
2 2024 1kmE3997N3088    3054357     Juglans nigra                                       NA      NA           2                 1 1072887
3 2024 1kmE3997N3090    3054368     Juglans regia                                       NA      NA           1                 1  138717
4 2024 1kmE3997N3100    2880539     Quercus rubra                                       NA      NA           1                 1  791115
5 2024 1kmE3997N3104    5333294   Castanea sativa                                       NA      NA           1                 1 1028994
6 2024 1kmE3997N3104    8313153 Quercus palustris                                       NA      NA           1                 1  538292

        unique_name     orig_tiplabel
1     Quercus rubra     Quercus rubra
2     Juglans nigra     Juglans nigra
3     Juglans regia     Juglans regia
4     Quercus rubra     Quercus rubra
5   Castanea sativa   Castanea sativa
6 Quercus palustris Quercus palustris
"

check_completeness(mcube)
"
The following species are not part of the provided phylogenetic tree:
   specieskey                 species
1     9148577            Alnus incana
2          NA
3     2880130         Quercus petraea
4     2880580          Quercus cerris
5     8288647 Pterocarya fraxinifolia
6     2879292         Quercus rosacea
7     2879520        Quercus conferta
8     2876571         Alnus pubescens
9     7797155           Alnus hirsuta
10    2880652         Quercus phellos
"

mcube <- mcube %>%
  dplyr::filter(!is.na(ott_id))
head(mcube)
"year   eeacellcode specieskey           species establishmentmeans degreeofestablishment pathway occurrences distinctobservers  ott_id
1 2024 1kmE3996N3087    2880539     Quercus rubra                                       NA      NA           1                 1  791115
2 2024 1kmE3997N3088    3054357     Juglans nigra                                       NA      NA           2                 1 1072887
3 2024 1kmE3997N3090    3054368     Juglans regia                                       NA      NA           1                 1  138717
4 2024 1kmE3997N3100    2880539     Quercus rubra                                       NA      NA           1                 1  791115
5 2024 1kmE3997N3104    5333294   Castanea sativa                                       NA      NA           1                 1 1028994
6 2024 1kmE3997N3104    8313153 Quercus palustris                                       NA      NA           1                 1  538292
unique_name     orig_tiplabel
1     Quercus rubra     Quercus rubra
2     Juglans nigra     Juglans nigra
3     Juglans regia     Juglans regia
4     Quercus rubra     Quercus rubra
5   Castanea sativa   Castanea sativa
6 Quercus palustris Quercus palustris
"
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
