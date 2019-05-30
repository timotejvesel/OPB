#server za shiny
#Najprej zaženi datoteko libraries.r

source("../lib/libraries.R")
source("../auth_public.r")
source("serverFunctions.R")

#tukaj klici sql, ki se povezejo na ui.R

shinyServer(function(input,output,session) {
  # Vzpostavimo povezavo
  drv <- dbDriver("PostgreSQL") 
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  userID <- reactiveVal()    # Placeholder za userID
  loggedIn <- reactiveVal(FALSE)    # Placeholder za logout gumb oz vrednost gumba
  
  dbGetQuery(conn, "SET CLIENT_ENCODING TO 'utf8'; SET NAMES 'utf8'")

  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn) #ko zapremo shiny naj se povezava do baze zapre
  })
  output$signUpBOOL <- eventReactive(input$signup_btn, 1)
  outputOptions(output, 'signUpBOOL', suspendWhenHidden=FALSE)  # Da omogoca skrivanje/odkrivanje
  observeEvent(input$signup_btn, output$signUpBOOL <- eventReactive(input$signup_btn, 1))
  
  # Greyout of signin button
  observeEvent(c(input$userName,input$password), {
    shinyjs::toggleState("signin_btn", 
                         all(c(input$userName, input$password)!=""))
  })
  
  # Sign in protocol
  observeEvent(input$signin_btn,
               {signInReturn <- sign.in.user(input$userName, input$password)
               if(signInReturn[[1]]==1){
                 userID(signInReturn[[2]])
                 output$signUpBOOL <- eventReactive(input$signin_btn, 2)
                 loggedIn(TRUE)
               }else if(signInReturn[[1]]==0){
                 showModal(modalDialog(
                   title = "Error during sign in",
                   paste0("An error seems to have occured. Please try again."),
                   easyClose = TRUE,
                   footer = NULL
                 ))
               }else{
                 showModal(modalDialog(
                   title = "Wrong Username/Password",
                   paste0("Username or/and password incorrect"),
                   easyClose = TRUE,
                   footer = NULL
                 ))
               }
               })
  
  # Greyout of signup button
  observeEvent(c(input$SignUpUserName, input$SignUpPassword), {
                   shinyjs::toggleState("signup_btnSignUp",
                                        all(c(input$SignUpUserName, input$SignUpPassword)!="")# & 
                                        # Preveri, ce samo latin characterji
                                        # !any(grepl("[^\x20-\x7F]",
                                        #         c(input$SignUpName, input$SignUpSurname, input$SignUpAddress, input$SignUpCity,
                                        #           input$SignUpCountry, input$SignUpEmso, input$SignUpMail, 
                                        #           input$SignUpUserName, input$SignUpPassword)))
                   )
                 })
  
  # Sign up protocol
  observeEvent(input$signup_btnSignUp,
               {
                 if(any(grepl("[^\x20-\x7F]",
                              c(input$SignUpUserName, input$SignUpPassword)))){
                   success <- -1
                 }else{
                   signUpReturn <- sign.up.user(input$SignUpUserName, input$SignUpPassword)
                   success <- signUpReturn[[1]]
                 }
                 if(success==1){
                   showModal(modalDialog(
                     title = "You have successfully signed up!",
                     paste0("Now you can login as ",input$SignUpUserName,''),
                     easyClose = TRUE,
                     footer = NULL
                   ))
                   output$signUpBOOL <- eventReactive(input$signup_btnSignUp, 0) 
                 }else if(success==-10){
                   showModal(modalDialog(
                     title = "Username conflict!",
                     paste0("The username ",input$SignUpUserName,' is already taken. Please,
                            chose a new one.'),
                     easyClose = TRUE,
                     footer = NULL
                     ))
                 }else if(success==-1){
                   showModal(modalDialog(
                     title = "Signup unsuccessful",
                     paste0("Only Latin characters allowed"),
                     easyClose = TRUE,
                     footer = NULL
                   ))
                 }else{
                   showModal(modalDialog(
                     title = "Error during sign up",
                     paste0("An error seems to have occured. Please try again."),
                     easyClose = TRUE,
                     footer = NULL
                   ))
                 }
               })
  
  # Back button to sign in page
  observeEvent(input$signup_btnBack, output$signUpBOOL <- eventReactive(input$signup_btnBack, 0))
  
  # Login/logout button in header
  observeEvent(input$dashboardLogin, {
    if(loggedIn()){
      output$signUpBOOL <- eventReactive(input$signin_btn, 0)
      userID <- reactiveVal()
    }
    loggedIn(ifelse(loggedIn(), FALSE, TRUE))
  })
  
  output$logintext <- renderText({
    if(loggedIn()) return("Logout here.")
    return("Login here")
  })
  
  output$dashboardLoggedUser <- renderText({
    if(loggedIn()) return(paste("Welcome,", pridobi.ime.uporabnika(userID())))
    return("")
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
    validate(need(!is.null(input$sodelujoci), "Izberi sodelujocega!"))
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
  
  
  output$sodel <- DT::renderDataTable(DT::datatable({     #glavna tabela rezultatov
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
    # validate(need(!is.null(input$vojna), "Izberi vojno!"))
    sql1 <- build_sql("SELECT glavna.ime AS \"Ime\", k1.clani AS \"Stran 1\", k2.clani AS \"Stran 2\",
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
# -------------------------------------------------------------------------------------------------
  
# slike
#output$iwo <- renderImage({})


# -------------------------------------------------------------------------------------------------
<<<<<<< HEAD
  
#komentarji 
  
=======
#komentarji 

# najdi.komentar <- reactive({
#   validate(need(stevec() > 0 && !is.null(input$vojna), "Izberi vojno!"))
#   sql_komentar <- build_sql("SELECT username AS Uporabnik, besedilo AS Komentar, cas FROM komentar
#                             JOIN uporabnik ON uporabnik.id = komentar.uporabnik_id 
#                             WHERE vojna_id =",input$vojna, conn)
# })
#   
# 
# output$komentiranje <- DT::renderDataTable({
#   DT::datatable(najdi.komentar())
#   })

>>>>>>> 06afebda1a2adaa4163318be34fb8c28032b0c49
output$izbrana.vojna <- renderUI({
  izbira_vojna = dbGetQuery(conn, build_sql("SELECT id, ime FROM vojna ORDER BY ime", con = conn))
  selectInput("vojna",
              label = "Izberite vojno:",
              choices = setNames(izbira_vojna$id, izbira_vojna$ime)
  )
})

observeEvent(input$komentar_gumb,{
  ideja <- renderText({input$komentar})
  sql2 <- build_sql("INSERT INTO komentar (uporabnik_id,vojna_id, besedilo,cas)
<<<<<<< HEAD
                   VALUES"(clan,",",input$vojna,",", ideja, ",NOW()", con = conn))
=======
                   VALUES(",userID(),",",input$vojna,",", input$komentar, ",NOW())", con = conn)
  #Med vejice moramo dodati sklic na id uporabnika
>>>>>>> 06afebda1a2adaa4163318be34fb8c28032b0c49
  data2 <- dbGetQuery(conn, sql2)
  data2
  shinyjs::reset("komentiranje")
  })
  
najdi.komentar <- reactive({
  input$komentar_gumb
  validate(need(!is.null(input$vojna), "Izberi vojno!"))
  sql_komentar <- build_sql("SELECT * FROM komentar
                            WHERE vojna_id =",input$vojna, con = conn)
  komentarji <- dbGetQuery(conn, sql_komentar)
  komentarji
})
output$komentiranje <- DT::renderDataTable((DT::datatable(najdi.komentar())))

# -------------------------------------------------------------------------------------------------

# statistika

 output$izbor.statistika <- renderUI({

   izbira_statistika = dbGetQuery(conn, build_sql("SELECT id, ime FROM sodelujoci ORDER BY ime", con = conn))

   #selectInput("statistika",
    #           label = "Izberi sodelujocega:",
    #           choices = setNames(izbira_statistika$id, izbira_statistika$ime)
              
   #)
 })


 najdi.statistika <- reactive({
   # validate(need(!is.null(input$statistika), "Izberi sodelujocega!"))
   sql3 <- build_sql("SELECT sodelujoci.id, sodelujoci.ime, COUNT(*) AS \"Stevilo vojn\", SUM(sodelovanje_koal.umrli) AS \"Zrtve\",
          SUM(sodelovanje_koal.umrli) / COUNT(*) AS \"Stevilo zrtev na vojno\", SUM(sodelovanje_koal.konec - sodelovanje_koal.zacetek) AS stevilo_dni_vojskovanja
          FROM sodelovanje_koal
          JOIN koalicija ON koalicija.id = koalicija_id
          JOIN vojna ON vojna.id = sodelovanje_vojna
          JOIN sodelujoci ON sodelujoci.id = sodelovanje_koal.sodelujoci_id
          WHERE TRUE 
          GROUP BY(sodelujoci.id)", con=conn)
     data3 <- dbGetQuery(conn, sql3)
     data3
     data3 <- data3[,c(2:5)]

   })

   output$stat <- DT::renderDataTable(DT::datatable({
     tabela3 = najdi.statistika()
   }))

})


