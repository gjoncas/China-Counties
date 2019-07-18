#Assemble different data from spreadsheets into one data frame
library("readxl")
library("writexl")

#variables: tax_enforcement, density, agri_prod, geo_var, lights, poverty

#- drop problem counties so that each variable has 629 elements
#- geo_var & agri_prod drop too many -- down to 473. Find out why.
#- then countrol drops even more, down to 462
#- use rle() to repeat elements for each firm in the firm-level data
#- make into a great big data.frame, export to Excel (use in Stata)
#- county dataset only has 2408 counties (485 in sample); LY's has 2853 (644 in sample)

firm_data <- read_excel("C:/Users/Graham/Desktop/Thesis/Regression/firm_data.xlsx", 
                        col_types = c("text","skip","skip","skip","numeric", "numeric","numeric",
                                      "numeric","numeric","numeric","numeric","numeric"))
firm_data = na.omit(firm_data)                                      #276474 obs
firm_data = firm_data[order(firm_data$county_id),]
#firm_data = subset(firm_data, county_id %in% agri_prod$county_id)  #276,474 obs --> 271,525 obs

agri_prod = read_excel("C:/Users/Graham/Desktop/Thesis/Regression/agri_prod.xls",
                       col_types = c("skip","text","skip","skip","skip","numeric")) #2782 obs
lost_agri <- read_excel("C:/Users/Graham/Desktop/Thesis/Regression/missing_agri.xlsx", 
                        col_types = c("text","numeric"))
lost_agri = na.omit(lost_agri)                      #still missing: c("210402", "340702")
agri_prod = rbind(agri_prod,lost_agri)              #27 firms in "210402", 28 firms in "340702"
agri_prod = agri_prod[order(agri_prod$county_id),]  #now: 2851 obs
rm(lost_agri)


# problem: firm_data has 2849 counties, but IDs don't all match IDs in agri_prod
#          69 counties in firm_data but not agri_prod, 71 in agri_prod but not firm_data
#solution: check for counties with close IDs, change firm_data IDs into close ones
full = unique(firm_data$county_id)                          #2849 counties
missing = full[which(! full %in% agri_prod$county_id)]      #69 counties
#miss2 = agri_prod$county_id[which(! agri_prod$county_id %in% full)]    #71 counties = 69 + 2

#given a missing observation, tries to find any county_id within 10 points
salvage <- function(obs,n=10) {
  lost = as.numeric(obs)
  try1 = lost + c(1:n)      #vector from obs+1 to obs+n
  try2 = lost - c(1:n)
  if (any(try1 %in% agri_prod$county_id)) {
    sup = min(try1[which(try1 %in% agri_prod$county_id)])  #least upper bound
  }
  else sup = FALSE
  if (any(try2 %in% agri_prod$county_id)) {
    inf = max(try2[which(try2 %in% agri_prod$county_id)])  #greatest lower bound
  } 
  else inf = FALSE
  
  if (sup==FALSE & inf==FALSE)  {return(obs)} else      #if no match, returns original
  if (sup==FALSE) {return(as.character(inf))} else
  if (inf==FALSE) {return(as.character(sup))} else
  if ((sup - lost) < (lost - inf)) {return(as.character(sup))}   #gives value closest to obs
  else return(as.character(inf))      #NB: using < (over <=) means favoring lower id in a tie
}

find.agri <- function(missing,n=10) {
  found = NULL
  for (i in missing) {found = c(found,salvage(i,n))}
  return(found)
}
#length(which(missing==find.agri(missing)))     #how many counties not salvaged


#set firm_id counties as salvaged IDs (??)


geo_var = read_excel("C:/Users/Graham/Desktop/Thesis/Regression/geo_var.xls",
                     col_types = c("skip","text","skip","numeric"))
colnames(geo_var) = c("county_id","elevation")
geo_var = geo_var[order(geo_var$county_id),]

rivers = read_excel("C:/Users/Graham/Desktop/Thesis/Regression/county_river.xls",
                    col_types = c("text","numeric","numeric"))      #only 2615 obs (omits zeros)
lost_rivs = agri_prod$county_id[(which(! agri_prod$county_id %in% rivers$county_id))]
lost_rivs = data.frame(lost_rivs,1e-08,1)             #for each river, sets length=1e-08 & area=1
colnames(lost_rivs) = c("county_id","length","area")
rivers = rbind(rivers,lost_rivs)
rivers = rivers[order(rivers$county_id),]
rivers$r.density = log(100000*rivers$length / rivers$area)
rivers$r.density[which(rivers$area==1)] = 0

density = read_excel("C:/Users/Graham/Desktop/Thesis/Regression/county_density.xlsx",
                        col_types = c("text", "numeric"))
density = density[order(density$county_id),]


lights = read_excel("C:/Users/Graham/Desktop/Thesis/Regression/nightlights.xls", 
                     col_types = c("skip", "text", "skip", "skip", "skip", "numeric"))
lights = lights[order(lights$county_id),]

poverty = read_excel("C:/Users/Graham/Desktop/Thesis/Regression/poverty_counties.xls", 
                    col_types = c("text", "skip", "numeric", "numeric", "numeric"))
poverty = poverty[order(poverty$county_id),]


#get same number of observations (2780) for each variable
agri_prod <- subset(agri_prod, county_id %in% firm_data$county_id)  #2851 obs --> 2780 obs
lights = subset(lights, county_id %in% agri_prod$county_id)         #2853 obs --> 2780 obs
geo_var = subset(geo_var, county_id %in% agri_prod$county_id)       #2853 obs --> 2780 obs
density = subset(density, county_id %in% agri_prod$county_id)       #2853 obs --> 2780 obs
rivers = subset(rivers, county_id %in% agri_prod$county_id)         #2831 obs --> 2780 obs
poverty = subset(poverty, county_id %in% agri_prod$county_id)       #2873 obs --> 2780 obs
firm_data <- subset(firm_data, county_id %in% agri_prod$county_id)  #276474   --> 271525

#define tax_enforcement variable
firm_data$income = firm_data$income + 0.001   #avoid dividing by zero
firm_data$employ = firm_data$employ + 1
tax_rate = 100*(firm_data$taxes + firm_data$corp_tax + firm_data$vat) / firm_data$income

#use run length encoder to get # of repetitions (firms) in each county
reps.v <- rle(firm_data$county_id)$lengths

#copies values for each firm in the county
#template: rep(c(1,2,3),c(3,2,4)) == c(1,1,1,2,2,3,3,3,3)
dsty = rep(density$density,reps.v)
geov = rep(geo_var$elevation,reps.v)
agri = rep(agri_prod$MEAN,reps.v)
lite = rep(lights$MEAN,reps.v)
rvrs = rep(rivers$r.density,reps.v)
pvty = rep(poverty$poverty832,reps.v)    #this is the 832 list; leave out 591 for now

regression = data.frame(firm_data$county_id,tax_rate,dsty,geov,agri,lite,rvrs,pvty)
colnames(regression) <- c("county","tax_rate","density","geo_var",
                          "agri_prod","lights","rivers","poverty")
rm(tax_rate,dsty,geov,agri,lite,rvrs,pvty)
regression$county = as.character(regression$county)     #convert from factor to char

#drop outliers from tax_enforcement (NB: need original version for robustness checks)
top.pct = quantile(regression$tax_rate,0.995)   # 37.8
bot.pct = quantile(regression$tax_rate,0.005)   #-4.53
regression = subset(regression, tax_rate>=bot.pct & tax_rate<=top.pct)    #268809 obs
rm(top.pct,bot.pct)

reps <- rle(regression$county)$lengths
regression = data.frame(regression,rep(reps,reps))
colnames(regression)[9] = "weight"

#length(which(regression$tax_rate > top.pct))   #1358 for both --> 2716 firms dropped (1%)
#tempfile <- write_xlsx(regression)     #get from C:\Users\Graham\AppData\Local\Temp