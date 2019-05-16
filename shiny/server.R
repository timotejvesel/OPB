#server za shiny
library(shiny)
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("../auth_public.r")

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
    
    izbira_sodelujoci = dbGetQuery(conn, build_sql("SELECT id, ime FROM sodelujoci ORDER BY ime"))
    
    selectInput("sodelujoci",
                label = "Izberite sodelujocega:",
                choices = setNames(izbira_sodelujoci$id, izbira_sodelujoci$ime)
    )
  })

  
  
  najdi.vojne <- reactive({
    validate(need(!is.null(input$sodelujoci), "Izberi državo!"))
    sql <- build_sql("SELECT DISTINCT sodelujoci.ime, vojna.ime,
            sodelovanje_koal.zacetek, sodelovanje_koal.konec,
            -- to_char(sodelovanje_koal.zacetek, 'DD.MM.YYYY') AS zacetek,
            -- to_char(sodelovanje_koal.konec, 'DD.MM.YYYY') AS konec,
            sodelovanje_koal.umrli AS zrtve FROM sodelovanje_koal
            JOIN koalicija ON koalicija.id = koalicija_id
            JOIN vojna ON vojna.id = sodelovanje_vojna
            JOIN sodelujoci ON sodelujoci.id = sodelovanje_koal.sodelujoci_id
            WHERE sodelujoci.id = ", input$sodelujoci, con=conn)
    data <- dbGetQuery(conn, sql)
    data <- data[,c(2,3,4,5)]
    # datumi v normalno obliko
    #data[,2] <- as.character(data[,2])
    #data[,3] <- as.character(data[,3])
    data

  })
  
  
  output$sodel <- DT::renderDataTable(DT::datatable({ #glavna tabela rezultatov
    tabela1=najdi.vojne()
  }) %>% DT::formatDate(c('zacetek', 'konec'), method = "toLocaleDateString")) # datum v normalno obliko 
                                                                                # +  pravilno sortiranje
  
})
  

