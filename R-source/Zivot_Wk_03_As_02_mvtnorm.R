#|------------------------------------------------------------------------------------------|
#|                                                              Zivot_Wk_03_As_02_mvtnorm.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    In this lab you will become more familiar with random variables and probability       |
#|  distributions. Try to do ALL of the calculations and plots in R. You can also do        |
#|  everything in Excel too.                                                                |
#|                                                                                          |
#|    You will find the examples in probReview.R and probReview.xls (available on the       |
#|  course webpage) to be helpful for some of the exercises that follow.                    |
#|                                                                                          |
#|    Hint: you can use the R functions pnorm and qnorm to answer these questions.          |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Assignment 2 Week 3 (some code taken from probReview.R)                         |
#|            Input:    None                                                                |
#|            Output:   TWO (2) probability distribution plots.                             |
#|                      SEVERAL calculated results.                                         |
#|------------------------------------------------------------------------------------------|
library(mvtnorm)

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

#--- Calculate Pr( X > 0.10 ) where X ~ N( 0.05, 0.10^2 )
#---  Use parameters mean=0.05 and sd=0.10
1 - pnorm(0.1, mean=0.05, sd=0.1)

#--- Calculate Pr( X < -0.10 ) where X ~ N( 0.05, 0.10^2 )
pnorm(-0.1, mean=0.05, sd=0.1)

#--- Calculate Pr( -0.05 < X < 0.15 ) where X ~ N( 0.05, 0.10^2 )
#       Pr( -0.05 < X < 0.15 ) = Pr( X < 0.15 ) - Pr( X < -0.05 )
pnorm(0.15, mean=0.05, sd=0.1) - pnorm(-0.05, mean=0.05, sd=0.1)

#--- Calculate 1% quantile where X ~ N( 0.05, 0.10^2 )
qnorm(0.01, mean=0.05, sd=0.1)

#--- Calculate 5% quantile where X ~ N( 0.05, 0.10^2 )
qnorm(0.05, mean=0.05, sd=0.1)

#--- Calculate 95% quantile where X ~ N( 0.05, 0.10^2 )
qnorm(0.95, mean=0.05, sd=0.1)

#--- Calculate 99% quantile where X ~ N( 0.05, 0.10^2 )
qnorm(0.99, mean=0.05, sd=0.1)

#--- Plot TWO (2) probability distributions on a chart.
#     Microsoft monthly returns ~ N(0.05, 0.10^2)
msftReturnNum = seq( -0.25, 0.35, length=150 )
#     Starbucks monthyl returns ~ N(0.025, 0.05^2)
sbuxReturnNum = seq( -0.25, 0.35, length=150 )
#     Plot Microsoft on a new chart
plot( msftReturnNum, dnorm(msftReturnNum, mean=0.05, sd=0.10), type="l", lwd=2, 
  col="black", xlab="x", ylab="pdf", xlim=c(-0.35, 0.35), ylim=c(0, 8) )
#     Plot Starbucks on the same chart
points( sbuxReturnNum, dnorm(sbuxReturnNum, mean=0.025, sd=0.05), type="l", lwd=2,
  col="blue", lty="dotted")

#--- Calculate the 1% and 5% VaR
#     Microsoft simple monthly return (R) ~ N(0.04, 0.09^2)
#     Initial wealth w0 = $100,000
#     1% VaR is the quantile value (area=1%) * initial wealth
100000 * qnorm(0.01, mean=0.04, sd=0.09)
100000 * qnorm(0.05, mean=0.04, sd=0.09)

#--- Calculate the 1% and 5% VaR
#     Microsoft compounded monthly return (r) ~ N(0.04, 0.09^2)
#     Initial wealth w0 = $100,000
#     Hint: Compute the 1% and 5% quantile from Normal distribution for r,
#       and then convert to a simple return (R) quantile using R = e^r - 1.
100000 * ( exp(qnorm(0.01, mean=0.04, sd=0.09)) - 1 )
100000 * ( exp(qnorm(0.05, mean=0.04, sd=0.09)) - 1 )


#--- Calculate the simple monthly return
#     End Sep:  Purchase Amazon and Costco
#                 Price Amzn = $38.23
#                 Price Cost = $41.11
#     End Oct:  Sold Amazon and Costco
#                 Price Amzn = $41.29
#                 Price Cost = $41.74
amznReturnNum <- 41.29/38.23 - 1
costReturnNum <- 41.74/41.11 - 1
amznReturnNum
costReturnNum

#--- Calculate the continuously compounded return
#     r = ln(R + 1)
log(amznReturnNum + 1)
log(costReturnNum + 1)

#--- Calculate the simple monthly total return and monthly dividend yield
#     End Oct: Dividend paid by Amazon
#               Dividend Amzn = $0.10
#     Dividend Yield = Div / Cost
amznTotalReturnNum <- (41.29 + 0.10)/38.23 - 1
amznTotalReturnNum
0.10/38.23

#--- Calculate the simple and continuously compounded annual returns
#     Assume Amzn monthly returns for 12 months = 0.08004185 (from Q12)
(1 + amznReturnNum) ^ 12 - 1

#--- Calculate portfolio weights
#     Assume initial wealth w0 = $10,000
#     End Sep:  Purchase $8,000 Amzn
#               Purchase $2,000 Cost
amznWt <- 8000 / 10000
costWt <- 2000 / 10000
amznWt
costWt

#--- Calculate the simple portfolio return (assume no dividends)
amznWt * amznReturnNum + costWt * costReturnNum

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|

