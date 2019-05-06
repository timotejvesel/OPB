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


### koalicija
vstavljanje.koalicija  <- function(){
  tryCatch({
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    
    for (i in 1:nrow(koalicija)){
      v <- koalicija[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO koalicija (id, clani, stran, umrli, sodelovanje_vojna)
                                  VALUES (",  v[["id.koalicija"]], ",
                                  ",v[["clani"]], ",
                                  ",v[["stran"]], ", 
                                  ",v[["zrtve"]], ",
                                  ",v[["id.vojna"]], ")", con = conn))
      
    }
  }, finally = {
    dbDisconnect(conn)
  })
  }
koalicija <- vstavljanje.koalicija()


### sodelovanje koalicija
vstavljanje.sodelovanje  <- function(){
  tryCatch({
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    
    for (i in 1:nrow(sodelovanje)){
      v <- sodelovanje[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO sodelovanje_koal (sodelujoci_id, koalicija_id, zacetek, konec, umrli)
                                  VALUES (",  v[["drzava.id"]], ",
                                  ",v[["id.koalicija"]], ",
                                  ",v[["datum.zacetek"]], ", 
                                  ",v[["datum.konec"]], ",
                                  ",v[["zrtve"]], ")", con = conn))
      
    }
  }, finally = {
    dbDisconnect(conn)
  })
  }
sodelovanje <- vstavljanje.sodelovanje()

vstavljanje.povzroci <- function(){
  tryCatch({
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    for (i in 1:nrow(povzroci)){
      v <- sodelovanje[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO povzroci (id.vojna, id.koalicija)
                                  VALUES (",  v[["id.vojna"]], ",
                                  ",v[["id.koalicija"]], con = conn))
      
    }
  }, finally = {
    dbDisconnect(conn)
  })
  }
povzroci <- vstavljanje.sodelovanje()

    
