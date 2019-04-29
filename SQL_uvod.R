#Uvoz podatkov v bazo
# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")
# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")


#CREATE TABLE STAVKI

Tabela -> postgresqlBuildTableDefinition(dbObj, ime_tabele_v_SQL, objekt_v_R,
                                        field.types = (seznam_tipov_za_objekt_v_R),
                                        row.names = TRUE)

drzava -> build_sql("CREATE TABLE drzava (
                      id  SERIAL PRIMARY KEY
                      ime TEXT,  
                      prestolnica TEXT,
                      prebivalstvo INTEGER,
                      ")

skupina -> build_sql("CREATE TABLE skupina (
                      ime TEXT PRIMARY KEY
                    pripadniki INTEGER,
                    ")
#sodelujoči -> build_sql("CREATE TABLE sodelujoci ()")
koalicija -> build_sql("CREATE TABLE koalicija (
                      clani TEXT
                      zacetek YEAR,
                      konec YEAR
                      umrli INTEGER)
                      ")
vojna -> build_sql("CREATE vojna (
                      ime TEXT PRIMARY KEY
                    prestolnica TEXT,
                    zacetek YEAR,
                    konec YEAR,
                    umrli INTEGER,
                    zmagovalec TEXT,
                    območje INTEGER
)
                    ")



