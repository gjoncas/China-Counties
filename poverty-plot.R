#Scatterplot for thesis defense presentation
#NB: run assembleData.R beforehand

plot(x = agri_prod$MEAN[which(poverty$poverty832==0)],
     y = geo_var$elevation[which(poverty$poverty832==0)],
     xlab = "Agriculture",
     ylab = "Geography",
     cex.lab=1.55,
     cex.axis=1.55,
     xlim = c(0,400),
     ylim = c(0,1800),		 
     #main = "Poverty vs. Non-Poverty Counties",
     col="blue",
     pch=19
     )

points(x = agri_prod$MEAN[which(poverty$poverty832==1)],
       y = geo_var$elevation[which(poverty$poverty832==1)],
       col="red",
       pch=19
       )

legend(300,2000,c("poverty","non-poverty"),bty="n",inset=-0.1, pch=19,
       col=c("red","blue"),x.intersp=0.25,y.intersp=0.35,cex=1.5)