uvozi.inter <- function() {
  inter <- read_csv("podatki/Inter-StateWarData_v4.0.csv",
                         na = ":", locale = locale(encoding="UTF-8"))[,c(1:12,19:24)]
  
  colnames(inter) <- c("id.vojna", "ime", "tip", "id.drzava", "drzava", "stran", "mesec.zacetek",
                            "dan.zacetek", "leto.zacetek", "mesec.konec",
                              "dan.konec", "leto.konec", "iz",
                            "obmocje","zacetnik", "izid", "v", "zrtve")
   
  
  return(inter)
  
}


inter <- uvozi.inter()
