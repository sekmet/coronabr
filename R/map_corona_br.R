#' Mapa do número de casos por estado
#'
#' Esta função faz o mapa do número de casos por estado brasileiro.
#'
#' @inheritParams plot_corona_br
#' @param prop_pop Lógico. Exibir gráfico com número de casos proporcional à população? Padrão prop_pop = TRUE
#'
#' @export
#'
#' @importFrom brazilmaps get_brmap
#' @importFrom sf st_as_sf
#' @importFrom rlang .data

map_corona_br <- function(df,
                          prop_pop = TRUE){
  # puxando a data mais atualizada
  df$date <- as.Date(df$date)
  datas <- plyr::count(df$date)
  datas$lag <- datas$freq - dplyr::lag(datas$freq)
  if (datas$lag[which.max(datas$x)] < 0) {
    data_max <- max(datas$x) - 1
  } else {
    data_max <- max(datas$x)
  }
  df <- df %>%
    filter(.data$date == data_max)
  df$Casos <- df$confirmed
  # proporcao de casos por 100k
  df$`Casos (por 100 mil hab.)` <- df$confirmed_per_100k_inhabitants
  df$State <- df$city_ibge_code
  br <- brazilmaps::get_brmap(geo = "State",
                              class = "sf")

  br_sf <- sf::st_as_sf(br) %>%
    merge(df, by = "State")
  # mapa
  mapa <- tmap::tm_shape(br) +
    tmap::tm_fill(col = "white") +
    tmap::tm_borders() +
    tmap::tm_shape(br_sf) +
    tmap::tm_fill() +
    tmap::tm_borders() +
    if (prop_pop == TRUE) {
      tmap::tm_symbols(size = "Casos (por 100 mil hab.)",
                       col = "red",
                       border.col = "red",
                       scale = 2,
                       alpha = 0.7)
    } else {
      tmap::tm_symbols(size = "Casos",
                       col = "red",
                       border.col = "red",
                       scale = 2,
                       alpha = 0.7)
    }
  mapa
}
