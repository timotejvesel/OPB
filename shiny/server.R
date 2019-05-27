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
                   success <- sign.up.user(input$SignUpUserName, input$SignUpPassword)
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
    validate(need(!is.null(input$sodelujoci), "Izberi drzavo!"))
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
    tabela=najdi.sodelujoci()
  }) %>% DT::formatDate(c('zacetek', 'konec'), method = "toLocaleDateString")) # datum v normalno obliko 
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
    validate(need(!is.null(input$vojna), "Izberi vojno!"))
    sql1 <- build_sql("SELECT glavna.ime, k1.clani AS stran_1, k2.clani AS stran_2,
                    glavna.zacetek,glavna.konec,
                    -- to_char(glavna.zacetek, 'DD.MM.YYYY') AS zacetek,
                    -- to_char(glavna.konec, 'DD.MM.YYYY') AS konec, 
                    glavna.zmagovalec, glavna.obmocje,
                    povzrociteljica.ime AS povzrocena_iz,
                    povzrocena.ime AS povzrocila_je FROM vojna glavna
                    JOIN koalicija k1 ON k1.sodelovanje_vojna = glavna.id AND k1.stran = 1
                    JOIN koalicija k2 ON k2.sodelovanje_vojna = glavna.id AND k2.stran = 2
                    LEFT JOIN povzroci povzrocitelj ON povzrocitelj.povzrocena_id = glavna.id
                    LEFT JOIN vojna povzrociteljica ON povzrocitelj.povzrocitelj_id = povzrociteljica.id
                    LEFT JOIN povzroci povzrocenec ON povzrocenec.povzrocitelj_id = glavna.id
                    LEFT JOIN vojna povzrocena ON povzrocenec.povzrocena_id = povzrocena.id
                    WHERE glavna.id = ", input$vojna, con=conn)
    data1 <- dbGetQuery(conn, sql1)
    # SPREMENI IMENA STOLPCEV V SHINY
  })


output$voj <- DT::renderDataTable(DT::datatable({ #glavna tabela rezultatov
  tabela1=najdi.vojna()
}) %>% DT::formatDate(c('zacetek', 'konec'), method = "toLocaleDateString")) # datum v normalno obliko
                                                                            # +  pravilno sortiranje



# -------------------------------------------------------------------------------------------------
#komentarji 
#mnenje <- renderText({input$komentar})
#sql2 <- build_sql("INSERT INTO komentar (id,uporabnik_ime,vojna_id, besedilo,cas)
#                  VALUES(clan,",input$vojna,",", mnenje, ",NOW()", con = conn)
#data2 <- dbGetQuery(conn, sql2)

najdi.komentar <- reactive({
  validate(need(!is.null(input$vojna), "Izberi vojno!"))
  sql_komentar <- build_sql("SELECT * FROM komentar
                            WHERE vojna_id =",input$vojna)
})
  

output$komentiranje <- DT::renderDataTable((DT::datatable(tabela2=najdi.komentar())))

})


# -------------------------------------------------------------------------------------------------

# statistika

# 
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
#   validate(need(!is.null(input$sodelujoci), "Izberi drÅ¾avo!"))
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

