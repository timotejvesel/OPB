#narejeni ploti za statistiko


#dolgcas mi je in ne morem spat
letna_analiza <- skupna %>% group_by(leto.zacetek) %>% count(leto.zacetek)
vojne_po_letih  <-plot(x=letna_analiza$leto.zacetek,y=letna_analiza$n,
                       xlab = "Leto", ylab = "Vojn v letu")
