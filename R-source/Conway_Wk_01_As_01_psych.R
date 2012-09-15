#|------------------------------------------------------------------------------------------|
#|                                                                     Conway_Wk_01_psych.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    Working memory training is a rapidly growing market with potential to further expand  |
#|  in the future. Several computerized software programs promoting cognitive improvements  |
#|  have been developed in recent years, with controversial results and implications.       |
#|                                                                                          |
#|    In a distinct literature, aerobic exercise has been shown to broadly enhance cognitive|
#|  functions, in humans and animals. My research group is attempting to bring together     |
#|  these TWO (2) trends of research, leading to an emerging third approach: designed sports|
#|  training. Specifically designed sports - wrestling, fencing, martial arts - which tax   |
#|  working memory by incorporating motion in three-dimensional space, are an optimal way to|
#|  combine the benefits of traditional cognitive training and aerobic exercise into a      |
#|  single activity.                                                                        |
#|                                                                                          |
#|    So, suppose we conducted a training experiment in which subjects were randomly        |
#|  assigned to one of two conditions:                                                      |
#|    (a) Designed sports training (des)                                                    |
#|    (b) Aerobic training (aer)                                                            |
#|                                                                                          |
#|    Also, assume that we measured both verbal (wm.v) and spatial (wm.s) working memory    |
#|  capacity before (pre) and after (post) training, using two separate measures: wm.v wm.s |
#|                                                                                          |
#|    Fictional data are available in the file: DAA.01.txt (Right click on link to save the |
#|  file to your computer.)                                                                 |
#|                                                                                          |
#|    Write an R script that does the following:                                            |
#|    (1) Plots histograms for all variables (therefore 8 histograms)                       |
#|    (2) Provides descriptive statistics for all variables                                 |
#|                                                                                          |
#|    Then, based on the R output, answer the following 5 questions (omitted):              |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Assignment 1 Week 1:                                                            |
#|            Input:  DAA.01.txt                                                            |
#|            Output: EIGHT (8) histograms and EIGHT(8) Q-Q plots                           |
#|------------------------------------------------------------------------------------------|
library(psych)

#|------------------------------------------------------------------------------------------|
#|                                I N I T I A L I Z A T I O N                               |
#|------------------------------------------------------------------------------------------|
Init <- function(fileStr, workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  retDfr <- read.table(file.choose(), header=T)
  return(retDfr)
}

#|------------------------------------------------------------------------------------------|
#|                                M A I N   P R O C E D U R E                               |
#|------------------------------------------------------------------------------------------|

#--- Init loading raw data
wmtDfr <- Init("DAA.01.txt")

#--- Count of raw data
wmtTotalInt <- nrow(wmtDfr)

#--- Names of header
wmtNameStr <- names(wmtDfr)

#--- Split raw data into TWO (2) data frames, omit first column
desDfr <- wmtDfr[ wmtDfr$cond=="des", 2:5 ]
aerDfr <- wmtDfr[ wmtDfr$cond=="aer", 2:5 ]

#--- Sum of TWO (2) data frames should equal count
nrow(desDfr) + nrow(aerDfr)

#--- Layout
layout(matrix(1:16,4,4,byrow=TRUE))

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
describe(desDfr)

for( nameStr in names(aerDfr) )
{
  #--- Check for normality p>0.05 is normal
  p <- shapiro.test( desDfr[[nameStr]] )$p.value
  hist( aerDfr[[nameStr]], prob=T, main=c( paste("AER", nameStr), paste("Shapiro p=",prettyNum(p,digits=2)) ), xlab=nameStr, xlim=c(0,50) )
  lines( density( aerDfr[[nameStr]] ) )
  #--- Check for normality
  qqnorm( desDfr[[nameStr]] )
}
describe(aerDfr)

