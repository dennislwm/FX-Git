#|------------------------------------------------------------------------------------------|
#|                                                                  Conway_Wk_As_02_psych.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    For Assignment #1 we assumed that a working memory training experiment was conducted  |
#| in which subjects were randomly assigned to ONE (1) of TWO (2) conditions:               |
#|    1. Designed sports training (des)                                                     |
#|    2. Aerobic training (aer)                                                             |
#|                                                                                          |
#|    For the first assignment we assumed that both verbal and spatial working memory       |
#| capacity were measured BEFORE and AFTER training but we assumed that only ONE (1) task   |
#| per construct was administered. A better approach would be to administer TWO (2) tasks   |
#| per construct. This would allow for stronger arguments about training effects because    |
#| reliability and validity can be assessed via correlation analyses.                       |
#|                                                                                          |
#|    So, this time, ASSUME there are TWO (2) measures of spatial working memory and        |
#| TWO (2) measures of verbal working memory, administered BEFORE and AFTER training.       |
#|                                                                                          |
#|    Fictional data are available in the file: DAA.02.txt.                                 |
#|                                                                                          |
#|    Write an R script that does the following:                                            |
#|    (1) Provides descriptive statistics for all EIGHT (8) measures, for each condition.   |
#|    (2) Provides an EIGHT by EIGHT (8x8) correlation matrix, for each condition.          |
#|                                                                                          |
#|    Then, based on the R output, answer the following FIVE (5) questions (omitted):       |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Assignment 2 Week 2:                                                            |
#|            Input:    DAA.02.txt                                                          |
#|            Output:   EIGHT (8) histograms and EIGHT(8) Q-Q plots, per condition.         |
#|                      EIGHT (8) descriptive statistics, per condition.                    |
#|                      EIGHT by EIGHT (8x8) correlation matrix, per condition.             |
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
wmtDfr <- Init("DAA.02.txt")

#--- Count of raw data
nrow(wmtDfr)

#--- Names of header
wmtNameStr <- names(wmtDfr)

#--- Split raw data into TWO (2) data frames, omit first column
desDfr <- wmtDfr[ wmtDfr$cond=="des", 3:10 ]
aerDfr <- wmtDfr[ wmtDfr$cond=="aer", 3:10 ]

#--- Sum of TWO (2) data frames should equal count
nrow(desDfr) + nrow(aerDfr)

#--- Layout
layout(matrix(1:32,4,8,byrow=TRUE))

#--- Custom Plot
for( nameStr in names(desDfr) )
{
  #--- Check for normality p>0.05 is normal
  p <- shapiro.test( desDfr[[nameStr]] )$p.value
  hist( desDfr[[nameStr]], prob=T, main=c( paste("DES", nameStr), paste("Shapiro p=",prettyNum(p,digits=2)) ), xlab=nameStr, xlim=c(0,50) )
  lines( density( desDfr[[nameStr]] ) )
  #--- Check for normality
  qqnorm( desDfr[[nameStr]] )
}

for( nameStr in names(aerDfr) )
{
  #--- Check for normality p>0.05 is normal
  p <- shapiro.test( desDfr[[nameStr]] )$p.value
  hist( aerDfr[[nameStr]], prob=T, main=c( paste("AER", nameStr), paste("Shapiro p=",prettyNum(p,digits=2)) ), xlab=nameStr, xlim=c(0,50) )
  lines( density( aerDfr[[nameStr]] ) )
  #--- Check for normality
  qqnorm( desDfr[[nameStr]] )
}

describe(desDfr)
describe(aerDfr)

#--- Scatterplot and Correlation Analysis (library gclus and ltm)
#     Scatterplot DES
cpairs( desDfr, panel.colors=dmat.color(abs(cor( desDfr ))), gap=.5, 
        main="DES Variables Ordered and Colored by Correlations")
#--- Correlation matrix DES
cor( desDfr )
#--- Perform correlation test for matrix (library ltm)
#     Correlation null hypothesis is that the correlation is zero (not correlated)
#     If the p-value is less than the alpha level, then the null hypothesis is rejected
#     Check for correlation p<0.05 is correlated
rcor.test( desDfr )

#--- Scatterplot and Correlation Analysis (library gclus and ltm)
#     Scatterplot AER
cpairs( aerDfr, panel.colors=dmat.color(abs(cor( aerDfr ))), gap=.5, 
        main="AER Variables Ordered and Colored by Correlations")
#--- Correlation matrix for AER
cor( aerDfr )
#--- Perform correlation test for matrix (library ltm)
#     Correlation null hypothesis is that the correlation is zero (not correlated)
#     If the p-value is less than the alpha level, then the null hypothesis is rejected
#     Check for correlation p<0.05 is correlated
rcor.test( aerDfr )

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|

