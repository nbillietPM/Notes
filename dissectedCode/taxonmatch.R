"
Taxonmatch function understanding
"
use("ape")
#Example data is included in the pdindicatoR package
tree_path <- system.file("extdata", "Fagales_species.nwk",
                         package = "pdindicatoR")

#On the local system it gives "C:/Users/niels/AppData/Local/R/win-library/4.4/pdindicatoR/extdata/Fagales_species.nwk"
tree_path

tree <- read.tree(tree_path)
print(tree)
"
Phylogenetic tree with 554 tips and 553 internal nodes.

Tip labels:
  Lophozonia_cunninghamii, Lophozonia_moorei, Lophozonia_menziesii, Nothofagus_x_alpina, Nothofagus_nervosa, Lophozonia_glauca, ...
Node labels:
  , '80', '35', '13', '14', '36', ...

Rooted; includes branch length(s).
"
#Extracts all labels from the leaves of the tree
tree_labels <- tree$tip.label

#Verify if any of the tree labels are of the format of ott[ddd...]
any(stringr::str_detect(tree_labels, "ott\\d+"))

taxa <- rotl::tnrs_match_names(tree_labels)
head(taxa)
"
            search_string             unique_name approximate_match score  ott_id is_synonym  flags number_matches
1 lophozonia cunninghamii Lophozonia cunninghamii             FALSE     1  862659      FALSE                     1
2       lophozonia moorei       Lophozonia moorei             FALSE     1  316858      FALSE                     1
3    lophozonia menziesii    Lophozonia menziesii             FALSE     1  316863      FALSE                     1
4     nothofagus x alpina     Nothofagus x alpina             FALSE     1 3931054      FALSE hybrid              1
5      nothofagus nervosa      Nothofagus nervosa             FALSE     1   80430      FALSE                     1
6       lophozonia glauca       Lophozonia glauca             FALSE     1  316852      FALSE                     1

Returns a table consisting of 8 variables
  - approximate_match
      -match_names function allows for 'fuzzy' name matching, assumption is that partial overlaps can be taken into account
"
#Create a new column to store gbif identifiers
taxa[, "gbif_id"] <- NA
i <- 1
for (id in taxa$ott_id) { #iterate over all ids
  if (is.na(id) == FALSE) { #check if id is a non NaN value
    tax_info <- rotl::taxonomy_taxon_info(id) #retrieve taxonomy info based on the id
    #returns a list of a list
    for (source in tax_info[[1]]$tax_sources) { #iterate over the taxonomy sources
      #use a regular expression to search for the gbif substring fixed matches the pattern as it is
      if (grepl("gbif", source, fixed = TRUE)) {
        #split up the source string into a gbif identifier?
        gbif <- stringr::str_split(source, ":")[[1]][2]
        #Assign the extracteed gbif id to a new column
        taxa[i, ]$gbif_id <- gbif
      }
    }
  }
  i <- i + 1
}

head(taxa)
"
            search_string             unique_name approximate_match score  ott_id is_synonym  flags number_matches gbif_id
1 lophozonia cunninghamii Lophozonia cunninghamii             FALSE     1  862659      FALSE                     1 2874928
2       lophozonia moorei       Lophozonia moorei             FALSE     1  316858      FALSE                     1 2874979
3    lophozonia menziesii    Lophozonia menziesii             FALSE     1  316863      FALSE                     1 2874917
4     nothofagus x alpina     Nothofagus x alpina             FALSE     1 3931054      FALSE hybrid              1    <NA>
5      nothofagus nervosa      Nothofagus nervosa             FALSE     1   80430      FALSE                     1    <NA>
6       lophozonia glauca       Lophozonia glauca             FALSE     1  316852      FALSE                     1 2874969
"
taxa$gbif_id <- as.integer(taxa$gbif_id)

original_df <- data.frame(
  #Extract all unique tree labels
  orig_tiplabel = unique(tree_labels),
  #Convert all labels to the lowercase format
  search_string = tolower(unique(tree_labels)))

#Analogously to the join operator in SQL. Do an inner join by search string
matched_result <- merge(taxa, original_df, by = "search_string", all.x = TRUE)
head(matched_result)
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
