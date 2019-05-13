#ui za shiny
library(shiny)
#lo�iti morava prijavno stran; ta bi bila popolnoma za�etna, 
#ko bi se prijavil bi odprl na naslednje


#predvidevam ve� panel; na eni zemljevid �ez cel svet, dana�nje dr�ave. 
shinyUI(fluidPage(theme = shinytheme("cerulean"),
                  titlePanel("Voja�ki spopadi"),
                  tabsetPanel(
                    #ta del po dr�avah
                    tabPanel("Zemljevid"
                             #tukaj bi dal zemljevid, in bi lahko izbral iz izbirnega seznama  dr�avo 
                             #in videl, v koliko vojnah je dr�ava bila
                             
                             
                             #poleg tega tudi uspe�nost
                             ),
                             
                    tabPanel("Uspe�nost"),
                    #po �tevilu zmag, porazov
                    tabPanel("�rtve")
                    #�rtve v vojnah
                    ),
                  tabsetPanel(
                    #tu bi bilo komentiranje dejanskih vojn; torej del po vojnah
                    tabPanel("Diskusija")
                    #tu bi lahko izbral vojno in bi se nabirali komentarji
                  )
                  )
        )