#|------------------------------------------------------------------------------------------|
#|                                                                     Lind_hawkers_ggmap.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The original post came from http://rpubs.com/Curtis/hawkers.                          |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script originated from the above, however the data file 'hawkers.csv'      |
#|          contain made-up longitudes, as the original longitude has been cut to 1 decimal.|
#|------------------------------------------------------------------------------------------|
require(ggmap)
require(mapproj)
source("C:/Users/denbrige/100 FxOption/103 FxOptionverback/080 Fx Git/R-source/PlusFile.R")

hawkers <- fileReadDfr("hawkers")
hawkers$latitude <- as.numeric(hawkers$latitude)
hawkers$longitude <- as.numeric(hawkers$longitude)

pg <- get_map(location='George Town, Penang',  
              zoom = 14,       # ranges from 0 (whole world) to 21 (building)
              source='stamen', # try 'google' or 'osm'      
              maptype='toner', 
              color='color'
) 

# the ggmap() function will convert your map data into a ggplot object
# the arguments to include your data at this stage are not essential, but 
# can make it easier to add layers (such as 'geoms') later on 
PG <- ggmap(pg, extent='panel', 
            base_layer=ggplot(hawkers, aes(x=longitude, y=latitude))
            )
PG <- PG + geom_point(color = "red", size = 4)
print(PG)

lon <- hawkers$longitude
lat <- hawkers$latitude
box <- make_bbox(lon, lat, f = 0.1)
box

# as before, we download our map data and convert it into a 'gg' object.
# note that because we are explicitly setting our map boundaries,
# adjusting the zoom in this case will change the resolution of the base
# map not the 'zoom' per se (likely to add further details, too)
pg <- get_map(location = box, zoom = 16, source = "stamen", maptype = "toner", 
              color = "color")

PG <- ggmap(pg, extent = "panel", base_layer = ggplot(hawkers, aes(x = longitude, 
                                                                   y = latitude)))

# here is where we can change the 'aesthetics' of our points
PG <- PG + geom_point(aes(color = Category), size = 5, alpha = 0.8)

# then a little bit of cosmetic work...  change category colors, titles,
# etc
PG <- PG + scale_colour_brewer(palette = "Set1")

PG <- PG + labs(title = "Recommended hawkers around George Town, Penang", x = "Longitude", 
                y = "Latitude")

PG <- PG + theme(plot.title = element_text(hjust = 0, vjust = 1, face = c("bold")), 
                 legend.position = "right")

print(PG)