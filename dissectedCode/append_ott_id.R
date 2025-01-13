cubePath <- system.file("extdata", "0004018-241107131044228_Fagales1km.csv",
            package = "pdindicatoR")
cubePath

"
If you are using an older version which is before R 4.0, all columns that have character string
data are by default converted to factor types. When a column is in factor type, you can’t perform
many string operations hence, to keep string columns as character type use stringsAsFactors=FALSE
while reading a CSV file in R.

With a newer version on R, you don’t have to use this argument as R by default considers character
data as a string. I am using R version 4.0, hence all my string columns are converted to character
(chr) type. Use str() to display the structure of the DataFrame.
"
cube <- utils::read.csv(cubePath, stringsAsFactors = FALSE, sep = "\t")

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
species_keys <- cube %>% distinct(.data$specieskey)


"
left_join(x,y)
  - X in this case is the species_keys
"
mtable <- species_keys %>%
  left_join(matched[, c("ott_id", "gbif_id", "unique_name", "orig_tiplabel")],
            by = join_by("specieskey" == "gbif_id"))

head(mtable)
"
  specieskey  ott_id       unique_name     orig_tiplabel
1    2880539  791115     Quercus rubra     Quercus rubra
2    3054357 1072887     Juglans nigra     Juglans nigra
3    3054368  138717     Juglans regia     Juglans regia
4    5333294 1028994   Castanea sativa   Castanea sativa
5    8313153  538292 Quercus palustris Quercus palustris
6    2876049  747675    Corylus maxima    Corylus maxima
"

mcube <- cube %>%
  left_join(
    mtable[, c("specieskey", "ott_id", "unique_name", "orig_tiplabel")],
    by = join_by("specieskey" == "specieskey")
  )
