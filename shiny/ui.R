library(shiny)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme("cerulean"),
                  
                  
                  titlePanel("Iskalnik po vseh vojnah od leta 1800"),
                  
                  mainPanel(
                    tabsetPanel(
                      tabPanel("Iskanje po sodelujocih",
                               
                               sidebarPanel(
                                 uiOutput("izbor.sodelujoci")
                               ),
                               mainPanel(DT::dataTableOutput("sodel"), width=12)
                      )
                      
                      
                      
                    ),
                    tabsetPanel(
                      tabPanel("Sama statistika",
                               
                               sidebarPanel(
                                 uiOutput("statistika")
                               ),
                               mainPanel(DT::dataTableOutput("stat"), width=12)
                      )
                      
                      
                      
                    )
                  )
                  
))



