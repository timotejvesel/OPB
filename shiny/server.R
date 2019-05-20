#server za shiny
#Najprej zaženi datoteko libraries.r

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
    validate(need(!is.null(input$sodelujoci), "Izberi drÅ¾avo!"))
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
  
#Zgolj za oglede nas zanima še koliko vojn je vsaka zmagala, izgubila, koliko žrtev je utrpela

# -------------------------------------------------------------------------------------------------

# iskanje po vojnah

output$izbor.sodelujoci <- renderUI({
  
  izbira_sodelujoci = dbGetQuery(conn, build_sql("SELECT id, ime FROM vojna ORDER BY ime"))
  
  selectInput("vojne",
              label = "Izberite vojno:",
              choices = setNames(izbira_sodelujoci$id, izbira_sodelujoci$ime)
  )
})


najdi.vojne <- reactive({
  validate(need(!is.null(input$sodelujoci), "Izberi vojno!"))
  sql <- build_sql("SELECT glavna.ime, k1.clani AS stran_1, k2.clani AS stran_2, glavna.zacetek, glavna.konec, glavna.zmagovalec, glavna.obmocje, povzrocitelj.povzrocitelj_id, povzrociteljica.ime AS povzrocena_iz FROM vojna glavna
JOIN koalicija k1 ON k1.sodelovanje_vojna = glavna.id AND k1.stran = 1
                   JOIN koalicija k2 ON k2.sodelovanje_vojna = glavna.id AND k2.stran = 2
                   LEFT JOIN povzroci povzrocitelj ON povzrocitelj.povzrocena_id = glavna.id
                   LEFT JOIN vojna povzrociteljica ON povzrocitelj.povzrocitelj_id = povzrociteljica.id
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

# -------------------------------------------------------------------------------------------------

# statistika


output$statistika <- renderUI({
  
  izbira_stat = dbGetQuery(conn, build_sql(""))
  
  selectInput("statistika",
              label = "Poglej, kaj o vojnah za vsako državo pravi statistika:"#,
              #choices = setNames(izbira_sodelujoci$id, izbira_sodelujoci$ime)
  )
})



statistic <- reactive({
  validate(need(!is.null(input$sodelujoci), "Izberi drÅ¾avo!"))
  #Ta SQL ni pravi
  sql <- build_sql("SELECT sodelujoci.ime AS ime, 
                           SUM(sodelovanje_koal.umrli) AS zrtve, 
                           COUNT(sodelovanje_koal.sodelujoci_id) AS stevilo_vojn, 
                           SUM(sodelovanje_koal.umrli) / count(sodelovanje_koal.sodelujoci_id) AS zrtve_na_vojno 
                    FROM sodelovanje_koal
                    JOIN sodelujoci ON sodelovanje_koal.sodelujoci_id = sodelujoci.id
                    JOIN koalicija ON sodelovanje_koal.koalicija_id = koalicija.id
                    JOIN vojna ON koalicija.sodelovanje_vojna = vojna.id
                    GROUP BY sodelujoci.id
#Poglej še za koliko zmag bo
     
                    ",  con=conn)
    data <- dbGetQuery(conn, sql)
    data

  })
  
  
  output$stat <- DT::renderDataTable(DT::datatable({ #glavna tabela rezultatov
    tabela1=statistic()
  }) 
})
