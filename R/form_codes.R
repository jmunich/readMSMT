#' Get a tibble with form name legend
#'
#' Returns a guide to form codes
#'
#' @export
#' @import tidyverse
#' @import readxl
#' @examples
#' form_codes()

form_codes <- function(cz = TRUE){
  require(tidyverse)
  if(cz){
    set_cz()
  }

  mapa_vykazu<-list(
    popis=c(
      "Mateřská škola 30.9.",
      "Školní družina/klub 31.10.",
      "Základní Škola 30.9.",
      "MŠ-ZŠ při zdravotnickém zařízení 30.9.",
      "Přihlášení a přijatí na konzervatoře 30.9.",
      "Střední škola 30.9.",
      "Konzervatoř 30.9.",
      "Vyšší odborná škola 30.9.",
      "Ředitelství škol 30.9.",
      "Zařízení pro výkon ústavní-ochrané výchovy 31.10.",
      "Činnost střediska volného času 31.10.",
      "Činnost zařízení školního stravování 31.10.",
      "Jazyková škola 30.9.",
      "Školské ubytovací zařízení 31.10.",
      "Pedagogicko-psychologická poradna 30.9.",
      "Základní umělecká škola 30.9.",
      "Středisko praktického vyučování 30.9.",
      "Speciálně pedagogické centrum 30.9.",
      "Středisko výchovné péče 30.9.",
      "Podpůrná opatření",
      "Podpůrná opatření: změny",
      "Zápis k předškolnímu vzdělávání 31.5.",
      "Zahájení povinné školní docházky na ZŠ"
    ),
    kod_simple=c(
      "v01",
      "v02",
      "v03",
      "v04",
      "v05",
      "v08",
      "v09",
      "v10",
      "v13",
      "v14",
      "v15",
      "v17",
      "v18",
      "v19",
      "v23",
      "v24",
      "v27",
      "v33",
      "v34",
      "v43",
      "v44",
      "v51",
      "v53"
    ),
    kod_msmt=c(
      "S 1-01",
      "Z 2-01",
      "M 3",
      "S 4-01",
      "S 5-01",
      "M 8",
      "M 9",
      "M 10",
      "M 13-01",
      "M 14-01",
      "M 15-01",
      "Z 17-01",
      "S 18-01",
      "Z 19-01",
      "Z 23-01",
      "S 24-01",
      "Z 27-01",
      "Z 33-01",
      "Z 34-01",
      "R 43-01",
      "R 44-99",
      "S 51-01",
      "S 53-01"
    )
  )
  forms <- as_tibble(mapa_vykazu) %>%
    mutate(popis = enc2utf8(popis))
  return(forms)
}
