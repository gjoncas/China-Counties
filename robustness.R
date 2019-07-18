#ROBUSTNESS CHECKS
#import functions from density.R

#Robustness check #1 - Immediate neighbours only (NB: need adjacent.l)
adj.l = subset(adjacent.l, names(adjacent.l) %in% agri_prod$county_id)
adj.l = adj.l[order(names(adj.l))]

#count neighbours for each county
n = length(adj.l)
adj.nbr <- vector(length=n)
  for (i in (1:n)) {
    adj.nbr[i] = length(adj.l[[i]])
  }
rm(i,n)

#repeat densities for firms in each county
reps.v = rle(regression$county)$lengths
adj.nbr = rep(adj.nbr,reps.v)
reg.adj = regression              #NB: don't actually need separate file
reg.adj$adjacent = adj.nbr
#tempfile <- write_xlsx(reg.adj)


#Robustness check #2 - Different tax_enforcement specifications
#NB: use original regression data (without quantiles)
firm_data = firm_data[order(firm_data$county_id),]    #make sure they're in order
regression = regression[order(regression$county),]

tax2 = 100*(firm_data$taxes + firm_data$corp_tax + firm_data$vat + 
        firm_data$mgmt_fee) / firm_data$income
tax3 = 100*(firm_data$taxes + firm_data$corp_tax + firm_data$vat - firm_data$subsidy) / 
        firm_data$income
tax4 = 100*(firm_data$taxes + firm_data$corp_tax + firm_data$vat + firm_data$mgmt_fee - 
        firm_data$subsidy) / firm_data$income

#put them in full regression, *then* drop
tax2.r = data.frame(regression,tax2)
tax3.r = data.frame(regression,tax3)
tax4.r = data.frame(regression,tax4)

tax2.r = subset(tax2.r, tax2>=quantile(tax2.r$tax2,0.01) & tax2<=quantile(tax2.r$tax2,0.99))
tax3.r = subset(tax3.r, tax3>=quantile(tax3.r$tax3,0.01) & tax3<=quantile(tax3.r$tax3,0.99))
tax4.r = subset(tax4.r, tax4>=quantile(tax4.r$tax4,0.01) & tax4<=quantile(tax4.r$tax4,0.99))

reps2 <- rle(tax2.r$county)$lengths
tax2.r = data.frame(tax2.r,rep(reps2,reps2))
colnames(tax2.r)[10] = "weight"

reps3 <- rle(tax3.r$county)$lengths
tax3.r = data.frame(tax3.r,rep(reps3,reps3))
colnames(tax3.r)[10] = "weight"

reps4 <- rle(tax4.r$county)$lengths
tax4.r = data.frame(tax4.r,rep(reps4,reps4))
colnames(tax4.r)[10] = "weight"

#length(unique(tax2.r$county))
#tempfile <- write_xlsx(tax2.r)


#Robustness check #3 - For sample with gdp data, compare with results using nightlights
#
gdp.ctrl = read_excel("C:/Users/Graham/Desktop/Thesis/Regression/controls_yearly.xls")
gdp.ctrl = subset(gdp.ctrl, year==2005)   #2013
gdp.ctrl = subset(gdp.ctrl, county_id %in% agri_prod$county_id)
gdp.ctrl = na.omit(gdp.ctrl)    #134 obs

pc_gdp = read_excel("C:/Users/Graham/Desktop/Thesis/Regression/pc_gdp.xlsx", 
         col_types = c("text","skip","numeric","skip","skip","skip","skip","skip"))
colnames(pc_gdp) = c("county_id","gdp2005")
pc_gdp = pc_gdp[order(pc_gdp$county_id),]
pc_gdp = subset(pc_gdp, county_id %in% agri_prod$county_id)         #2076 obs --> 1410 obs
pc_gdp = na.omit(pc_gdp)                                            #1410 obs --> 1331 obs

#NB: must do na.omit on pc_gdp and gdp.ctrl beforehand
#NB: for 6 obs in pc_gdp, a county_id is used twice
mixgdp = data.frame(agri_prod$county_id,NA)
colnames(mixgdp) = c("county_id","gdp")
mixgdp$county_id = as.character(mixgdp$county_id)
for (i in 1:2780) {
  if (mixgdp$county_id[i] %in% pc_gdp$county_id) {
    mixgdp$gdp[i] = pc_gdp$gdp2005[which(pc_gdp$county_id==mixgdp$county_id[i])]
    } else
    if (mixgdp$county_id[i] %in% gdp.ctrl$county_id) {
      mixgdp$gdp[i] = gdp.ctrl$gdp[which(gdp.ctrl$county_id==mixgdp$county_id[i])]
      } else next
}                   #why is there an error message?

gdp = rep(mixgdp$gdp,reps.v)
gdp.reg = data.frame(regression,gdp)
gdp.reg = na.omit(gdp.reg)
gdp.reg$loggdp = log(gdp.reg$gdp)
#tempfile <- write_xlsx(gdp.reg)


#for summary statistics on sample with gdp data
#gdp.sample = data.frame(density$density,lights$MEAN,mixgdp$gdp)
#colnames(gdp.sample) = c("density","lights","gdp")
#gdp.sample = na.omit(gdp.sample)
#gdp.sample$gdp = log(gdp.sample$gdp)

#pov.reg = subset(regression, poverty==1)
#
#pov.sample = data.frame(agri_prod$county_id,agri_prod$MEAN,geo_var$elevation,density$density,
#                        lights$MEAN,rivers$r.density,mixgdp$gdp,poverty$poverty832)
#colnames(pov.sample)=c("county","agri_prod","geo_var","density","lights","rivers","gdp","poverty")
#pov.sample$county = as.character(pov.sample$county)
#pov.sample = subset(pov.sample, poverty==1)


#reps.v <- rle(regression$county)$lengths
#regression = data.frame(regression,rep(reps,reps))