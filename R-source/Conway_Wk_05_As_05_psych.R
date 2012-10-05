#|------------------------------------------------------------------------------------------|
#|                                                               Conway_Wk_05_As_05_psych.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    Suppose an experiment was conducted to test whether Working Memory (WM) training      |
#|  works as well as Study Program (SP) training to boost performance on a university       |
#|  admission test (UAT). Assume that high school students were recruited and randomly      |
#|  assigned to ONE (1) of TWO (2) conditions: WM training or SP training. Further assume   |
#|  that EACH student was tested on the UAT BEFORE and AFTER training (so we have pre- and  |
#|  post-training scores on the UAT). Use the data in DAA.04.txt.                           |
#|                                                                                          |
#|    Round to TWO (2) significant digits (for example, if the correlation is .456 then     |
#|  write .46).                                                                             |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Assignment 5 Week 5 Coursera Statistics One:                                                            |
#|            Input:    DAA.04.txt                                                          |
#|            Output:   TWO (2) dependent t-test and ONE (1) independent t-test.            |
#|                      THREE (3) Cohen's d-values.                                         |
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
rawDfr <- Init("DAA.04.txt")

#--- Count of raw data
nrow(rawDfr)

#--- Names of header
names(rawDfr)

#--- Create subsets of data for EACH group
wmDfr <- subset( rawDfr, rawDfr$training == "WM" )
spDfr <- subset( rawDfr, rawDfr$training == "SP")

#--- Dependent t-test for SP group
t.test(spDfr$pre.uat, spDfr$post.uat, paired=T)

#--- Calculate effect size for dependent t-test (Cohen's d value)
#       d = (Mean(X) - 0) / SD(X), pop mean = 0
spDescDfr <- describe(spDfr)
spDescDfr[4,3] / spDescDfr[4,4]

#--- Dependent t-test for WM group
t.test(wmDfr$pre.uat, wmDfr$post.uat, paired=T)

#--- Calculate effect size for dependent t-test (Cohen's d value)
#       d = (Mean(X) - 0) / SD(X), pop mean = 0
wmDescDfr <- describe(wmDfr)
wmDescDfr[4,3] / wmDescDfr[4,4]

#--- Independent t-test
t.test(rawDfr$gain ~ rawDfr$training, var.equal=T)

#--- Calculate effect size for independent t-test
#       SD_Pooled ^ 2 = (DF_1/DF_Total) * SD_1 ^ 2 + (DF_2/DF_Total) * SD_2 ^ 2
#       d = (Mean(X_1) - Mean(X_2)) / SD_Pooled
sdPooledNum <- 19/38 * spDescDfr[4,4] + 19/38 * wmDescDfr[4,4]
(spDescDfr[4,3] - wmDescDfr[4,3])/sdPooledNum

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|

