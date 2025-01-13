MRCA <- ape::getMRCA(ex_data$tree, ex_data$tree$tip.label)
MRCA
"
the getMRCA function returns the index of the most recent common ancestor of a group of tips.
[1] 555
"
species <- c("Fagus lucida", "Castanopsis fabri", "Quercus_robur")

#Initialise an empty integer vector to store the indices of the tips into
#
tip_ids <- vector(mode = "integer", length = length(species))
tip_ids
"
[1] 0 0 0
"
seq_along(species)
"
[1] 1 2 3
"
for (i in seq_along(species)) {
  x <- which(tree$tip.label == species[i])
  print(x)
  if (length(x) > 0) {
    tip_ids[i] <- x
    print(tip_ids)
  } else {
    # Optionally, print a warning or assign a default value for missing matches
    warning(paste("Species", species[i], "not found in tree$tip.label"))
    tip_ids[i] <- NA  # Assign NA if the species is not found
  }
}
"
[1] 545
[1] 412
integer(0)
Warning message:
Species Quercus_robur not found in tree$tip.label

For the first two species a corresponding index can be found

This section can be rewritten as

which(!is.na(match(tree$tip.label, species)))
"

nodepath <- vector(mode = "list", length(tip_ids))
for (i in seq_along(tip_ids)) {
  x <- ape::nodepath(tree, MRCA, tip_ids[i])
  nodepath[[i]] <- x
}

"
Fetch the paths that the species of interests span to their MRCA

[[1]]
[1]  555  582  870 1099 1100 1101 1102  545

[[2]]
 [1] 555 582 870

Can be rewritten as

nodepath <- lapply(tip_ids, function(id) ape::nodepath(tree, MRCA, id))
"


