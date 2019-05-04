uvozi.inter <- function() {
  inter <- read_csv2("Viri/Inter_popravljen.csv",
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

# za zacetek in konec vojne vzamemo min oz. max datuma zacetka oz. konca
vojna <- unique(inter[,c("id.vojna","ime","datum.zacetek","datum.konec", "izid","obmocje")])
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




uvozi.intra <- function() {
  intra <- read_csv2("Viri/Intra_popravljen.csv",
                    na = ":", locale = locale(encoding="UTF-8"))[,c(1:5,7:12,19:24)]
  
  colnames(inter) <- c("id.vojna", "ime", "tip", "id.drzava", "drzava", "stran", "mesec.zacetek",
                       "dan.zacetek", "leto.zacetek", "mesec.konec",
                       "dan.konec", "leto.konec", "iz",
                       "obmocje","zacetnik", "izid", "v", "zrtve")
  
  
  return(inter)
  
}


intra <- uvozi.intra()

