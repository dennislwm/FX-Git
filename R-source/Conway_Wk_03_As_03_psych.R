#|------------------------------------------------------------------------------------------|
#|                                                               Conway_Wk_03_As_03_psych.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    Write a script in R to run correlation and multiple regression analyses. Use the data |
#|  in "DAA.03.txt". The file contains fictional data from 245 adults. The THREE (3)        |
#|  variables of interest are (1) physical endurance, (2) age, and (3) number of years      |
#|  engaged in an active sport.                                                             |
#|                                                                                          |
#|    From your R output, report the TEN (10) values listed in the table below. Round to    |
#|  TWO (2) significant digits (for example, if the correlation is .456 then write .46).    |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Assignment 3 Week 3:                                                            |
#|            Input:    DAA.03.txt                                                          |
#|            Output:   THREE (3) histograms and THREE (3) Q-Q plots.                       |
#|                      THREE (3) descriptive statistics.                                   |
#|                      ONE (1) scatterplot and ONE (1) correlation matrix.                 |
#|                      TWO (2) unstandardized and TWO (2) standardized simple regressions. |
#|                      ONE (1) unstandardized and ONE (1) standardized multiple regression.|
#|------------------------------------------------------------------------------------------|
library(psych)
library(ltm)
library(gclus)

#|------------------------------------------------------------------------------------------|
#|                                I N I T I A L I Z A T I O N                               |
#|------------------------------------------------------------------------------------------|
Init <- function(fileStr, workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  setwd(workDirStr)
  retDfr <- read.table(fileStr, header=T)
  return(retDfr)
}

#|------------------------------------------------------------------------------------------|
#|                                M A I N   P R O C E D U R E                               |
#|------------------------------------------------------------------------------------------|

#--- Init loading raw data
rawDfr <- Init("DAA.03.txt")

#--- Count of raw data
nrow(rawDfr)

#--- Names of header
names(rawDfr)

#--- Remove column 1
rawDfr <- rawDfr[,2:4]

#--- Layout
layout(matrix(1:6,3,2,byrow=TRUE))

#--- Custom Plot
for( nameStr in names(rawDfr) )
{
  #--- Check for normality p>0.05 is normal
  p <- shapiro.test( rawDfr[[nameStr]] )$p.value
  hist( rawDfr[[nameStr]], prob=T, main=c( paste("RAW", nameStr), paste("Shapiro p=",prettyNum(p,digits=2)) ), xlab=nameStr )
  lines( density( rawDfr[[nameStr]] ) )
  #--- Check for normality
  qqnorm( rawDfr[[nameStr]] )
}

describe(rawDfr)

#--- Scatterplot and Correlation Analysis (library gclus and ltm)
#     Scatterplot 
cpairs( rawDfr, panel.colors=dmat.color(abs(cor( rawDfr ))), gap=.5, 
        main="RAW Variables Ordered and Colored by Correlations")
#--- Correlation matrix 
cor( rawDfr )
#--- Perform correlation test for matrix (library ltm)
#     Correlation null hypothesis is that the correlation is zero (not correlated)
#     If the p-value is less than the alpha level, then the null hypothesis is rejected
#     Check for correlation p<0.05 is correlated
rcor.test( rawDfr )

#--- Simple Regression (unstandardized)
#     Y   = endurance
#     X   = age
raw1Lm <- lm(rawDfr$endurance ~ rawDfr$age)
summary(raw1Lm)
#--- Simple Regression (standardized)
sraw1Lm <- lm(scale(rawDfr$endurance) ~ scale(rawDfr$age))
summary(sraw1Lm)

#--- Simple Regression (unstandardized)
#     Y   = endurance
#     X   = activeyears
raw2Lm <- lm(rawDfr$endurance ~ rawDfr$activeyears)
summary(raw2Lm)
#--- Simple Regression (standardized)
sraw2Lm <- lm(scale(rawDfr$endurance) ~ scale(rawDfr$activeyears))
summary(sraw2Lm)

#--- Multiple Regression (unstandardized)
#     Y   = endurance
#     X1  = age
#     X2  = activeyears
raw3Lm <- lm(rawDfr$endurance ~ rawDfr$age + rawDfr$activeyears)
summary(raw3Lm)
#--- Multiple Regression (standardized)
sraw3Lm <- lm(scale(rawDfr$endurance) ~ scale(rawDfr$age) + scale(rawDfr$activeyears))
summary(sraw3Lm)

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|

