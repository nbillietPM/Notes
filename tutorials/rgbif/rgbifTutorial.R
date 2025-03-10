, ,library(rgbif)
"
In order to use the rbgif interface we need to have
  - a GBIF username
  - a GBIF email linked to the username
  - a password for the account
All of this can be done on the GBIF website.

Searches on the database can be performed without providing a username, password and email.
However if we wish to download the data to our system locally these things need to be passed.
In the download functions these arguments are always passed as
  - user='userName'
  - pwd='password'
  - email='email'
However it is possible to edit your Rprofile to automatically include this in the
global namespace. Check out the blogpost
  https://docs.ropensci.org/rgbif/articles/gbif_credentials.html
"
#install.packages("usethis")
#usethis::edit_r_environ()

"
occ_search

Search function allows us to browse GBIF data without downloading it directly to
our system locally. It is limited to 100 000 entries to be queried before we need
to download the data
  - no user information is required to perform search action
  - no citation is generated to refer to the queried data
"

#basisOfRecord allows us to search based on the nature of the specimen in question
#PRESERVED_SPECIMEN FOSSIL_SPECIMEN LIVING_SPECIMEN HUMAN_OBSERVATION MACHINE_OBSERVATION MATERIAL_CITATION

occ_search(basisOfRecord = "PRESERVED_SPECIMEN") #single basisOfRecord
occ_search(basisOfRecord = "PRESERVED_SPECIMEN;HUMAN_OBSERVATION") #multiple basisOfRecords combined

#Prefered way of looking up data is with a usageKey instead of a scientific name

backBone <- name_backbone(name = "Calopteryx splendens") #Fetches the GBIF taxonomic backbone
colnames(backBone)
"
 [1] "usageKey"       "scientificName" "canonicalName"  "rank"           "status"
 [6] "confidence"     "matchType"      "kingdom"        "phylum"         "order"
[11] "family"         "genus"          "species"        "kingdomKey"     "phylumKey"
[16] "classKey"       "orderKey"       "familyKey"      "genusKey"       "speciesKey"
[21] "synonym"        "class"          "verbatim_name"
"
#backbone can be used to obtain the usageKey from the species of interest
occ_search(scientificName = "Calopteryx splendens")
#returns 500 matches of the 350885 available matches in the database
#using scientific name performs a checkup in the backend of the taxonKey
occ_search(taxonKey = name_backbone(name = "Calopteryx splendens")$usageKey) #equivalent and prefered way

enumeration_country() #lookup country codes

"
Searching by country is prefered over searching by continent due to the fact that
the continent field is not filled in when coordinates are available and are publisher
dependent
"
"
Searching for occurences from a specific continent should preferably be done using
the gadmGid or supply a bounding box or WKT polygon to geometry
"

#Test case for the canadian goose in belgium

taxonKey_canadianGoose <- name_backbone(name = "Branta canadensis")$usageKey #extract taxonkey

testCase <- occ_search(taxonKey = taxonKey_canadianGoose, country = "BE", basisOfRecord = "HUMAN_OBSERVATION") #filter results for belgium and human observations
colnames(testCase$data)
"
 [1] "key"                              "scientificName"                   "decimalLatitude"
 [4] "decimalLongitude"                 "issues"                           "datasetKey"
 [7] "publishingOrgKey"                 "installationKey"                  "hostingOrganizationKey"
[10] "publishingCountry"                "protocol"                         "lastCrawled"
[13] "lastParsed"                       "crawlId"                          "basisOfRecord"
[16] "occurrenceStatus"                 "taxonKey"                         "kingdomKey"
[19] "phylumKey"                        "classKey"                         "orderKey"
[22] "familyKey"                        "genusKey"                         "speciesKey"
[25] "acceptedTaxonKey"                 "acceptedScientificName"           "kingdom"
[28] "phylum"                           "order"                            "family"
[31] "genus"                            "species"                          "genericName"
[34] "specificEpithet"                  "taxonRank"                        "taxonomicStatus"
[37] "iucnRedListCategory"              "dateIdentified"                   "coordinateUncertaintyInMeters"
[40] "continent"                        "stateProvince"                    "year"
[43] "month"                            "day"                              "eventDate"
[46] "startDayOfYear"                   "endDayOfYear"                     "modified"
[49] "lastInterpreted"                  "references"                       "license"
[52] "isSequenced"                      "identifier"                       "facts"
[55] "relations"                        "isInCluster"                      "datasetName"
[58] "recordedBy"                       "identifiedBy"                     "geodeticDatum"
[61] "class"                            "countryCode"                      "recordedByIDs"
[64] "identifiedByIDs"                  "gbifRegion"                       "country"
[67] "publishedByGbifRegion"            "rightsHolder"                     "identifier.1"
[70] "http...unknown.org.nick"          "verbatimEventDate"                "collectionCode"
[73] "verbatimLocality"                 "gbifID"                           "occurrenceID"
[76] "taxonID"                          "catalogNumber"                    "institutionCode"
[79] "eventTime"                        "http...unknown.org.captive"       "identificationID"
[82] "name"                             "networkKeys"                      "individualCount"
[85] "datasetID"                        "samplingProtocol"                 "informationWithheld"
[88] "nomenclaturalCode"                "municipality"                     "identificationVerificationStatus"
[91] "language"                         "type"                             "vernacularName"
[94] "accessRights"                     "behavior"                         "lifeStage"
[97] "distanceFromCentroidInMeters"     "occurrenceRemarks"
"
unique(testCase$data$stateProvince)
"
[1] "Vlaanderen"              "East Flanders"           "West Flanders"
[4] "Antwerp"                 "Flemish Brabant"         "Limburg"
[7] "Brussels Capital Region"
"
unique(testCase$data$country)
"
[1] "Belgium"
"
unique(testCase$data$basisOfRecord)
"
[1] "HUMAN_OBSERVATION"
"

"
occ_download()
  * occ_download()
  * occ_download_prep()
  * occ_download_get()
  * occ_download_import()

utilizes the predicate helper functions to narrow down the query to the desired subset of data.
Setting up your credentials is necessary for downloading data from GBIF and automatically generates
a DOI code in order to reference the downloaded dataset

  https://docs.ropensci.org/rgbif/articles/getting_occurrence_data.html
"

#occ_download(pred("taxonKey", taxonKey$usageKey), user=GBIF_USER, pwd=GBIF_PWD, email=GBIF_EMAIL)
occ_download(pred_and(pred("taxonKey", taxonKey_canadianGoose),
                      pred("country", "BE"),
                      pred("basisOfRecord", "HUMAN_OBSERVATION")),
             format="SIMPLE_CSV")
"
<<gbif download>>
  Your download is being processed by GBIF:
  https://www.gbif.org/occurrence/download/0072342-241126133413365
  Most downloads finish within 15 min.
  Check status with
  occ_download_wait('0072342-241126133413365')
  After it finishes, use
  d <- occ_download_get('0072342-241126133413365') %>%
    occ_download_import()
  to retrieve your download.
Download Info:
  Username: nbilliet
  E-mail: niels.billiet@plantentuinmeise.be
  Format: SIMPLE_CSV
  Download key: 0072342-241126133413365
  Created: 2025-01-16T08:17:05.256+00:00
Citation Info:
  Please always cite the download DOI when using this data.
  https://www.gbif.org/citation-guidelines
  DOI: 10.15468/dl.dpncr5
  Citation:
  GBIF Occurrence Download https://doi.org/10.15468/dl.dpncr5 Accessed from R via rgbif (https://github.com/ropensci/rgbif) on 2025-01-16
"
occ_download_wait('0072342-241126133413365')

occDF <- occ_download_get("0072342-241126133413365") %>% occ_download_import()

occDF %>% nrow()
occDF %>% str()
