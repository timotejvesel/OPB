library(shiny)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme("superhero"),
                  
                  
                  titlePanel("Iskalnik po vseh vojnah od leta 1800"),
                  
                  mainPanel(
                    tabsetPanel(
                      tabPanel("Iskanje po sodelujocih",
                               
                               sidebarPanel(
                                 uiOutput("izbor.sodelujoci")
                               ),
                               mainPanel(tableOutput("izdelki"))
                      )
                      
                      
                      
                    )
                  )
                  
))



