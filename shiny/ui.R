#ui za shiny
library(shiny)
#loèiti morava prijavno stran; ta bi bila popolnoma zaèetna, 
#ko bi se prijavil bi odprl na naslednje


#predvidevam veè panel; na eni zemljevid èez cel svet, današnje države. 
shinyUI(fluidPage(theme = shinytheme("cerulean"),
                  titlePanel("Vojaški spopadi"),
                  tabsetPanel(
                    #ta del po državah
                    tabPanel("Zemljevid"
                             #tukaj bi dal zemljevid, in bi lahko izbral iz izbirnega seznama  državo 
                             #in videl, v koliko vojnah je država bila
                             
                             
                             #poleg tega tudi uspešnost
                             ),
                             
                    tabPanel("Uspešnost"),
                    #po številu zmag, porazov
                    tabPanel("Žrtve")
                    #žrtve v vojnah
                    ),
                  tabsetPanel(
                    #tu bi bilo komentiranje dejanskih vojn; torej del po vojnah
                    tabPanel("Diskusija")
                    #tu bi lahko izbral vojno in bi se nabirali komentarji
                  )
                  )
        )