library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")

drv <- dbDriver("PostgreSQL")

### vojna
vstavljanje.vojna <- function(){
  tryCatch({
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    
    for (i in 1:nrow(vojna)){
      v <- vojna[i, ]
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
vojna <- vstavljanje.vojna()

### sodelujoci
vstavljanje.sodelujoci <- function(){
  tryCatch({
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    
    for (i in 1:nrow(sodelujoci)){
      v <- sodelujoci[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO sodelujoci (id,ime)
                                  VALUES (", v[["id.drzava"]], ",
                                  ",v[["ime"]], ")", con = conn))
      
    }
  }, finally = {
    dbDisconnect(conn)
  })
}
sodelujoci <- vstavljanje.sodelujoci()
