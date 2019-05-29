vpisniPanel <- tabPanel("SignIn", value="signIn",
                         fluidPage(
                           fluidRow(
                             column(width = 12,
                                    align = "center",
                                    textInput("userName","User name", value= ""),
                                    passwordInput("password","Password", value = ""),
                                    actionButton("signin_btn", "Sign In"),
                                    actionButton("signup_btn", "Sign Up"))
                              )))

registracijaPanel <- tabPanel("SignUp", value = "signUp",
                              fluidPage(
                                fluidRow(
                                  column(width = 12,
                                         align="center",
                                         textInput("SignUpUserName","* Username", value= "", placeholder = "Only Latin characters."),
                                         passwordInput("SignUpPassword","* Password", value= "", placeholder = "Only Latin characters."),
                                         actionButton("signup_btnBack", "Back"),
                                         actionButton("signup_btnSignUp", "Sign Up")
                                  )
                                )
                              )
                            )



sidebar <- dashboardSidebar(hr(),
  sidebarMenu(id="drzave",
              menuItem("Pregled vojn po skupinah", tabName = "drzave", selected = TRUE)),
  sidebarMenu(id="vojne",
              menuItem("Pregled vojn",tabName = "vojne")),
  sidebarMenu(id="stat", 
              menuItem("Statistika po sodelujocih", tabName = "stat")),
  sidebarMenu(id="kometnar", 
              menuItem("Civilen diskurz o vojnah", tabName = "koment"))
  
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "drzave",
            fluidRow(sidebarPanel(
              uiOutput("izbor.sodelujoci")
            ),
            mainPanel(DT::dataTableOutput("sodel")
              ))),
    tabItem(tabName = "vojne",
            fluidRow(sidebarPanel(
              sliderInput("min_max",
                          "Stevilo zrtev:",
                          min = 0,
                          max = 17000000,
                          value = c(0,17000000),
                          step = 1,
                          post = "",
                          sep = ".")
            ),
            mainPanel(DT::dataTableOutput("voj")
            ))),
    tabItem(tabName = "stat",
            fluidRow(sidebarPanel(
              uiOutput("izbor.statistika")
            ),
            mainPanel(DT::dataTableOutput("stat")
            ))),
    tabItem(tabName = "komentar",
            fluidRow( textInput("komentar", "Dodaj svoje mnenje", "Tvoje mnenje"),
                      verbatimTextOutput("value"),
                      DT::dataTableOutput("komentiranje")
                      
            ))
    ))
    
fluidPage(useShinyjs(),
           conditionalPanel(condition = "output.signUpBOOL!='1' && output.signUpBOOL!='2'",#&& false", 
                   vpisniPanel),       # UI panel za vpis
  conditionalPanel(condition = "output.signUpBOOL=='1'", registracijaPanel),  # UI panel registracija
  conditionalPanel(condition = "output.signUpBOOL=='2'",    # Panel, ko si ze vpisan
                   dashboardPage(#dashboardHeader(disable=T),
                     dashboardHeader(title = "Pregled vojn",
                                                 tags$li(class = "dropdown",
                                                         tags$li(class = "dropdown", textOutput("dashboardLoggedUser"), style = "padding-top: 15px; padding-bottom: 15px; color: #fff;"),
                                                         tags$li(class = "dropdown", actionLink("dashboardLogin", textOutput("logintext")))
                                                         )),
                                 sidebar,
                                 body,
                                 skin = "blue")),
  theme="bootstrap.css"
)