Úvod
----

Účel balíčku readMSMT je poskytnout nástroj zjednodušující práci s daty
z výkazů sbíraných MŠMT. Jelikož data vyžádatelná občanem mohou nabývat
podoby až několika set excelových tabulek, readMSMT vytváří prostředí,
které nevyžaduje zásadní úpravy v původních datech a na vyžádání vrací
proměnné z let a výkazů vybraných uživatelem v přehledné podobě. Účel
balíčku je následující:

1.  Vytvořit mapu uložených dat
2.  Na požádání vrátit vyžádané proměnné
3.  Usnadnit propojování s jinými datovými sety

Balíček readMSMT operuje na základě balíčků dplyr a readxl. Využívá
syntax a funkce z tidyverse, ale lze s ním pracovat i bez znalosti
těchto balíčků.

Začněte instalací balíčku:

    devtools::install_github("jmunich/readMSMT")

A pokračujte jeho spuštěním:

    library(readMSMT)

Využití
-------

Data MŠMT jsou sbírána skrze výkazy vyplňované řediteli škol. Data z
jednotivých výkazů za každý rok jsou často rozdělená do několika
excelových tabulek (sheets). Balíček operuje s názvy těchto tabulek.
Názvy tabulek by měly v zálkladní podobě dodržovat následující formát:
vXXYYaaa. Každý kód začíná písmenem "v". XX reprezentuje číslo výkazu a
YY rok. Pod znaky aaa bývá specifický podkód tabulky. Dělení na tabulky
s podkódy ale není napříč lety konzistentní. Například data z výkazu
M-03 za rok 2019 mohou být rozdělena do tabulek se jmény v0319a, v0319b,
v0319c. Balíček obsahuje funkci která vrací tabulku s popisy kódů
výkazů:

    ## Pozn. pro práci se speciálními charaktery, jako jsou písmena s háčky, lze aktivovat funkci set_cz(), nebo její aktivaci specifikovat ve funkci form_codes(cz = TRUE). Funkce není nezbytná pro fungování balíčku 
    set_cz()

    ## [1] "LC_COLLATE=English_United States.1250;LC_CTYPE=English_United States.1250;LC_MONETARY=English_United States.1250;LC_NUMERIC=C;LC_TIME=English_United States.1250"

    guide <- form_codes()
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

Setup
-----

První krok je samozřejmě získání samotných dat. To lze buď přátelským
kontaktování MŠMT, nebo formálně přes žádost podle zákona č. 106/1999
Sb., o svobodném přístupu k informacím (vzor žádosti by měl být snadno
dohledatelný). Data by měla být zorganizována podle výše popsaného
kódování. Poté je stačí uložit do jedné složky.

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

Funkce vytvoří soubor *MSMT\_data\_map.RDATA*, který bude uložen v
pracovním direktoriáři k načtení při dalším využtí dat. Vytvoření
souboru může zabrat nějaký čas. Když se program dostane k pročítání
jednotlivých souborů, začne svůj pokrok zobrazovat v konzoli. Existuje
několi způsobů, jak lze mapu vytvořit. Vytvoříte-li mapu s uložením,
stačí ji vytvořit pouze jednou.

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
adresy...

    my_map <- readRDS("E:/EDU/Data/MSMT_data_map.RDATA")

...nebo, je-li soubor v pracovním direktoriáři, názvem souboru:

    my_map <- readRDS("MSMT_data_map.RDATA")

### Struktura mapy

Mapa dat obsahuje tři objekty. První je tabulka meta\_data, která
shrnuje lokace soubourů s relevantními daty (directory), název tabulky a
jeho verzi v lowercase (sheet\_name a sheet), kód výkazu (form), rok
(year) a počet výskytů tabulky v datech pro případ duplikátů
(occurences).

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

Další dva objekty obsahují listy s názvy proměnných v jednotlivých
tabulkách. Objekt varlist obsahuje původní názvy proměnných, objekt
varlist\_lc obsahuje názvy transformované do lowercase, pro případ
rozdílů mezi tabulkami.

    ## Prvních třicet proměnných první tabulky
    head(my_map$varlist[[1]], 30)

    ##  [1] "idc"       "red_izo"   "izo"       "list"      "izonew"    "zriz"     
    ##  [7] "ulice"     "misto"     "typ"       "spr_urad3" "vusc"      "jazyk_s"  
    ## [13] "rok"       "nvusc"     "ikf"       "zrus"      "zar_naz"   "dp"       
    ## [19] "sp"        "sp_skoly"  "pu"        "r01012"    "r01013"    "r01022"   
    ## [25] "r01023"    "r01032"    "r01042"    "r01043"    "r03012"    "r03013"

Využití
-------

Když je mapa vytvořena nebo načtena, funkce get\_variables() s její
pomocí identifikuje soubory obsahující vyhledávané proměnné a následně
hodnoty těchto proměnných načte do nového objektu. I za využití mapy
může vyhledávání trvat několik okamžiků.

    tibble_list <- get_variables(variables = c("r15013","r15013a"), # Vektor vyhledávaných proměnných
                  map = my_map, # Mapa dat: není-li specifikována, funkce se ji pokusí najít v pracovním direktoriáři. Lze uvézt i adresu souboru obsahujícího mapu.
                  joint = c("izo","red_izo"), # Názvy dalších proměnných, které budou zahrnuty do výběru. Defaultně obsahuje základní identifikátory
                  forms = "v08", # Vektor (nebo samostatný character) určující žádoucí výkazy. Prázdný argument prohledá všechny výkazy
                  years = c("12","13","14","15","16","17","18") # Vektor obsahující žádoucí roky. Prázdný argument prohledá všechny roky
                  )

    ## Warning in get_variables(variables = c("r15013", "r15013a"), map = my_map, :
    ## File(s) v0817a_3 have two or more occurrences. Using the first file.

Funkce vrací list se dvěma objekty. První jsou průvodná meta\_data pro
využité soubory. Druhý objekt (variables) obsahuje tabulky se získanými
daty. Ke každé tabulce je přidána proměnná s příslušným rokem.

    tibble_list$variables$v0812a_2

    ## # A tibble: 1,379 x 4
    ##    year  izo       red_izo   r15013
    ##    <chr> <chr>     <chr>      <dbl>
    ##  1 12    108022676 600007481      0
    ##  2 12    108022722 600007472      0
    ##  3 12    108023079 600005569      0
    ##  4 12    108023087 600005585      0
    ##  5 12    108024148 600012271      0
    ##  6 12    108026736 600013014      6
    ##  7 12    108026761 600024695      0
    ##  8 12    108027457 600015831      5
    ##  9 12    108028127 600013375      0
    ## 10 12    108028135 600013260      0
    ## # ... with 1,369 more rows

    tibble_list$variables$v0813a_2

    ## # A tibble: 1,343 x 4
    ##    year  izo       red_izo   r15013
    ##    <chr> <chr>     <chr>      <dbl>
    ##  1 13    000013757 600006654     25
    ##  2 13    000053155 600014614      5
    ##  3 13    000053163 600014649      3
    ##  4 13    000055069 600015408      0
    ##  5 13    000055077 600015416      0
    ##  6 13    000055107 600015483      0
    ##  7 13    000064556 600006000      1
    ##  8 13    000068772 600006972      2
    ##  9 13    000068781 600006913      5
    ## 10 13    000068799 600007081      1
    ## # ... with 1,333 more rows

Takto vzniklý list lze například za využití balíčku dplyr propojit do
jedné tabulky v long formátu.

    long_data <- dplyr::bind_rows(tibble_list$variables)
    long_data

    ## # A tibble: 9,852 x 5
    ##    year  izo       red_izo   r15013 r15013a
    ##    <chr> <chr>     <chr>      <dbl>   <dbl>
    ##  1 12    108022676 600007481      0      NA
    ##  2 12    108022722 600007472      0      NA
    ##  3 12    108023079 600005569      0      NA
    ##  4 12    108023087 600005585      0      NA
    ##  5 12    108024148 600012271      0      NA
    ##  6 12    108026736 600013014      6      NA
    ##  7 12    108026761 600024695      0      NA
    ##  8 12    108027457 600015831      5      NA
    ##  9 12    108028127 600013375      0      NA
    ## 10 12    108028135 600013260      0      NA
    ## # ... with 9,842 more rows

Propojování s dalšími daty
--------------------------

Takto vzniklé soubory lze přes identifikátory škol propojit s dalšími
datovými soubory. Tyto identifikátory se v datech vyskytují čtyři:
"red\_izo","izo","p\_izo" a "izonew". Identifikátor "red\_izo" značí
ředitelství, pod které může spadat jedno, ale i několik školských
zařízení. Identifikátory "izo","p\_izo" a "izonew" pak značí jednotlivá
zařízení, s tím, že v některých letech se objevuje "p\_izo" a v
některých "izonew". V tuhle chvíli sice mám teorii o tom, kde se berou,
ale musím ji ještě ověřit.

V následujícím příkladě propojuji na základě red\_izo data z výkazů s
daty z adresáře škol. Je důležité počítat s tím, že některé
identifikátory nemusí být v adresáři obsažené. Pokusím se vymyslet, co s
tím.

    adresy<-read_excel("E:/EDU/Data/data/IZOCODES/Adresar.xlsx")%>%
      select(RED_IZO, Území, ORP)%>%
      mutate_all(as.character)
    names(adresy)<-tolower(names(adresy))

    joint <- left_join(long_data,adresy, by = "red_izo")
    unique(joint$území)

    ##  [1] "CZ0207" "CZ0105" "CZ0523" NA       "CZ0525" "CZ0635" "CZ0641" "CZ0511"
    ##  [9] "CZ0104" "CZ0102" "CZ0422" "CZ0513" "CZ0713" "CZ0323" "CZ0325" "CZ0805"
    ## [17] "CZ0514" "CZ0426" "CZ0424" "CZ0724" "CZ0423" "CZ0804" "CZ0632" "CZ020B"
    ## [25] "CZ0208" "CZ0209" "CZ0314" "CZ0644" "CZ0107" "CZ0425" "CZ0101" "CZ0103"
    ## [33] "CZ0647" "CZ0109" "CZ0106" "CZ0108" "CZ0712" "CZ0202" "CZ0642" "CZ0421"
    ## [41] "CZ0802" "CZ0714" "CZ0411" "CZ0531" "CZ0313" "CZ0803" "CZ0204" "CZ0721"
    ## [49] "CZ0206" "CZ0533" "CZ0715" "CZ0317" "CZ0534" "CZ0646" "CZ0521" "CZ0532"
    ## [57] "CZ0806" "CZ0645" "CZ0634" "CZ0722" "CZ0512" "CZ0327" "CZ0427" "CZ0316"
    ## [65] "CZ0723" "CZ0643" "CZ0633" "CZ0201" "CZ0321" "CZ0711" "CZ0311" "CZ0631"
    ## [73] "CZ0412" "CZ0203" "CZ010A" "CZ0326" "CZ0205" "CZ020C" "CZ0312" "CZ0522"
    ## [81] "CZ0322" "CZ0413" "CZ0524" "CZ020A" "CZ0315" "CZ0801" "CZ0324"

    print(joint)

    ## # A tibble: 9,852 x 7
    ##    year  izo       red_izo   r15013 r15013a území  orp  
    ##    <chr> <chr>     <chr>      <dbl>   <dbl> <chr>  <chr>
    ##  1 12    108022676 600007481      0      NA CZ0207 2115 
    ##  2 12    108022722 600007472      0      NA CZ0207 2115 
    ##  3 12    108023079 600005569      0      NA CZ0105 1116 
    ##  4 12    108023087 600005585      0      NA CZ0105 1116 
    ##  5 12    108024148 600012271      0      NA CZ0523 5209 
    ##  6 12    108026736 600013014      6      NA <NA>   <NA> 
    ##  7 12    108026761 600024695      0      NA CZ0525 5203 
    ##  8 12    108027457 600015831      5      NA CZ0635 6115 
    ##  9 12    108028127 600013375      0      NA <NA>   <NA> 
    ## 10 12    108028135 600013260      0      NA CZ0641 6201 
    ## # ... with 9,842 more rows

S daty lze pak dělat psí kusy.

    ggplot(joint, aes(x = as.numeric(year), y=log(r15013), color=substr(území, 1,4), fill=substr(území, 1,4)))+
      geom_count()+theme(legend.position = "none")+geom_line(aes(group=red_izo))

    ## Warning: Removed 6215 rows containing non-finite values (stat_sum).

![](README_files/figure-markdown_strict/unnamed-chunk-16-1.png)
