#|------------------------------------------------------------------------------------------|
#|                                                 Zivot_Wk_05_As_05_PerformanceAnalytics.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Lab                                                                               |
#|    The following questions require R. On the class web page are the script files lab5.r  |
#|  and descriptiveStatistics.r. The former contains hints for completing the assignment,   |
#|  and the latter contains the code for the doing the examples from class.                 |
#|                                                                                          |
#|    As in previous labs do NOT submit any output directly. There is an associated         |
#|  homework, "Assignment 5: R", that has questions related to the output of this lab.      |
#|                                                                                          |
#|    In this lab, you will analyze continuously compounded monthly return data on the      |
#|  Vanguard long term bond index fund (VBLTX), Fidelity Magellan stock mutual fund         |
#|  (FMAGX), and Starbucks stock (SBUX). I encourage you to go to finance.yahoo.com and     |
#|  research these assets. The script file lab5.r walks you through all of the computations |
#|  for the lab.                                                                            |
#|                                                                                          |
#|    You will use the get.hist.quote() function from the tseries package to automatically  |
#|  load this data into R. You will also use several functions from the                     |
#|  PerformanceAnalytics package. Remember to install packages before you load them into R. |
#|                                                                                          |
#| Assert Exercise                                                                          |
#|  (I) Univariate Graphical Analysis                                                       |
#|                                                                                          |
#|    (1) Make time plots of the return data using the R command plot() as illustrated in   |
#|        the script file lab5.r. Think about any relationships between the returns         |
#|        suggested by the plots. Pay particular attention to the behavior of returns       |
#|        toward the END of 2008 at the BEGINNING of the financial crisis.                  |
#|                                                                                          |
#|    (2) Make a cumulative return plot (future of $1 invested in each asset). Which assets |
#|        gave the best and worst future values over the investment horizon?                |
#|                                                                                          |
#|    (3) For EACH return series, make a FOUR(4)-panel plot containing a histogram,         |
#|        density plot, boxplot and normal QQ-plot. Do the return series look normally      |
#|        distributed?                                                                      |
#|                                                                                          |
#|  (II) Univariate Numerical Summary Statistics                                            |
#|                                                                                          |
#|    (1) Compute numerical descriptive statistics for ALL assets using the R functions     |
#|        summary(), mean(), var(), stdev(), skewness(), and kurtosis() (in package         |
#|        PerformanceAnalytics). Which asset appears to be the riskiest asset?              |
#|                                                                                          |
#|    (2) Using the mean monthly return for EACH asset, compute an estimate of the annual   |
#|        continuously compounded return (i.e. recall the relationship between the expected |
#|        monthly cc return and the expected annual cc return). Convert this annual cc      |
#|        return into a simple annual return. Are there any surprises?                      |
#|                                                                                          |
#|    (3) Using the estimate of the monthly return standard deviation for EACH asset,       |
#|        compute an estimate of the annual return standard deviation.                      |
#|                                                                                          |
#|  (III) Bivariate Graphical Analysis                                                      |
#|                                                                                          |
#|    Use the R pairs() function to create all pair-wise scatterplots of returns.           |
#|                                                                                          |
#|  (IV) Bivariate Numerical Summary Statistics                                             |
#|                                                                                          |
#|    Use the R functions var() and cor() to compute the sample covariance matrix and       |
#|  sample correlation matrix of the returns.                                               |
#|                                                                                          |
#|  (V) Time Series Summary Statistics                                                      |
#|                                                                                          |
#|    Use the R function acf() to compute and plot the sample autocorrelation functions of  |
#|  EACH return. Do the returns appear to be uncorrelated over time?                        |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Computational Finance and Financial Econometrics Assignment 5 Week 5:  |
#|          (ALL of the code taken from lab5.R)                                             |
#|            Input:    Nil                                                                 |
#|            Output:   (I)   ONE (1) THREE(3)-panel plot of returns                        |
#|                            TWO (2) combined plots of returns                             |
#|                            ONE (1) plot of future value                                  |
#|                            THREE (3) FOUR(4)-panel plots (returns, boxplot, density, Q-Q)|
#|                            TWO (2) combined boxplots of returns                          |
#|                      (II)  TEN (10) descriptive statistics                               |
#|                      (III) ONE (1) pairs plot of correlation matrix                      |
#|                      (IV)  TWO (2) descriptive matrices                                  |
#|                      (V)   THREE (3) plots of autocorrelations                           |
#|------------------------------------------------------------------------------------------|
library(PerformanceAnalytics)
library(zoo)
library(tseries)

#|------------------------------------------------------------------------------------------|
#|                                I N I T I A L I Z A T I O N                               |
#|------------------------------------------------------------------------------------------|
Init <- function(..., workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source")
{
  setwd(workDirStr)
  
#---  Assert create an empty zoo
  mergeZoo <- zoo(0)
  
  for( tickerChr in c(...) )
  {
    tickerZoo = suppressWarnings(get.hist.quote(instrument=tickerChr, start="1998-01-01", 
                                                end="2009-12-31", quote="AdjClose", 
                                                provider="yahoo", origin="1970-01-01",
                                                compression="m", retclass="zoo"))
  #--- Change class of time index to yearmon which is appropriate for monthly data
  #       index() and as.yearmon() are functions in the zoo package 
    index(tickerZoo) = as.yearmon(index(tickerZoo))
    
  #--- Create merged price data
    if( is.null(nrow(mergeZoo)) )
      mergeZoo <- tickerZoo
    else
      mergeZoo <- merge(mergeZoo, tickerZoo)
  }
  
  #--- Rename columns
  colnames(mergeZoo) = c(...)
  
  #--- Return value is a zoo
  return(mergeZoo)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                                M A I N   P R O C E D U R E                               |
#|------------------------------------------------------------------------------------------|
#--- Init loading data
rawDataZoo <- Init("VBLTX", "FMAGX", "SBUX")
#--- Count of cols of data
ncol(rawDataZoo)
#--- Count of rows of data
nrow(rawDataZoo)
#--- Names of header
names(rawDataZoo)
#--- Peek at data
head(rawDataZoo)
#--- Calculate cc returns as difference in log prices
retDataZoo <- diff(log(rawDataZoo))

#|------------------------------------------------------------------------------------------|
#|                            P A R T   O N E   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#--- Assert FOUR (4) plots on the same chart
layout(matrix(1:3,3,1,byrow=TRUE))

#--- THREE(3)-panel plot (each y axis has different scale)
#       Note: The generic plot() function invokes the plot method for objects of class zoo. 
#       See the help on plot.zoo
# 
plot(retDataZoo, col="blue", lwd=2, main="Monthly cc returns on 3 assets")

#--- Assert ONE (1) plot on the same chart
layout(matrix(1:1,1,1,byrow=TRUE))

plot(retDataZoo, plot.type="single", col=c("yellow","blue","red"), lwd=2,
     main="Monthly cc returns on 3 assets (base)", ylab="Return", ylim=c(-0.5,0.5))
legend(x="bottom", legend=colnames(retDataZoo), col=c("yellow","blue","red"), lwd=2)
abline(h=0)

#--- Plot returns using the PerformanceAnalytics function chart.TimeSeries()
#       This creates a slightly nicer looking plot that plot.zoo().
chart.TimeSeries(retDataZoo, legend.loc="bottom", 
                 main="Monthly cc returns on 3 assets (PerformanceAnalytics)") 

#--- Cumulative return plot - must use simple returns and not cc returns for this
#       Use PerformanceAnalytics function chart.CumReturns()
chart.CumReturns(diff(rawDataZoo)/lag(rawDataZoo, k=-1), legend.loc="topleft", 
                 wealth.index=TRUE, main="Future Value of $1 invested")

#--- Create matrix of return data. 
#       Some core R functions don't work correctly with zoo objects 
retDataMat = coredata(retDataZoo)
class(retDataMat)
colnames(retDataMat)
head(retDataMat)

#--- Assert FOUR (4) plots on the same chart
par(mfrow=c(2,2))

#--- Here are the FOUR(4)-panel plots
hist(retDataMat[,"VBLTX"],main="VBLTX monthly returns", xlab="VBLTX", 
     probability=T, col="slateblue1")
boxplot(retDataMat[,"VBLTX"],outchar=T, main="Boxplot", col="slateblue1")
plot(density(retDataMat[,"VBLTX"]),type="l", main="Smoothed density",
     xlab="monthly return", ylab="density estimate", col="slateblue1")
qqnorm(retDataMat[,"VBLTX"], col="slateblue1")
qqline(retDataMat[,"VBLTX"])

par(mfrow=c(2,2))

hist(retDataMat[,"FMAGX"],main="FMAGX monthly returns", xlab="FMAGX", 
     probability=T, col="slateblue1")
boxplot(retDataMat[,"FMAGX"],outchar=T, main="Boxplot", col="slateblue1")
plot(density(retDataMat[,"FMAGX"]),type="l", main="Smoothed density",
     xlab="monthly return", ylab="density estimate", col="slateblue1")
qqnorm(retDataMat[,"FMAGX"], col="slateblue1")
qqline(retDataMat[,"FMAGX"])

par(mfrow=c(2,2))

hist(retDataMat[,"SBUX"],main="SBUX monthly returns", xlab="SBUX", 
     probability=T, col="slateblue1")
boxplot(retDataMat[,"SBUX"],outchar=T, main="Boxplot", col="slateblue1")
plot(density(retDataMat[,"SBUX"]),type="l", main="Smoothed density",
     xlab="monthly return", ylab="density estimate", col="slateblue1")
qqnorm(retDataMat[,"SBUX"], col="slateblue1")
qqline(retDataMat[,"SBUX"])

#--- Show boxplot of three series on one plot
par(mfrow=c(1,1))

boxplot(retDataMat[,"VBLTX"], retDataMat[,"FMAGX"], retDataMat[,"SBUX"],
        names=colnames(retDataMat), col="slateblue1", 
        main="Return Distribution Comparison (base)")

#--- Do the same thing using the PerformanceAnalytics function chart.Boxplot()
par(mfrow=c(1,1))

chart.Boxplot(retDataZoo, main="Return Distribution Comparison (PerformanceAnalytics)")

#|------------------------------------------------------------------------------------------|
#|                            P A R T   T W O   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#--- Compute univariate descriptive statistics
summary(retDataMat)

#--- Compute descriptive statistics by column using the base R function apply()
#       Note: skewness() and kurtosis() are in the package PerformanceAnalytics
#       Note: kurtosis() returns excess kurtosis
apply(retDataMat, 2, mean)
apply(retDataMat, 2, var)
apply(retDataMat, 2, sd)
apply(retDataMat, 2, skewness)
apply(retDataMat, 2, kurtosis)

#--- A nice PerformanceAnalytics function that computes all of the relevant descriptive 
#       statistics is table.Stats()
table.Stats(retDataZoo)

#--- Annualize monthly estimates
#       Annualized cc mean 
#       Annualized simple mean
#       Annualized sd values
12*apply(retDataMat, 2, mean)
exp(12*apply(retDataMat, 2, mean)) - 1
sqrt(12)*apply(retDataMat, 2, sd)

#|------------------------------------------------------------------------------------------|
#|                          P A R T   T H R E E   P R O C E D U R E                         |
#|------------------------------------------------------------------------------------------|
#--- Compute bivariate descriptive statistics
par(mfrow=c(1,1))

pairs(retDataMat, col="slateblue1", pch=16)

#|------------------------------------------------------------------------------------------|
#|                          P A R T   F O U R   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#--- Compute 3 x 3 covariance and correlation matrices
var(retDataMat)
cor(retDataMat)

#|------------------------------------------------------------------------------------------|
#|                          P A R T   F I V E   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#--- Compute time series diagnostics
#       Autocorrelations
par(mfrow=c(1,1))

acf(retDataMat[,"VBLTX"], main="VBLTX")

par(mfrow=c(1,1))

acf(retDataMat[,"FMAGX"], main="FMAGX")

par(mfrow=c(1,1))

acf(retDataMat[,"SBUX"], main="SBUX")

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|