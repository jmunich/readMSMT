Úvod
----
Tento tutorial lze v plnější podobě najít zde: https://jmunich.github.io/readMSMT/

Účel balíčku readMSMT je poskytnout nástroj zjednodušující práci s daty
z výkazů sbíraných MŠMT. Jelikož data vyžádatelná občanem mohou nabývat
podoby až několika set excelových tabulek, readMSMT vytváří prostředí,
které nevyžaduje zásadní úpravy v původních datech a na vyžádání vrací
proměnné z let a výkazů vybraných uživatelem v přehledné podobě. Účel
balíčku je následující:

1.  Vytvořit mapu uložených dat
2.  Usnadnit indexování a vyhledávání dostupnosti proměnných
3.  Na povel vrátit vyžádané proměnné

Balíček readMSMT operuje na základě balíčků dplyr a readxl. Funkce
využívají syntax a funkce z tidyverse, ale lze s nimi pracovat i bez
znalosti těchto balíčků.

Začněte instalací balíčku:

    devtools::install_github("jmunich/readMSMT")

A pokračujte jeho spuštěním:

    library(readMSMT)

Využití
-------

### O výkazech MŠMT

První krok je získání samotných dat, která v době napsání balíčku nejsou
dostupná online. Data lze získat buď přátelským kontaktování MŠMT, nebo
formálně přes žádost podle zákona č. 106/1999 Sb., O svobodném přístupu
k informacím (vzor žádosti by měl být snadno dohledatelný). Data by měla
být zorganizována podle níže popsaného kódování. Po získání stačí data
uložit do jedné složky.

Data MŠMT jsou sbírána skrze výkazy vyplňované řediteli škol. Data z
jednotlivých výkazů za každý rok jsou často rozdělená do několika
excelových tabulek (sheets). Balíček operuje s názvy těchto tabulek.
Názvy tabulek by měly v zálkladní podobě dodržovat následující formát:
vXXYYaaa. Každý kód začíná písmenem “v”. XX reprezentuje číslo výkazu a
YY rok. Balíček obsahuje funkci, která vrací přehled výkazů s popisy
kódů. Pro přepnutí místního locale do UTF-8 encoding (pro práci se
speciálními symboly v Českém jazyce, jako je ‘Š’) můžete využít funkci
set\_cz():

    set_cz()

    ## [1] "LC_COLLATE=English_United States.1250;LC_CTYPE=English_United States.1250;LC_MONETARY=English_United States.1250;LC_NUMERIC=C;LC_TIME=English_United States.1250"

    guide <- form_codes()
    ## set_cz lze využít i přímo ve form_codes(cz = TRUE)
    print(guide)

    ## # A tibble: 23 x 3
    ##    popis                                             kod_simple kod_msmt
    ##    <chr>                                             <chr>      <chr>   
    ##  1 Materská škola 30.9.                              V01        S 1-01  
    ##  2 Školní družina/klub 31.10.                        V02        Z 2-01  
    ##  3 Základní Škola 30.9.                              V03        M 3     
    ##  4 MŠ-ZŠ pri zdravotnickém zarízení 30.9.            V04        S 4-01  
    ##  5 Prihlášení a prijatí na konzervatore 30.9.        V05        S 5-01  
    ##  6 Strední škola 30.9.                               V08        M 8     
    ##  7 Konzervator 30.9.                                 V09        M 9     
    ##  8 Vyšší odborná škola 30.9.                         V10        M 10    
    ##  9 Reditelství škol 30.9.                            V13        M 13-01 
    ## 10 Zarízení pro výkon ústavní-ochrané výchovy 31.10. V14        M 14-01 
    ## # ... with 13 more rows

Mezi hodnotami kod\_simple lze najít výše popsané hodnoty vXX pro další
vyhledávání.

Pod znaky aaa bývá specifický podkód tabulky. Dělení na tabulky s
podkódy ale není napříč lety konzistentní. Například data z výkazu M-03
za rok 2019 mohou být rozdělena do tabulek se jmény v0319a, v0319b,
v0319c, zatímco v předchozím roce byla dostupná pouze v tabulkách v0318a
a v 0318b.

Setup
-----

Jednotlivé tabulky poskytuje MŠMT buď ve formátu .xls nebo .xlsx. Z toho
důvodu readMSMT využívá funkci read\_excel() z balíčku readxl. Opakované
pročítání velkého počtu excelových tabulek ve snaze najít hledané
proměnné může být výpočetně zdlouhavé. Proto doporučujeme jednorázové
vytvoření mapy složek s daty, která shrne výskyty proměnných v
jednotlivých dokumentech a umožní efektivnější načítání dat. Funkce
map\_folders() takové shrnutí vytváří. Stačí ji spustit jednou při
prvním použití balíčku a následně jen při provádění jakýchkoliv změn
struktury složky s daty nebo obsahu datových souborů.

### Vytvoření mapy souborů a proměnných

Funkce map\_folders() vytvoří soubor *MSMT\_data\_map.RDATA*, který bude
uložen v pracovním direktoriáři k načtení při dalším využtí dat.
Vytvoření souboru může zabrat nějaký čas. Když se program dostane k
pročítání jednotlivých souborů, začne svůj pokrok zobrazovat v konzoli.
Existuje několi způsobů, jak lze mapu vytvořit. Vytvoříte-li mapu s
uložením, stačí ji vytvořit pouze jednou (a poté znovu až při přidání
nových souborů do složky). Ve funkci lze specifikovat, kde se data
nachází (*location*), zda (a kam) má být mapa uložena (*save\_map*) a
zda má být navrácen objekt s mapou (*return\_map*). Následují příklady
využití funkce.

Pro vytvoření mapy, je-li složka s daty podsložkou pracovního
direktoriáře:

    map_folders()

Pro vytvoření mapy, je-li složka s daty podsložkou jiného direktoriáře

    map_folders(location = "E:/EDU/Data/data/MSMT/") ## Vložte vlastní adresu

Pro vytvoření mapy konkrétní složky, její uložení v konkrétní složce a
vytvoření objektu **my\_map** s mapou

    my_map <- map_folders(location = "E:/EDU/Data/data/MSMT/", save_map = "E:/EDU/Data/", return_map = TRUE)

Mapu lze kdykoliv vytvořit i jako objekt bez ukládání nebo přepisování
souboru

    my_map <- map_folders(save_map = FALSE, return_map = TRUE)

### Načtení mapy

Po uložení lze objekt s mapou kdykoliv načíst, buď za použití plné
adresy…

    my_map <- readRDS("C:/EDU/Data/MSMT_data_map.RDATA")

…nebo, je-li soubor v pracovním direktoriáři, názvem souboru:

    my_map <- readRDS("MSMT_data_map.RDATA")

### Struktura mapy

Mapa dat obsahuje tři objekty. První je tabulka *meta\_data*, která
shrnuje lokace relevantních souborů, název tabulky a jeho verzi v
lowercase (sheet\_name a sheet), kód výkazu (form), rok (year) a počet
výskytů tabulky v datech pro případ duplikátů (occurrences).

    my_map$meta_data

    ## # A tibble: 743 x 6
    ## # Groups:   sheet [585]
    ##    directory                          sheet_name sheet   form  year  occurrences
    ##    <chr>                              <chr>      <chr>   <chr> <chr>       <int>
    ##  1 E:/EDU/Data/data/MSMT//2011_12/v0~ v0111_1    v0111_1 v01   11              1
    ##  2 E:/EDU/Data/data/MSMT//2011_12/v0~ v0111_2    v0111_2 v01   11              1
    ##  3 E:/EDU/Data/data/MSMT//2011_12/v0~ v0111o     v0111o  v01   11              1
    ##  4 E:/EDU/Data/data/MSMT//2011_12/v0~ v0211      v0211   v02   11              1
    ##  5 E:/EDU/Data/data/MSMT//2011_12/v0~ v0211o     v0211o  v02   11              1
    ##  6 E:/EDU/Data/data/MSMT//2011_12/v0~ v0311a_1   v0311a~ v03   11              1
    ##  7 E:/EDU/Data/data/MSMT//2011_12/v0~ v0311a_2   v0311a~ v03   11              1
    ##  8 E:/EDU/Data/data/MSMT//2011_12/v0~ v0311a_3   v0311a~ v03   11              1
    ##  9 E:/EDU/Data/data/MSMT//2011_12/v0~ v0311a_4   v0311a~ v03   11              1
    ## 10 E:/EDU/Data/data/MSMT//2011_12/v0~ v0311a_5   v0311a~ v03   11              1
    ## # ... with 733 more rows

Další dva objekty *varlist* a *varlist\_lc* obsahují listy s názvy
proměnných v jednotlivých tabulkách. Objekt varlist obsahuje původní
názvy proměnných, objekt varlist\_lc obsahuje názvy transformované do
lowercase, pro případ rozdílů mezi tabulkami.

    ## Prvních dvacet proměnných první tabulky
    head(my_map$varlist[[1]], 20)

    ##  [1] "idc"       "red_izo"   "izo"       "list"      "izonew"    "zriz"     
    ##  [7] "ulice"     "misto"     "typ"       "spr_urad3" "vusc"      "jazyk_s"  
    ## [13] "rok"       "nvusc"     "ikf"       "zrus"      "zar_naz"   "dp"       
    ## [19] "sp"        "sp_skoly"

Využití
-------

Když je mapa vytvořena nebo načtena, funkce balíčku s její pomocí
identifikuje soubory obsahující vyhledávané proměnné a následně hodnoty
těchto proměnných načte do nového objektu. I za využití mapy může
vyhledávání trvat několik okamžiků.

### Názvy proměnných

Název proměnné lze vyčíst z tabulek ve pdf souborech výkazů. Struktura
názvu je **r číslo-řádku číslo-sloupce**. Například v tabulce I z výkazu
M-3 by celkový počet (sloupec 2) žáků kteří ukončili povinnou školní
docházku (řádek *0101*) byl pro každou školu uveden pod proměnnou
**r01012**.

<img src="Tabulka.png" width="90%" />

### Získávání většího počtu názvů proměnných

Vypisovat jména proměnných pro velké tabulky je mimořádná ztráta času.
Balíček proto obsahuje funkci *get\_table\_names*, která rekonstruuje
názvy proměnných v tabulce do snadno manipulovatelné matice. Funkce
obsahuje parametry **table\_ind**, který obsahuje indikátor tabulky
(zpravidla první dvě čísla u kódu řádku), *row\_inds* pro rozsah hodnot
řádků a *col\_inds* pro žádaný rozsah sloupců.

Některé tabulky obsahují proměnné vložené v pozdějších letech. Aby se
nenarušila původní struktura názvů proměnných, mívají takové koncovku
“a”, “b” etc. Tyto speciální indexy lze manuálně doplnit parametry
*extra\_row* a *extra\_col*.

Pro rekonstrukci výše uvedené tabulky lze použít:

    variable_names <- get_table_names(table_ind = "01", # Index tabulky
                    row_inds = c(1,4:11), # Uvedené řádky (v tabulce chybí 2 a 3)
                    col_inds = 2:5, # Sloupce
                    extra_row = "07a") # Speciální řádek 7a

    print(variable_names)

    ##       [,1]      [,2]      [,3]      [,4]     
    ##  [1,] "r01012"  "r01013"  "r01014"  "r01015" 
    ##  [2,] "r01042"  "r01043"  "r01044"  "r01045" 
    ##  [3,] "r01052"  "r01053"  "r01054"  "r01055" 
    ##  [4,] "r01062"  "r01063"  "r01064"  "r01065" 
    ##  [5,] "r01072"  "r01073"  "r01074"  "r01075" 
    ##  [6,] "r01082"  "r01083"  "r01084"  "r01085" 
    ##  [7,] "r0107a2" "r0107a3" "r0107a4" "r0107a5"
    ##  [8,] "r01092"  "r01093"  "r01094"  "r01095" 
    ##  [9,] "r01102"  "r01103"  "r01104"  "r01105" 
    ## [10,] "r01112"  "r01113"  "r01114"  "r01115"

Chceme-li pak získat například názvy všech proměnných s celkovými počtem
žáků z běžných tříd, stačí zvolit správný řádek vzniklé matice:

    my_varnames <- variable_names[,1]

    print(my_varnames)

    ##  [1] "r01012"  "r01042"  "r01052"  "r01062"  "r01072"  "r01082"  "r0107a2"
    ##  [8] "r01092"  "r01102"  "r01112"

### Dostupnost proměnných mezi lety

Máme-li názvy proměnných, můžeme využít mapu souborů ke zjištění jejich
dostupnosti napříč lety. Funkce get\_variable\_availability() přijímá
vektor vyžádaných proměnných a výkazů. Vrací list s tibbles obsahujícími
vyžádané proměnné v daných výkazech a jejich dostupnost. Jelikož stejný
název proměnné se může objevit mezi formuláři, je potřeba specifikovat,
kde mají být vyhledány.

    available <- get_variable_availability(variables = my_varnames,
                                                map = my_map, # Je-li mapa v pracovním direktoriáři, 
                                                              # není třeba ji uvádět
                                                forms = c("v03")) # Výkaz M-3

Funkce navrátí tibble s dostupností (je-li specifikován vektor výkazů,
vrátí tibble pro každý výkaz):

    available$tables$v03

    ## # A tibble: 8 x 11
    ##   year  r01012 r01042 r01052 r01062 r01072 r01082 r0107a2 r01092 r01102 r01112
    ##   <chr> <chr>  <chr>  <chr>  <chr>  <chr>  <chr>  <chr>   <chr>  <chr>  <chr> 
    ## 1 11    Yes    Yes    Yes    Yes    Yes    Yes    No      Yes    Yes    Yes   
    ## 2 12    Yes    Yes    Yes    Yes    Yes    Yes    No      Yes    Yes    Yes   
    ## 3 13    Yes    Yes    Yes    Yes    Yes    Yes    No      Yes    Yes    Yes   
    ## 4 14    Yes    Yes    Yes    Yes    Yes    Yes    No      Yes    Yes    Yes   
    ## 5 15    Yes    Yes    Yes    Yes    Yes    Yes    No      Yes    Yes    Yes   
    ## 6 16    Yes    Yes    Yes    Yes    Yes    Yes    Yes     Yes    Yes    Yes   
    ## 7 17    Yes    Yes    Yes    Yes    Yes    Yes    Yes     Yes    Yes    Yes   
    ## 8 18    Yes    Yes    Yes    Yes    Yes    Yes    Yes     Yes    Yes    Yes

Funkce dostupnost rovněž vyobrazuje pro snadnější kontrolu. Například u
speciální proměnné *r0107a2* lze vidět, že byla přidána až v roce 2016:

    available$plots$v03

![](README_files/figure-markdown_strict/unnamed-chunk-16-1.png)

### Získávání samotných proměnných

Když je jasno, jaké proměnné jsou třeba, lze použít funkci
*get\_variables()* k jejich získání. Funkce využije existující mapu,
vybere soubory obsahující žádoucí proměnné a pro každý rok vrátí tabulku
vyžádaných dat. Je-li v souboru pro jeden rok více relevantních souborů
(pravděpodobně duplikáty), funkce vybere první soubor a vydá upozornění.
Chybí-li nějaké proměnná v daném roce, vrátí se tabulka bez této
proměnné.

    tibble_list <- get_variables(variables = my_varnames, 
                  map = my_map, # Je-li mapa v pracovním direktoriáři, 
                                # není třeba ji uvádět 
                  joint = c("izo","red_izo", "vusc"), # Názvy dalších proměnných,
                                                      # například identifikátorů. Obsahuje
                                                      # defaultní hodnoty
                  forms = "v03", # Vektor (nebo samostatný character) žádaných výkazů
                  years = c("12","13","14","15","16","17","18") # Vektor obsahující žádoucí roky. 
                                                                # Prázdný argument prohledá 
                                                                # všechny dostupné roky
                  )

    ## Warning in get_variables(variables = my_varnames, map = my_map, joint =
    ## c("izo", : File(s) v0316a_1, v0317a_1 have two or more occurrences. Using the
    ## first file.

Funkce vrací list se dvěma objekty. První jsou průvodná meta\_data pro
využité soubory. Druhý objekt (variables) obsahuje tabulky se získanými
daty. Ke každé tabulce je přidána proměnná s příslušným rokem. Příklad
tabulek za roky 2012 a 2013:

    head(tibble_list$variables$v0312a_1)

    ## # A tibble: 6 x 13
    ##   year  izo   red_izo vusc  r01012 r01042 r01052 r01062 r01072 r01082 r01092
    ##   <chr> <chr> <chr>   <chr>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
    ## 1 12    0000~ 600023~ CZ05~      0      0      0      0      0      0      0
    ## 2 12    0000~ 600023~ CZ05~      0      0      0      0      0      0      0
    ## 3 12    0001~ 600096~ CZ05~     49      1      2     46      0     13     13
    ## 4 12    0001~ 600096~ CZ05~     19      0      3     16      0      0      0
    ## 5 12    0001~ 600001~ CZ05~     19      0      3     15      1      0      0
    ## 6 12    0002~ 600115~ CZ06~     22      0      0     22      0      3      3
    ## # ... with 2 more variables: r01102 <dbl>, r01112 <dbl>

    head(tibble_list$variables$v0313a_1)

    ## # A tibble: 6 x 13
    ##   year  izo   red_izo vusc  r01012 r01042 r01052 r01062 r01072 r01082 r01092
    ##   <chr> <chr> <chr>   <chr>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
    ## 1 13    0476~ 600035~ CZ01~     45      0      0     45      0     24     20
    ## 2 13    0476~ 600041~ CZ01~     27      0      0     27      0      4      3
    ## 3 13    0476~ 600041~ CZ01~     22      0      0     22      0     10      9
    ## 4 13    0476~ 600035~ CZ01~     28      0      0     28      0     11      9
    ## 5 13    0476~ 600035~ CZ01~     20      0      0     20      0      5      4
    ## 6 13    0476~ 600035~ CZ01~     35      0      4     31      0      0      0
    ## # ... with 2 more variables: r01102 <dbl>, r01112 <dbl>

Takto vzniklý list lze například za využití balíčku dplyr propojit do
jedné tabulky v long formátu. Toto je možné v případě, že všechny
proměnné v rámc rái roku byly uloženy ve stejném souboru.

Poznámka: Pokud by se za každý rok vrátilo více tabulek (například pokud
používám proměnné z tabulky I a z tabulky IX výkazu M-3), musím nejříve
pro každý rok propojit tyto tabulky přes identifikátory škol, které by
měly být v rámci let konzistentní, například funkcí
*dplyr::left\_join(x, y, by = “izo”)*.

    long_data <- dplyr::bind_rows(tibble_list$variables)
    head(long_data)

    ## # A tibble: 6 x 14
    ##   year  izo   red_izo vusc  r01012 r01042 r01052 r01062 r01072 r01082 r01092
    ##   <chr> <chr> <chr>   <chr>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
    ## 1 12    0000~ 600023~ CZ05~      0      0      0      0      0      0      0
    ## 2 12    0000~ 600023~ CZ05~      0      0      0      0      0      0      0
    ## 3 12    0001~ 600096~ CZ05~     49      1      2     46      0     13     13
    ## 4 12    0001~ 600096~ CZ05~     19      0      3     16      0      0      0
    ## 5 12    0001~ 600001~ CZ05~     19      0      3     15      1      0      0
    ## 6 12    0002~ 600115~ CZ06~     22      0      0     22      0      3      3
    ## # ... with 3 more variables: r01102 <dbl>, r01112 <dbl>, r0107a2 <dbl>

    unique(long_data$year)

    ## [1] "12" "13" "14" "15" "16" "17" "18"

S daty lze pak dělat psí kusy. Funkce *starts\_with()* a *ends\_with()*
z tidyverse (popř. *matches()* a regex) jsou obzvlášť šikovné, protože
se s nimi dají indexovat celé řádky nebo sloupce výkazových tabulek.
Například se můžeme podívat na počet všech žáků, kteří ukončili školní
docházku v sedmém ročníku ZŠ mezi regiony v čase.

    tab_1 <- as.vector(variable_names)

    tibble_list_1 <- get_variables(variables = tab_1, 
                  joint = "vusc",
                  forms = "v03")

    ## Warning in get_variables(variables = tab_1, joint = "vusc", forms = "v03"):
    ## File(s) v0316a_1, v0317a_1 have two or more occurrences. Using the first file.

    long_data_1 <- dplyr::bind_rows(tibble_list_1$variables)

    long_data_1 %>%
      mutate(vusc = substr(vusc, 1, 4)) %>%
      group_by(year, vusc) %>%
      summarise_all(sum) %>%
      select(vusc, starts_with("r0104")) %>% # Vybrat čtvrtý řádek
      select(vusc, matches("[a-z0-9]+2$|[a-z0-9]+4$")) %>% # Vybrat druhý a čtvrtý sloupec
      ungroup() %>%
      mutate(left_7 = rowSums(.[3:4])) %>%
      ggplot(aes(x = ordered(year), y = left_7, color = vusc, group = vusc)) +
      geom_point(show.legend = FALSE) +
      geom_path(show.legend = FALSE)

    ## Adding missing grouping variables: `year`Adding missing grouping variables:
    ## `year`

![](README_files/figure-markdown_strict/unnamed-chunk-20-1.png)
