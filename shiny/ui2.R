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
                      
                      
                      
                      
                    ),
                      tabPanel("Iskanje po vojnah",
                               
                               sidebarPanel(
                                 uiOutput("izbor.vojna")
                               ),
                               mainPanel(DT::dataTableOutput("voj"), width=12)
                      ))
                      
                      
                      
                  )
                  
))



