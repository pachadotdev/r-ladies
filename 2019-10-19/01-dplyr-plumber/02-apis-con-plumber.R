# paquetes ----

library(dplyr)
library(stringr)
library(glue)
library(RPostgreSQL)

# conexion a bbdd ----

con <- RPostgreSQL::dbConnect(
  drv = dbDriver("PostgreSQL"),
  dbname = parametros[["base"]],
  host = parametros[["host"]],
  user = parametros[["user"]],
  password = parametros[["pass"]]
)

# comunidades ----

load("ots_communities.rda")

# limpiar inputs ----

clean_char_input <- function(x, i, j) {
  y <- iconv(x, to = "ASCII//TRANSLIT", sub = " ")
  y <- str_replace_all(y, "[^[:alpha:]-]", " ")
  y <- str_squish(y)
  y <- str_trim(y)
  y <- str_to_lower(y)
  y <- str_sub(y, i, j)
  
  return(y)
}

# anios disponibles en bbdd

min_year <- dbGetQuery(con, glue_sql("SELECT MIN(year) FROM public.hs07_yr")) %>% as.numeric()
max_year <- dbGetQuery(con, glue_sql("SELECT MAX(year) FROM public.hs07_yr")) %>% as.numeric()

# titulos ----

#* @apiTitle Demo de API usando tradestatistics.io
#* @apiDescription Proporciona datos de comercio internacional

# YRPC --------------------------------------------------------------------

#* Echo back the result of a query on yrpc table
#* @param y Anio
#* @param r ISO del informante
#* @param p ISO del socio
#* @get /yrpc_simplificada

function(y = NULL, r = NULL, p = NULL) {
  y <- as.integer(y)
  r <- clean_char_input(r, 1, 3)
  p <- clean_char_input(p, 1, 3)

  if (!y >= min_year | !y <= max_year) {
    return("El anio especificado no es valido, mira la documentacion en tradestatistics.io")
    stop()
  }
  
  if (nchar(r) != 3) {
    return("El codigo ISO de origen especificado no es valido, mira la documentacion en tradestatistics.io")
    stop()
  }
  
  if (nchar(p) != 3) {
    return("El codigo ISO de destino especificado no es valido, mira la documentacion en tradestatistics.io")
    stop()
  }
  
  query <- glue_sql(
    "
    SELECT *
    FROM public.hs07_yrpc
    WHERE year = {y}
    ",
    .con = con
  )
  
  if (r != "all" & nchar(r) == 3) {
    query <- glue_sql(
      query,
      " AND reporter_iso = {r}",
      .con = con
    )
  }
  
  if (p != "all" & nchar(p) == 3) {
    query <- glue_sql(
      query,
      " AND partner_iso = {p}",
      .con = con
    )
  }
  
  data <- dbGetQuery(con, query)
  
  if (nrow(data) == 0) {
    data <- tibble(
      year = y,
      reporter_iso = r,
      partner_iso = p,
      product_code = c,
      observation = "No data available for these filtering parameters"
    )
  } else {
    data <- data %>% 
      left_join(ots_communities) %>% 
      group_by(reporter_iso, partner_iso, community_name, community_color) %>% 
      summarise(
        export_value_usd = sum(export_value_usd, na.rm = T),
        import_value_usd = sum(import_value_usd, na.rm = T)
      )
  }
  
  return(data)
}
