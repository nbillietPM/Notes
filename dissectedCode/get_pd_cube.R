library(pdindicatoR)

ex_data <- retrieve_example_data()
tree <- ex_data$tree
cube <- ex_data$cube
grid <- ex_data$grid
pa <- ex_data$pa

matched <- taxonmatch(tree)
head(matched)
"
              search_string               unique_name approximate_match score  ott_id is_synonym  flags number_matches gbif_id
1     alfaroa costaricensis     Alfaroa costaricensis             FALSE     1  199041      FALSE                     1 7310550
2    alfaroa guanacastensis    Alfaroa guanacastensis             FALSE     1  199043      FALSE                     2      NA
3         alfaroa manningii         Alfaroa manningii             FALSE     1  199049      FALSE                     1 4205554
4        alfaroa williamsii        Alfaroa williamsii             FALSE     1 1064109      FALSE                     1 7310534
5                alfaropsis                Alfaropsis             FALSE     1  200433      FALSE barren              2      NA
6 allocasuarina acutivalvis Allocasuarina acutivalvis             FALSE     1  769753      FALSE                     1 2891875

              orig_tiplabel
1     Alfaroa costaricensis
2    Alfaroa guanacastensis
3         Alfaroa manningii
4        Alfaroa williamsii
5                Alfaropsis
6 Allocasuarina acutivalvis
"
matched_nona <- matched %>% dplyr::filter(!is.na(gbif_id))

mcube <- append_ott_id(tree, cube, matched_nona)

check_completeness(mcube)

mcube <- mcube %>%
  dplyr::filter(!is.na(ott_id))

aggr_cube_1 <- aggregate_cube(mcube, timegroup=NULL)
aggr_cube_2 <- aggregate_cube(mcube, timegroup=1)
aggr_cube_3 <- aggregate_cube(mcube, timegroup=5)


all_matched_sp <- unique(mcube[["orig_tiplabel"]])

typeof(all_matched_sp)
head(all_matched_sp)
"
[1] "Quercus rubra"     "Juglans nigra"     "Juglans regia"     "Castanea sativa"   "Quercus palustris" "Corylus maxima"
"
#MRCA returns an error when the all_matched_sp contains a NA value
#Error in while (!done) { : missing value where TRUE/FALSE needed
MRCA <- ape::getMRCA(tree, all_matched_sp)
MRCA
"
1] 582
"
PD_cube <- aggr_cube_1 %>%
  mutate(PD = unlist(purrr::map(aggr_cube_1$orig_tiplabels,
                                ~ calculate_faithpd(tree, unlist(.x), MRCA))))

pd1<-calculate_faithpd(tree, unlist(aggr_cube_1$orig_tiplabels), MRCA)
"
There were 50 or more warnings (use warnings() to see the first 50)
"
pd1
"
[1] 797.944
"
"
aggr_cube$orig_tiplabels ~ calculate_faithpd(tree, unlist(.x), MRCA)
  - an anonymous function that computes the Faith PD indicator
  - the functions takes aggr_cube$orig_tiplabels as the argument and places each of its elements at the .x position
  -
"
unlist(aggr_cube_1$orig_tiplabels)

pdList <- purrr::map(aggr_cube_1$orig_tiplabels, ~ calculate_faithpd(tree, unlist(.x), MRCA))
unlist(pdList)[1:25]
"[1]  87.03916  87.03916  87.03916  87.03916 201.32048 201.32048 369.69048 335.40440 378.72071 355.61901 222.26078 254.10048
[13] 393.05602  87.03916 226.85832 231.29101 221.53509  87.03916  87.03916  87.03916 294.26586  87.03916 174.07832  87.03916
[25]  87.03916"

PD_cube[1,]$

