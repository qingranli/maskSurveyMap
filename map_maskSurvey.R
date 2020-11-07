rm(list=ls())
gc()

library(tidyverse)
library(data.table)
library(sf)
library(tmap)
library(tidycensus)

# download data ===============================================================
dt_url = "https://raw.githubusercontent.com/nytimes/covid-19-data/master/mask-use/mask-use-by-county.csv"
dt <- fread(dt_url)

colnames(dt)
glimpse(dt) # nrow = 3142

# P = a random encounter wears mask
dt <- dt %>% mutate(pWear = 1*ALWAYS + 0.8*FREQUENTLY + 0.5*SOMETIMES 
                    + 0.2*RARELY + 0*NEVER)

## get the spatial data (with "shifted" geo) for county
data("county_laea", package = "tidycensus")
cnty_dt = county_laea %>% mutate(COUNTYFP = as.numeric(GEOID))


# merge with dt by FIPS =======================================================
shp_plot <- cnty_dt %>% left_join(dt, by = 'COUNTYFP') %>%
  arrange(GEOID) %>% 
  mutate(STFIPS = str_sub(GEOID,1,2)) %>% 
  filter(!is.na(pWear))
glimpse(shp_plot)


# plot county map =============================================================
pMAP <- tm_shape(shp_plot) + 
  tm_polygons(col = "pWear", id = "NAME",
              palette = "GnBu", 
              border.col = "white", border.alpha = 0,
              legend.hist = TRUE,
              title = "probability")

# add state border ------------------------------------------------------------
states <- shp_plot %>% select(STFIPS, geometry) %>% group_by(STFIPS) %>% summarise()
pMAP1 <- pMAP + tm_shape(states) + tm_borders(col = "white", lwd = 1)

# layout of plot --------------------------------------------------------------
pMAP2 <- pMAP1 + tm_layout(main.title = "Probability that a random encounter wears mask",
                         main.title.position = "center",
                         main.title.size = 1.4,
                         main.title.fontface = "bold",
                         frame = FALSE,
                         legend.outside = TRUE,
                         legend.hist.width = 1.1
                         )

pMAP2

# save map ====================================================================
png("Map_NYT_maskSurvey.png", res = 200, width = 11, height = 5, units = "in")
pMAP2
dev.off()



###############################################################################
# Plot and View in interactive mode (set shift_geo = F) =======================
cnty_dt = get_acs("county", variables = "B00001_001", year = 2018,
                  output = "tidy", geometry = TRUE, shift_geo = FALSE) %>%
  rename('pop' = estimate) %>%
  mutate(COUNTYFP = as.numeric(GEOID)) %>%
  select(-variable)

shp_plot <- cnty_dt %>% left_join(dt, by = 'COUNTYFP') %>%
  arrange(GEOID) %>% 
  mutate(STFIPS = str_sub(GEOID,1,2))

pMAP3 <- tm_shape(shp_plot) + 
  tm_polygons(col = "pWear", id = "NAME",
              palette = "GnBu", 
              border.col = "white", border.alpha = 0.5,
              title = "probability") + 
  tm_layout(main.title = "Probability that a random encounter wears mask",
            main.title.position = "center",
            main.title.size = 1.4,
            main.title.fontface = "bold"
            )

tmap_mode("view") # tmap_mode("plot")
pMAP3

# save interactive map ========================================================
tmap_save(pMAP3, "Map_NYT_maskSurvey.html")
