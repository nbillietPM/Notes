columns_to_select <- c("year", "eeacellcode", "specieskey", "ott_id",
                       "unique_name", "orig_tiplabel")
typeof(columns_to_select)
"
intersect: Intersection of Subsets

Calculates the intersection of subsets of a probability space.
Comparisons are made row-wise, so that in the data frame case, intersect(A,B) is
a data frame with those rows that are both in A and in B.
"
intersect(columns_to_select, colnames(mcube))
#Returns the same vector as columns_to_select, code is redundant

simpl_cube <- mcube[, intersect(columns_to_select, colnames(mcube))]


min_year <- min(simpl_cube$year)

timegroup<-1
aggr_cube
list(unique(aggr_cube$specieskey))
"
The missing(timegroup) condition is redundant in this case as the default value is
NULL. If no other value is given to the timegroup variable then the function will execute
as the is.null condition gets fulfilled.
"
if (!("year" %in% colnames(simpl_cube))
) {
  aggr_cube <- simpl_cube %>%
    group_by(.data$eeacellcode) %>%
    reframe(
      specieskeys = list(unique(.data$specieskey)),
      ott_ids = list(unique(.data$ott_id)),
      unique_names = list(unique(.data$unique_name)),
      orig_tiplabels = list(unique(.data$orig_tiplabel))
    )

  # When timegroup ==1
} else if (timegroup == 1) {
  aggr_cube <- simpl_cube %>%
    arrange(.data$year) %>% #sort the according to the year
    group_by(.data$eeacellcode, .data$year) %>% #Group the data together based on the grid cell and year
    reframe(
      specieskeys = list(unique(.data$specieskey)),
      ott_ids = list(unique(.data$ott_id)),
      unique_names = list(unique(.data$unique_name)),
      orig_tiplabels = list(unique(.data$orig_tiplabel))
    ) %>%
    rename(period = .data$year)
} else {

  # Calculate the 5-year period for each row
  period <- NULL
  aggr_cube <- simpl_cube %>%
    arrange(.data$year) %>%
    mutate(period = min_year + 5 * ((.data$year - min_year) %/% 5)) %>%
    mutate(period = paste(period, period + 4, sep = "-")) %>%
    group_by(.data$period, .data$eeacellcode) %>%
    reframe(
      specieskeys = list(unique(.data$specieskey)),
      ott_ids = list(unique(.data$ott_id)),
      unique_names = list(unique(.data$unique_name)),
      orig_tiplabels = list(unique(.data$orig_tiplabel))
