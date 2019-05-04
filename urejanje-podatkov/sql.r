
# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")
conn <- dbConnect(drv, dbname = db, host = host,
                  user = user, password = password)

# Uporabimo tryCatch,
# da prisilimo prekinitev povezave v primeru napake

tryCatch({
  # Vzpostavimo povezavo
  
 dbSendQuery(conn, build_sql("CREATE TABLE vojna (
                              id INTEGER PRIMARY KEY,
                              ime TEXT NOT NULL,
                              zacetek DATE,
                              konec DATE,
                              zmagovalec INTEGER,
                              obmocje TEXT)", con = conn)) # zmagovalec..... zacasni tip: INTEGER
  
  dbSendQuery(conn, build_sql("CREATE TABLE drzava (
                              id SERIAL PRIMARY KEY,
                              ime TEXT,
                              prestolnica TEXT,
                              prebivalstvo INTEGER)", con = conn))
  
  dbSendQuery(conn, build_sql(" CREATE TABLE sodelujoci (
                              id SERIAL PRIMARY KEY,
                              ime TEXT,
                              cas_obstoja TEXT,
                              drzava_id INTEGER NOT NULL,
                              FOREIGN KEY(drzava_id) REFERENCES drzava(id),
                              je_skupina BOOLEAN)", con = conn))
                            
  dbSendQuery(conn, build_sql("CREATE TABLE koalicija (
                              id SERIAL PRIMARY KEY, 
                              clani TEXT,
                              umrli INTEGER,
                              sodelovanje_vojna INTEGER NOT NULL, 
                              FOREIGN KEY(sodelovanje_vojna) REFERENCES vojna(id) )", con = conn))
  
  dbSendQuery(conn, build_sql("CREATE TABLE sodelovanje_koal (
                              sodelujoci_id INTEGER NOT NULL,
                              koalicija_id INTEGER NOT NULL,
                              zacetek DATE,
                              konec DATE,
                              umrli INTEGER,
                              FOREIGN KEY (sodelujoci_id) REFERENCES sodelujoci(id),
                              FOREIGN KEY (koalicija_id) REFERENCES koalicija(id))", con = conn))

  dbSendQuery(conn, build_sql("CREATE TABLE povzroci (
                              povzrocitelj_id INTEGER NOT NULL,
                              povzrocena_id INTEGER NOT NULL,
                              FOREIGN KEY(povzrocena_id)  REFERENCES vojna(id),
                              FOREIGN KEY(povzrocitelj_id) REFERENCES vojna(id))", con = conn))
  
  
  dbSendQuery(conn, build_sql("CREATE TABLE uporabnik (
                              id SERIAL PRIMARY KEY,
                              username TEXT NOT NULL,
                              hash TEXT NOT NUll)", con = conn))
  
  dbSendQuery(conn, build_sql("CREATE TABLE komentar (
                              id SERIAL PRIMARY KEY,
                              uporabnik_id INTEGER,
                              vojna_id INTEGER,
                              besedilo TEXT,
                              cas TIMESTAMP,
                              FOREIGN KEY(uporabnik_id) REFERENCES uporabnik(id),
                              FOREIGN KEY(vojna_id) REFERENCES vojna(id))", con = conn))
  
  
  # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })

                          


