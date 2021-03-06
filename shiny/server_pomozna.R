#server za shiny
#Najprej zaženi datoteko libraries.r

source("../auth_public.r")

#tukaj klici sql, ki se povezejo na ui.R

shinyServer(function(input,output,session) {
  # Vzpostavimo povezavo
  drv <- dbDriver("PostgreSQL") 
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  dbGetQuery(conn, "SET CLIENT_ENCODING TO 'utf8'; SET NAMES 'utf8'")
  
  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn) #ko zapremo shiny naj se povezava do baze zapre
  })
  
# -------------------------------------------------------------------------------------------------
  
# sodelujoci
  
  output$izbor.sodelujoci <- renderUI({
    
    izbira_sodelujoci = dbGetQuery(conn, build_sql("SELECT id, ime FROM sodelujoci ORDER BY ime", con = conn))
    
    selectInput("sodelujoci",
                label = "Izberite sodelujocega:",
                choices = setNames(izbira_sodelujoci$id, izbira_sodelujoci$ime)
    )
  })

  
  
  najdi.sodelujoci <- reactive({
    validate(need(!is.null(input$sodelujoci), "Izberi drzavo!"))
    sql <- build_sql("SELECT DISTINCT sodelujoci.ime , vojna.ime AS \"Ime vojne\",
            sodelovanje_koal.zacetek AS \"Zacetek sodelovanja\", sodelovanje_koal.konec AS \"Konec sodelovanja\", 
            -- to_char(sodelovanje_koal.zacetek, 'DD.MM.YYYY'),
            -- to_char(sodelovanje_koal.konec, 'DD.MM.YYYY'),
            sodelovanje_koal.umrli AS \"Stevilo zrtev\" FROM sodelovanje_koal
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
    tabela=najdi.sodelujoci()
  }) %>% DT::formatDate(c('Zacetek sodelovanja', 'Konec sodelovanja'), method = "toLocaleDateString")) # datum v normalno obliko 
                                                                                # +  pravilno sortiranje
  

  
# -------------------------------------------------------------------------------------------------

# iskanje po vojnah

  output$izbor.vojna <- renderUI({

    izbira_vojna = dbGetQuery(conn, build_sql("SELECT id, ime FROM vojna ORDER BY ime", con = conn))

    selectInput("vojna",
                label = "Izberite vojno:",
                choices = setNames(izbira_vojna$id, izbira_vojna$ime)
    )
  }) 


  najdi.vojna <- reactive({
    #validate(need(!is.null(input$vojna), "Izberi vojno!"))
    sql1 <- build_sql("SELECT glavna.ime, k1.clani AS \"Stran 1\", k2.clani AS \"Stran 2\",
                    glavna.zacetek AS \"Zacetek\",glavna.konec AS \"Konec\",
                    -- to_char(glavna.zacetek, 'DD.MM.YYYY'),
                    -- to_char(glavna.konec, 'DD.MM.YYYY'), 
                    glavna.zrtve AS \"Stevilo zrtev\",
                    glavna.zmagovalec AS \"Zmagovalec\", glavna.obmocje AS \"Obmocje\",
                    povzrociteljica.ime AS \"Povzrocena iz vojne\",
                    povzrocena.ime AS \"Povzrocila je vojno \" FROM vojna glavna
                    JOIN koalicija k1 ON k1.sodelovanje_vojna = glavna.id AND k1.stran = 1
                    JOIN koalicija k2 ON k2.sodelovanje_vojna = glavna.id AND k2.stran = 2
                    LEFT JOIN povzroci povzrocitelj ON povzrocitelj.povzrocena_id = glavna.id
                    LEFT JOIN vojna povzrociteljica ON povzrocitelj.povzrocitelj_id = povzrociteljica.id
                    LEFT JOIN povzroci povzrocenec ON povzrocenec.povzrocitelj_id = glavna.id
                    LEFT JOIN vojna povzrocena ON povzrocenec.povzrocena_id = povzrocena.id
                    WHERE TRUE", con=conn)
    if (!is.null(input$min_max[1])) {
     sql1 <- build_sql(sql1, " AND (glavna.zrtve BETWEEN ", input$min_max[1], " AND ", input$min_max[2], " OR glavna.zrtve IS NULL)", con=conn)
    }
    data1 <- dbGetQuery(conn, sql1)
    data1
  })


  output$voj <- DT::renderDataTable({
    tabela1 = najdi.vojna()
    validate(need(nrow(tabela1) > 0, "Ni podatkov"))
    DT::datatable(tabela1) %>% DT::formatDate(c('Zacetek', 'Konec'), method = "toLocaleDateString") # datum v normalno obliko
                                                                              # +  pravilno sortiranje
  })
})

# -------------------------------------------------------------------------------------------------
# statistika za sodelujoce

# output$statistika <- renderUI({
#
#   izbira_stat = dbGetQuery(conn, build_sql(""))
#
#   selectInput("statistika",
#               label = "Poglej, kaj o vojnah za vsako državo pravi statistika:"#,
#               #choices = setNames(izbira_sodelujoci$id, izbira_sodelujoci$ime)
#   )
# })
#
#
#
# statistic <- reactive({
#   validate(need(!is.null(input$sodelujoci), "Izberi drzavo!"))
#   #Ta SQL ni pravi
#   sql <- build_sql("SELECT sodelujoci.ime AS ime,
#                            SUM(sodelovanje_koal.umrli) AS zrtve,
#                            COUNT(sodelovanje_koal.sodelujoci_id) AS stevilo_vojn,
#                            SUM(sodelovanje_koal.umrli) / count(sodelovanje_koal.sodelujoci_id) AS zrtve_na_vojno
#                     FROM sodelovanje_koal
#                     JOIN sodelujoci ON sodelovanje_koal.sodelujoci_id = sodelujoci.id
#                     JOIN koalicija ON sodelovanje_koal.koalicija_id = koalicija.id
#                     JOIN vojna ON koalicija.sodelovanje_vojna = vojna.id
#                     GROUP BY sodelujoci.id
# #Poglej še za koliko zmag bo
#
#                     ",  con=conn)
#     data <- dbGetQuery(conn, sql)
#     data
#
#   })
#
#
#   output$stat <- DT::renderDataTable(DT::datatable({ #glavna tabela rezultatov
#     tabela1=statistic()
#   }))

# SELECT sodelujoci.id, sodelujoci.ime, COUNT(*) AS stevilo_vojn, SUM(sodelovanje_koal.umrli) AS zrtve , SUM(sodelovanje_koal.umrli) / COUNT(*) AS zrtve_na_vojno,
# SUM(DATEDIFF(Day, MIN(joindate), MAX(joindate))) AS stevilo_dni_vojskovanja
# FROM sodelovanje_koal
# JOIN koalicija ON koalicija.id = koalicija_id
# JOIN vojna ON vojna.id = sodelovanje_vojna
# JOIN sodelujoci ON sodelujoci.id = sodelovanje_koal.sodelujoci_id
# GROUP BY(sodelujoci.id)



