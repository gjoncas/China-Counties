#Using data on county adjacency + centroids, find county density
library("readxl")   #NB: I can probably bypass using Excel files later on
library("writexl")
library("geosphere")  #more accurate calculation of distance on earth

#1. Get data from county_centroids + county_neighbour
#2. Make a list of neighbours for each county
#3. For each county, get its neighbours of neighbours of ... (to reduce search space)
#4. Use distGeo formula to calculate distances between centroids in set
#5. If a county j's centroid is <100km from county i, add 1 to i's density

neighbours = read_excel("C:/Users/Graham/Desktop/Thesis/County_Borders/county_neighbour.xls",
                         col_types = c("skip","text", "text","skip","skip"))
colnames(neighbours) = c("src_id","nbr_id")

centroids <- read_excel("C:/Users/Graham/Desktop/Thesis/County_Borders/county_centroids.xls",
                        col_types = c("skip","skip","skip","skip","text","numeric","numeric"))
#counties of HK (810000) and Macau (820000) have same county_id -- take average
hk = subset(centroids, county_id=="810000")
hk = data.frame(county_id=hk[[1]][1],Centroid_X=mean(hk[[2]]),Centroid_Y=mean(hk[[3]]))
mc = subset(centroids, county_id=="820000")
mc = data.frame(county_id=mc[[1]][1],Centroid_X=mean(mc[[2]]),Centroid_Y=mean(mc[[3]]))
#
centroids <- centroids[!centroids$county_id %in% c("810000","820000"),]
centroids <- rbind(centroids,hk)
centroids <- rbind(centroids,mc)
 counties <- centroids$county_id          #2853 unique counties
rm(hk,mc)
 
#makes vector of neighbours for a county
beMyNeighbour <- function(county) {
   nbs.i <- which(neighbours$src_id==county)    #where the county shows up in the vector
   adj.v <- neighbours$nbr_id[nbs.i]            #vector with neighbours of county i
   return(adj.v)                                #to try: binary search + bug-prevention
}

#list: for each county, gives vectors of neighbours
getNeighbours <- function() {
  nbrs.l <- list()
  n <- length(counties)
  
  for (i in (1:n)) {
    nbrs.l[i] <- list(beMyNeighbour(counties[i]))
    names(nbrs.l)[i] <- counties[i]
  }
  return(nbrs.l)
}

adjacent.l = getNeighbours()        #NB: not in nbrs.sq b/c gets called over & over in c.density

#recursive function to find neighbours to the nth degree (neighbours 'squared')
nbrs.sq <- function(county,n) {
  if (n<=0) {return(county)} else
  nbrs.v = NULL
    for (i in county) {
    cnty.s <- as.character(i)     #without this, interprets i as literal index value
    allnbr <- lapply(adjacent.l[[cnty.s]],beMyNeighbour)
    unique <- unique(unlist(allnbr))
    nbrs.v <- c(nbrs.v,unique)
  }
  county <- unique(nbrs.v)        #re-using varname 'county' to emphasize recursion
  return(nbrs.sq(county,n-1))
}


#NB: distGeo function comes from geosphere package; can enter distHaversine as test
distance = function(county1,county2,FUN=distGeo) {
  i <- which(centroids$county_id==county1)
  coord1 <- c(centroids$Centroid_X[i],centroids$Centroid_Y[i])
  j <- which(centroids$county_id==county2)
  coord2 <- c(centroids$Centroid_X[j],centroids$Centroid_Y[j])
  d = FUN(coord1,coord2)
  return(d/1000)    #distance in km
}
#To Do: robustness check with densities calculated with haversine distance
#length(which(densities!=test)) == ___
#in __, haversine > geo.Dist; in __, geo.Dist > haversine

#use to compare mean of nbrs.sq("110101",2) to mean of nbrs.sq("110101",3), etc.
test.dist <- function(county,n,FUN=mean) {
  test.v <- NULL
  neighbours <- nbrs.sq(county,n)
  for (i in neighbours) {test.v <- c(test.v,distance(county,i))}
  return(FUN(test.v))
}
#test.dist("110101",2)==80.50643      #test.dist("110101",2)==147.3078


#densities of one county
c.density <- function(county,n,limit=100) {
  neighbours <- nbrs.sq(county,n)
  density <- 0
  for (i in neighbours) {
    if (distance(county,i) <= limit) {density = density + 1}
    else next
  }
  return(density)
}

#loops over all counties in vector
getDensities <- function(counties,n,limit=100) {
  densities <- NULL 
  for (i in counties) {densities <- c(densities,c.density(i,n,limit))}
  return(densities)
}

densities <- getDensities(counties,3,100)   #n=2: ~5mins to run; n=3: ~20mins
                                            #n=3 is optimal (580 differences from n=2)

#Robustness check: does it make a difference whether neighbour depth is n or n+1?
test.nbr.depth <- function(d1,d2) {
  density1 <- getDensities(counties,d1)
  density2 <- getDensities(counties,d2)
  diff.dense <- length(which(density1!=density2))
  return(diff.dense)
}
#test.nbr.depth(2,3)      #robustness check -- actually, difference is 0!

#county_density <- data.frame(county_id=counties,density=densities)
#tempfile <- write_xlsx(county_density)

#get histogram of densities
hist(densities, main=NULL, xlab="County density", 
     cex.lab=1.55, cex.axis=1.55, cex.main=1.55, cex.sub=1.55)      #makes font larger