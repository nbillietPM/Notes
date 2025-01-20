library(pdindicatoR)

ex_data <- retrieve_example_data()

"
Why is the example data loaded into a function? Functions should be as general as
possible
"
pa <- ex_data$pa
pa

grid <- ex_data$grid

grid[1,]
"
     id OBJECTID      CELLCODE EOFORIGIN NOFORIGIN Shape_Leng Shape_Area                       geometry
1 33848    33848 1kmE3974N3068   3974000   3068000       4000      1e+06 POLYGON ((3974000 3068000, ...
"
grid$geometry
cube <- ex_data$data
matched <- taxonmatch(tree)
matched_nona <- matched %>%
  dplyr::filter(!is.na(gbif_id))
mcube <- append_ott_id(tree, cube, matched_nona)
mcube <- mcube %>% dplyr::filter(!is.na(ott_id))


PD_cube <- get_pd_cube(mcube, tree, timegroup = 5, metric = "faith")

unlist(PD_cube[1,])

"
    eeacellcode     specieskeys         ott_ids    unique_names  orig_tiplabels              PD
"1kmE3993N3101"       "5414202"         "79360"   "Myrica gale"   "Myrica gale"      "87.03916"
"

PD_cube_geo <- right_join(grid, PD_cube,
                          by = join_by("CELLCODE" == "eeacellcode"))
unlist(PD_cube_geo[1,])

"
             id        OBJECTID        CELLCODE       EOFORIGIN       NOFORIGIN      Shape_Leng      Shape_Area     specieskeys
        "38579"         "38579" "1kmE3993N3101"       "3993000"       "3101000"          "4000"         "1e+06"       "5414202"
        ott_ids    unique_names  orig_tiplabels              PD       geometry1       geometry2       geometry3       geometry4
        "79360"   "Myrica gale"   "Myrica gale"      "87.03916"       "3993000"       "3993000"       "3994000"       "3994000"
      geometry5       geometry6       geometry7       geometry8       geometry9      geometry10
      "3993000"       "3101000"       "3102000"       "3102000"       "3101000"       "3101000"
"

bbox <- sf::st_bbox(PD_cube_geo)
bbox
"
   xmin    ymin    xmax    ymax
3993000 3080000 4032000 3120000
"

expansion_factor <- 0.20
bbox_expanded <- c(
  xmin = as.numeric(bbox["xmin"]) -
    (as.numeric(bbox["xmax"]) - as.numeric(bbox["xmin"])) * expansion_factor,
  xmax = as.numeric(bbox["xmax"]) +
    (as.numeric(bbox["xmax"]) - as.numeric(bbox["xmin"])) * expansion_factor,
  ymin = as.numeric(bbox["ymin"]) -
    (as.numeric(bbox["ymax"]) - as.numeric(bbox["ymin"])) * expansion_factor,
  ymax = as.numeric(bbox["ymax"]) +
    (as.numeric(bbox["ymax"]) - as.numeric(bbox["ymin"])) * expansion_factor
)

bbox_expanded
"
bbox_expanded
   xmin    xmax    ymin    ymax
3985200 4039800 3072000 3128000
"

bbox_expanded-bbox
"
   xmin    xmax    ymin    ymax
  -7800  959800 -960000    8000

The minimal coordinate should indeed decrease as we expand the box and the
maximal coordinate should increase
"

bbox["xmin"] - (bbox["xmax"] - bbox["xmin"]) * expansion_factor
"
xmin
3985200
"

world <- rnaturalearth::ne_countries(scale = "small", returnclass = "sf")
"
crs -> coordinate reference system

The value 3035 refers to the ETRS89-extended / LAEA Europe reference system

this line of code transforms the world map so that it is centered with the european
continent centrered on the map. If we wish for other people to, i.e. non europeans to
utilize this library than the option for different centering or CRS should be made
possible
"
world_3035 <- sf::st_transform(world, crs = 3035)

# Initialize lists to store maps and indicators
plots <- list()
indicators <- list()

# Calculate global min and max PD values for consistent color scale
pd_min <- min(PD_cube_geo$PD, na.rm = TRUE)
pd_max <- max(PD_cube_geo$PD, na.rm = TRUE)

#timegroup=NULL map

map_PD <- ggplot2::ggplot()

#Construct World Map
map_PD<- map_PD +
  ggplot2::geom_sf(data = world_3035, fill = "antiquewhite")
map_PD

"
geom_sf() is a function from the ggplot2 package that is used to create spatial
(geospatial) visualizations. Specifically, it is used for plotting sf
(simple features) objects, which represent spatial data structures like points,
lines, and polygons.

"SF" refers to the Simple Features standard used to store geometric objects
(points, lines, polygons, etc.) along with associated attributes.

This function creates the geometry (such as borders, areas, or points)
and uses the corresponding data for the plot.

Adds the PD data to the plot
"
map_PD<- map_PD +
  ggplot2::geom_sf(data = PD_cube_geo,
                   mapping = ggplot2::aes(fill = .data$PD))
map_PD

"
Change the colour coding of the PD data top the viridis colour scheme
"
map_PD<-map_PD+ggplot2::scale_fill_viridis_c(option = "B")
map_PD

"
Adds the outline
"
map_PD<-map_PD+ggplot2::geom_sf(data = pa, fill = NA, color = "lightblue",
                   linewidth = 0.03)
map_PD


map_PD<-map_PD+ggplot2::coord_sf(xlim = c(bbox_expanded["xmin"], bbox_expanded["xmax"]),
                    ylim = c(bbox_expanded["ymin"], bbox_expanded["ymax"]),
                    expand = FALSE)
map_PD

map_PD<-map_PD+ggplot2::xlab("Longitude") + ggplot2::ylab("Latitude")
map_PD

map_PD<-map_PD+ggplot2::theme(
    panel.grid.major = ggplot2::element_line(color = grDevices::gray(0.5),
                                             linewidth = 0.5),
    panel.background = ggplot2::element_rect(fill = "aliceblue"))
