
# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")

# Uporabimo tryCatch,
# da prisilimo prekinitev povezave v primeru napake

tryCatch({
  # Vzpostavimo povezavo
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  

  dbSendQuery(conn, build_sql("CREATE TABLE vojna (
                              id INTEGER PRIMARY KEY,
                              ime TEXT NOT NULl,
                              zacetek DATE,
                              konec DATE,
                              zmagovalec TEXT,
                              območje TEXT)"))
  
  
  dbSendQuery(conn, build_sql(" CREATE TABLE sodelujoci (
                              id SERIAL PRIMARY KEY,
                              ime TEXT,
                              cas_obstoja TEXT,
                              drzava_id REFERENCES drzava(id) FOREIGN KEY,
                              je_skupina BOOLEAN)"))
                            
  
  
  dbSendQuery(conn, build_sql("CREATE TABLE drzava (
                              id SERIAL PRIMARY KEY
                              ime TEXT
                              prestolnica TEXT,
                              prebivalstvo INTEGER)"))
  

  
  dbSendQuery(conn, build_sql("CREATE TABLE koalicija (
                              id SERIAL PRIMARY KEY, 
                              clani TEXT,
                              umrli INTEGER,
                              sodelovanje_vojna TEXT REFERENCES vojna(id) FOREIGN KEY)"))
  
  dbSendQuery(conn, build_sql("CREATE TABLE sodelovanje_koal (
                              sodelujoci_id INTEGER NOT NULL,
                              koalicija_id INTEGER NOT NULL,
                              zacetek DATE,
                              konec DATE,
                              umrli INTEGER,
                              FOREIGN KEY (sodelujoci_id) REFERENCES sodelujoci(id)
                              FOREIGN KEY (koalicija_id) REFERENCES koalicija(id))"))

  dbSendQuery(conn, build_sql("CREATE TABLE povzroci (
                              povzrocitelj_id REFERENCES vojna(id),
                              povzrocena_id REFERENCES vojna(id),
                              FOREIGN KEY(povzrocena_id)  REFERENCES vojna(id),
                              FOREIGN KEY(povzrocitelj_id) REFERENCES vojna(id))"))
  
  
  dbSendQuery(conn, build_sql("CREATE TABLE uporabnik (
                              id SERIAL PRIMARY KEY,
                              username TEXT NOT NULL,
                              hash TEXT NOT NUll)"))
  
  dbSendQuery(conn, build_sql("CREATE TABLE komentar (
                              id SERIAL PRIMARY KEY,
                              uporabnik_id INTEGER,
                              vojna_id INTEGER
                              besedilo TEXT,
                              cas NOW(),
                              FOREIGN KEY(uporabnik_id) REFERENCES uporabnik(id),
                              FOREIGN KEY(vojna_id) REFERENCES vojna(id))"))
  
  

  # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })

                          


