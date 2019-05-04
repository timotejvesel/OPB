library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("urejanje-podatkov/auth.R")

drv <- dbDriver("PostgreSQL")


vstavljanje.vojna <- function(){
  tryCatch({
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    
    for (i in 1:nrow(vse_vojne)){
      v <- vse_vojne[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO vojna (id,ime,zacetek,konec,zmagovalec,obmocje)
                                  VALUES (", v[["id.vojna"]], ",
                                  ",v[["ime"]], ", 
                                  ",v[["datum.zacetek"]], ",
                                  ",v[["datum.konec"]], ",
                                  ",v[["izid"]], ",
                                  ",v[["obmocje"]], ")", con = conn))
      
    }
    }, finally = {
      dbDisconnect(conn)
    })
  }
vrsta <- vstavljanje.vojna()
