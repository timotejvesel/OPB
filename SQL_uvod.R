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

država -> build_sql("CREATE TABLE drzava (
                      ime TEXT PRIMARY KEY
                      prestolnica TEXT,
                      prebivalstvo INTEGER,
                      zacetek YEAR,
                      konec YEAR
                      umrli INTEGER)
                    ")

skupina -> build_sql("CREATE TABLE skupina (
                      ime TEXT PRIMARY KEY
                    pripadniki INTEGER,
                    zacetek YEAR,
                    konec YEAR
                    umrli INTEGER)
                    ")
država -> build_sql("CREATE TABLE drzava (
                      ime TEXT PRIMARY KEY
                    prestolnica TEXT,
                    prebivalstvo INTEGER,
                    zacetek YEAR,
                    konec YEAR
                    umrli INTEGER)
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



