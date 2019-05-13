#server za shiny
library(shiny)
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth_public.R")

#tukaj klici sql, ki se povezejo na ui.R

shinyServer(function(input, output,session) {
  # Vzpostavimo povezavo
  drv <- dbDriver("PostgreSQL") 
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  dbGetQuery(conn, "SET CLIENT_ENCODING TO 'utf8'; SET NAMES 'utf8'") #poskusim resiti rezave s sumniki
  
  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn) #ko zapremo shiny naj se povezava do baze zapre
  })
  
# -------------------------------------------------------------------------------------------------
  
# sodelujoci
  
  
  output$izbor.sodelujoci <- renderUI({
    
    izbira_sodelujoci = dbGetQuery(conn, build_sql("SELECT ime FROM sodelujoci"))
    Encoding(izbira_vrste[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
    
    selectInput("sodelujoci",
                label = "Izberite sodelujocega:",
                choices = izbira_sodelujoci
    )
  })

  
  
  najdi.vojne <- reactive({
    
    sql <- "SELECT vojna.ime, sodelovanje_koal.zacetek, sodelovanje_koal.konec, sodelovanje_koal.umrli AS zrtve FROM sodelovanje_koal
            JOIN koalicija ON koalicija.id = koalicija_id
            JOIN vojna ON vojna.id = sodelovanje_vojna" 
    query <- sqlInterpolate(conn, sql) #preprecimo sql injectione
    t=dbGetQuery(conn,query)
    
  })

  
  
  
})
  

