
sign.up.user <- function(username, pass){
  # Return values:
  # 1 ... success
  # 0 ... error
  # -10 ... username exists
  success <- 0      # Boolean, if the insertion into the db was successful
  
  # hashing of password
  pass <- hashpw(pass)
  clan <- username
  
  useraccount <- data.frame(id, username = clan, password=pass)
  
  #kako dodamo zaporedni id uporabnika v bazi?
  
  tryCatch({
    drv <- dbDriver("PostgreSQL")
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    userTable <- tbl(conn, "uporabnik")
    # Pogledamo, èe je uporabnisko ime ze zasedeno
    if(0 != dim((userTable %>% filter(username == uporabnik) %>% collect()))[1]){
      success <- -10
    }
    # Ce nam if stavek vrne True, potem v bazo uporabnik dodamo uporabnika z zaporedno stevilko, uporabniskim in geslom
    sql_prijava <- build_sql("INSERT INTO uporabnik(id,username,hash)
                             VALUES(clan,pass)")
    data_sql_prijava <- dbGetQuery(conn,sql_prijava)
    success <- 1
    
  }, finally = {
    dbDisconnect(conn)
    return(success)
  })
}

sign.in.user <- function(username, pass){
  # Return a list. In the first place is an indicator of success:
  # 1 ... success
  # 0 ... error
  # -10 ... wrong username
  # The second place represents the userid if the login info is correct,
  # otherwise it's NULL
  success <- 0
  uporabnikID <- NULL
  tryCatch({
    drv <- dbDriver("PostgreSQL")
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    userTable <- tbl(conn, "uporabnik")
    obstoj <- 0
    # obstoj = 0, ce username in geslo ne obstajata,  1 ce obstaja
    uporabnik <- username
    geslo <- (userTable %>% filter(username == uporabnik) %>% select(password) %>% collect())[[1]]
    
    if(checkpw(pass,geslo)){
      obstoj <- 1
    }
    if(obstoj == 0){
      success <- -10
    }else{
      uporabnikID <- (userTable %>% filter(username == uporabnik) %>%
                        select(userid) %>% collect())[[1]]
      success <- 1
    }
  },warning = function(w){
    print(w)
  },error = function(e){
    print(e)
  }, finally = {
    dbDisconnect(conn)
    return(list(success, uporabnikID))
  })
}


