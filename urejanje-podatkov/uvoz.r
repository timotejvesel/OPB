##### Uvoz inter
uvozi.inter <- function() {
  inter <- read_csv2("podatki/Inter_popravljen.csv",
                         na = ":", locale = locale(encoding="UTF-8"))[,c(1:12,19:24)]
  
  colnames(inter) <- c("id.vojna", "ime", "tip", "id.drzava", "drzava", "stran", "mesec.zacetek",
                            "dan.zacetek", "leto.zacetek", "mesec.konec",
                              "dan.konec", "leto.konec", "iz",
                            "obmocje","zacetnik", "izid", "v", "zrtve")
  
  inter$datum.zacetek <- as.Date(with(inter, paste(leto.zacetek, mesec.zacetek, dan.zacetek,sep="-")), "%Y-%m-%d")
  inter$datum.konec <- as.Date(with(inter, paste(leto.konec, mesec.konec, dan.konec,sep="-")), "%Y-%m-%d")
   
  
  for (i in 1:length(inter$obmocje)) {
    if (inter$obmocje[i] == 1) {
        inter$obmocje[i] <- "Western Hemisphere"
        }
    else if (inter$obmocje[i] == 2) {
        inter$obmocje[i] <- "Europe"
      }
    else if (inter$obmocje[i] == 4) {
      inter$obmocje[i] <- "Africa"
    }
    else if (inter$obmocje[i] == 6) {
      inter$obmocje[i] <- "Middle East"
    }
    else if (inter$obmocje[i] == 7) {
      inter$obmocje[i] <- "Asia"
    }
    else if (inter$obmocje[i] == 9) {
      inter$obmocje[i] <- "Oceania"
    }
    else if (inter$obmocje[i] == 11) {
      inter$obmocje[i] <- "Europe, Middle East"
    }
    else if (inter$obmocje[i] == 12) {
      inter$obmocje[i] <- "Europe, Asia"
    }
    else if (inter$obmocje[i] == 13) {
      inter$obmocje[i] <- "W. Hemisphere, Asia"
    }
    else if (inter$obmocje[i] == 14) {
      inter$obmocje[i] <- "Europe, Africa, Middle East"
    }
    else if (inter$obmocje[i] == 15) {
      inter$obmocje[i] <- "Europe, Africa, Middle East, Asia"
    }
    else if (inter$obmocje[i] == 16) {
      inter$obmocje[i] <- "Africa, Middle East, Asia, Oceania"
    }
    else if (inter$obmocje[i] == 17) {
      inter$obmocje[i] <- "Asia, Oceania"
    }
    else if (inter$obmocje[i] == 18) {
      inter$obmocje[i] <- "Africa, Middle East"
    }
    else if  (inter$obmocje[i] == 19) {
      inter$obmocje[i] <- "Europe, Africa, Middle East, Asia, Oceania"
    }
        
  }
  
  return(inter)
  
}

inter <- uvozi.inter()



##### Uvoz intra
uvozi.intra <- function() {
  intra <- read_csv2("podatki/Intra_popravljen.csv",
                     na = ":", locale = locale(encoding="UTF-8"))[,c(1:6,8:13,20:25)]
  
  colnames(intra) <- c("id.vojna", "ime", "tip", "id.drzava", "drzava", "stran", "mesec.zacetek",
                       "dan.zacetek", "leto.zacetek", "mesec.konec",
                       "dan.konec", "leto.konec", "iz",
                       "obmocje","zacetnik", "izid", "v", "zrtve")
  
  intra$datum.zacetek <- as.Date(with(intra, paste(leto.zacetek, mesec.zacetek, dan.zacetek,sep="-")), "%Y-%m-%d")
  intra$datum.konec <- as.Date(with(intra, paste(leto.konec, mesec.konec, dan.konec,sep="-")), "%Y-%m-%d")
  
  
  for (i in 1:length(intra$obmocje)) {
    if (intra$obmocje[i] == 1) {
      intra$obmocje[i] <- "Western Hemisphere"
    }
    else if (intra$obmocje[i] == 2) {
      intra$obmocje[i] <- "Europe"
    }
    else if (intra$obmocje[i] == 4) {
      intra$obmocje[i] <- "Africa"
    }
    else if (intra$obmocje[i] == 6) {
      intra$obmocje[i] <- "Middle East"
    }
    else if (intra$obmocje[i] == 7) {
      intra$obmocje[i] <- "Asia"
    }
    else if (intra$obmocje[i] == 9) {
      intra$obmocje[i] <- "Oceania"
    }
    else if (intra$obmocje[i] == 11) {
      intra$obmocje[i] <- "Europe, Middle East"
    }
    else if (intra$obmocje[i] == 12) {
      intra$obmocje[i] <- "Europe, Asia"
    }
    else if (intra$obmocje[i] == 13) {
      intra$obmocje[i] <- "W. Hemisphere, Asia"
    }
    else if (intra$obmocje[i] == 14) {
      intra$obmocje[i] <- "Europe, Africa, Middle East"
    }
    else if (intra$obmocje[i] == 15) {
      intra$obmocje[i] <- "Europe, Africa, Middle East, Asia"
    }
    else if (intra$obmocje[i] == 16) {
      intra$obmocje[i] <- "Africa, Middle East, Asia, Oceania"
    }
    else if (intra$obmocje[i] == 17) {
      intra$obmocje[i] <- "Asia, Oceania"
    }
    else if (intra$obmocje[i] == 18) {
      intra$obmocje[i] <- "Africa, Middle East"
    }
    else if  (intra$obmocje[i] == 19) {
      intra$obmocje[i] <- "Europe, Africa, Middle East, Asia, Oceania"
    }
    
  }
  return(intra)
  
}

intra <- uvozi.intra()

##### Uvoz extra
uvozi.extra <- function() {
  extra <- read_csv2("podatki/Extra_popravljen.csv",
                     na = ":", locale = locale(encoding="UTF-8"))[,c(1:12,19,21:25)]
  
  colnames(extra) <- c("id.vojna", "ime", "tip", "id.drzava", "drzava", "stran", "mesec.zacetek",
                       "dan.zacetek", "leto.zacetek", "mesec.konec",
                       "dan.konec", "leto.konec",
                       "zacetnik", "iz", "izid", "v","obmocje" ,"zrtve")
  
  extra$datum.zacetek <- as.Date(with(extra, paste(leto.zacetek, mesec.zacetek, dan.zacetek,sep="-")), "%Y-%m-%d")
  extra$datum.konec <- as.Date(with(extra, paste(leto.konec, mesec.konec, dan.konec,sep="-")), "%Y-%m-%d")
  
  
  for (i in 1:length(extra$obmocje)) {
    if (extra$obmocje[i] == 1) {
      extra$obmocje[i] <- "Western Hemisphere"
    }
    else if (extra$obmocje[i] == 2) {
      extra$obmocje[i] <- "Europe"
    }
    else if (extra$obmocje[i] == 4) {
      extra$obmocje[i] <- "Africa"
    }
    else if (extra$obmocje[i] == 6) {
      extra$obmocje[i] <- "Middle East"
    }
    else if (extra$obmocje[i] == 7) {
      extra$obmocje[i] <- "Asia"
    }
    else if (extra$obmocje[i] == 9) {
      extra$obmocje[i] <- "Oceania"
    }
    else if (extra$obmocje[i] == 11) {
      extra$obmocje[i] <- "Europe, Middle East"
    }
    else if (extra$obmocje[i] == 12) {
      extra$obmocje[i] <- "Europe, Asia"
    }
    else if (extra$obmocje[i] == 13) {
      extra$obmocje[i] <- "W. Hemisphere, Asia"
    }
    else if (extra$obmocje[i] == 14) {
      extra$obmocje[i] <- "Europe, Africa, Middle East"
    }
    else if (extra$obmocje[i] == 15) {
      extra$obmocje[i] <- "Europe, Africa, Middle East, Asia"
    }
    else if (extra$obmocje[i] == 16) {
      extra$obmocje[i] <- "Africa, Middle East, Asia, Oceania"
    }
    else if (extra$obmocje[i] == 17) {
      extra$obmocje[i] <- "Asia, Oceania"
    }
    else if (extra$obmocje[i] == 18) {
      extra$obmocje[i] <- "Africa, Middle East"
    }
    else if  (extra$obmocje[i] == 19) {
      extra$obmocje[i] <- "Europe, Africa, Middle East, Asia, Oceania"
    }
    
  }
  return(extra)
  
}

extra <- uvozi.extra()


##### Uvoz non
uvozi.non <- function() {
  non <- read_csv2("podatki/Non_popravljen.csv",
                   na = ":", locale = locale(encoding="UTF-8"))[,c(1:7,9:19)]
  
  colnames(non) <- c("id.vojna", "ime", "tip", "obmocje" ,"id.drzava", "drzava", "stran",
                     "leto.zacetek","mesec.zacetek",
                     "dan.zacetek", "leto.konec","mesec.konec",
                     "dan.konec", 
                     "zacetnik", "iz",  "v","izid","zrtve")
  
  non$datum.zacetek <- as.Date(with(non, paste(leto.zacetek, mesec.zacetek, dan.zacetek,sep="-")), "%Y-%m-%d")
  non$datum.konec <- as.Date(with(non, paste(leto.konec, mesec.konec, dan.konec,sep="-")), "%Y-%m-%d")
  
  
  for (i in 1:length(non$obmocje)) {
    if (non$obmocje[i] == 1) {
      non$obmocje[i] <- "Western Hemisphere"
    }
    else if (non$obmocje[i] == 2) {
      non$obmocje[i] <- "Europe"
    }
    else if (non$obmocje[i] == 4) {
      non$obmocje[i] <- "Africa"
    }
    else if (non$obmocje[i] == 6) {
      non$obmocje[i] <- "Middle East"
    }
    else if (non$obmocje[i] == 7) {
      non$obmocje[i] <- "Asia"
    }
    else if (non$obmocje[i] == 9) {
      non$obmocje[i] <- "Oceania"
    }
    else if (non$obmocje[i] == 11) {
      non$obmocje[i] <- "Europe, Middle East"
    }
    else if (non$obmocje[i] == 12) {
      non$obmocje[i] <- "Europe, Asia"
    }
    else if (non$obmocje[i] == 13) {
      non$obmocje[i] <- "W. Hemisphere, Asia"
    }
    else if (non$obmocje[i] == 14) {
      non$obmocje[i] <- "Europe, Africa, Middle East"
    }
    else if (non$obmocje[i] == 15) {
      non$obmocje[i] <- "Europe, Africa, Middle East, Asia"
    }
    else if (non$obmocje[i] == 16) {
      non$obmocje[i] <- "Africa, Middle East, Asia, Oceania"
    }
    else if (non$obmocje[i] == 17) {
      non$obmocje[i] <- "Asia, Oceania"
    }
    else if (non$obmocje[i] == 18) {
      non$obmocje[i] <- "Africa, Middle East"
    }
    else if  (non$obmocje[i] == 19) {
      non$obmocje[i] <- "Europe, Africa, Middle East, Asia, Oceania"
    }
    
  }
  return(non)
  
}

non <- uvozi.non()


### zdruzimo vojne v eno tabelo
skupna <- rbind(inter,extra,intra,non)

### naredimo tabelo za vojno
# za zacetek in konec vojne vzamemo min oz. max datuma zacetka oz. konca
vojna <- unique(skupna[,c("id.vojna","ime","datum.zacetek","datum.konec", "izid","obmocje")])
vojna1 <- vojna %>% group_by(id.vojna,ime,izid) %>% summarise(datum.zacetek = min(datum.zacetek)) %>% ungroup()
vojna2 <- vojna %>% group_by(id.vojna) %>% summarise(datum.konec = max(datum.konec)) %>% ungroup()
vojna3 <- vojna %>% group_by(id.vojna) %>% summarise(obmocje = toString(obmocje)) %>% ungroup()

vojna4 <- inner_join(vojna1,vojna2, by = "id.vojna")
vojna4 <- inner_join(vojna3,vojna4, by = "id.vojna")


# odstrani ponavljajoca se obmocja v posamezni vojni
for (i in 1:nrow(vojna4)) {
  if (vojna4$izid == 8 ) {
    
  }
  vojna4$obmocje[i] <- paste(vojna4$obmocje[i],",", sep = '')
  str <- vojna4$obmocje[i]
  d <- unlist(strsplit(str, split=" "))
  vojna4$obmocje[i] <- paste(unique(d), collapse = ' ')
  # odstrani zadnjo vejico
  vojna4$obmocje[i] <- gsub(",$", "", vojna4$obmocje[i])
}
vojna <- vojna4
vojna <- vojna[c("id.vojna","ime","datum.zacetek","datum.konec","izid","obmocje")]

