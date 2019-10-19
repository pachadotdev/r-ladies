# Packages ----------------------------------------------------------------

library(shiny)
library(dplyr)
library(highcharter)

# URLs --------------------------------------------------------------------

base_url <- "http://localhost:8080"

# Choices -----------------------------------------------------------------

# choices trick by Andrea Gao
# http://gytcrt.github.io/gytcrt.github.io/2016/08/11/RShiny-easily-passing-a-long-list-of-items-to-selectInput-choices/

available_years <- 1966:2018

available_years_min <- min(available_years)
available_years_max <- max(available_years)

available_reporters_iso <- c("per","chl","arg")

# Highcharts --------------------------------------------------------------

hc_export_menu <- list(
  list(text="Download PNG image",
       onclick=JS("function () { 
                  this.exportChart({ type: 'image/png' }); }")),
  list(text="Download JPEG image",
       onclick=JS("function () { 
                  this.exportChart({ type: 'image/jpeg' }); }")),
  list(text="Download SVG vector image",
       onclick=JS("function () { 
                  this.exportChart({ type: 'image/svg+xml' }); }")),
  list(text="Download PDF document",
       onclick=JS("function () { 
                  this.exportChart({ type: 'application/pdf' }); }"))
)
