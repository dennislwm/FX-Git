#|------------------------------------------------------------------------------------------|
#|                                                              Zivot_Wk_04_As_03_mvtnorm.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    Let X and Y be distributed bivariate normal with muX=0.05, muY=0.025, sigX=0.10,      |
#|  sigY=0.05                                                                               |
#|    (a) rhoXY =  0.9                                                                      |
#|    (b) rhoXY = -0.9                                                                      |
#|    (c) rhoXY =  0                                                                        |
#|                                                                                          |
#|    Using R package mvtnorm function rmvnorm(), simulate 100 observations from the        |
#|  bivariate distribution with rhoXY equal to (a), (b) and (c).                            |
#|                                                                                          |
#|    Using the plot() function create a scatterplot of the observations and comment on the |
#|  direction and strength of the linear association.                                       |
#|                                                                                          |
#|    Using the function pmvnorm(), compute the joint probability Pr(X < 0,Y < 0).          |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Assignment 3 Week 4 (some code taken from lab3.R)                               |
#|            Input:    Nil                                                                 |
#|            Output:   THREE (3) scatter plots.                                            |
#|                      THREE (3) computed joint probabilities.                             |
#|------------------------------------------------------------------------------------------|
library(mvtnorm)

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
CalcSigmaMtx <- function(rho.xy, sig.x, sig.y)
{
  #---- Assert simulate from bivariate normal with rho
  sig.xy = rho.xy*sig.x*sig.y
  matrix(c(sig.x^2, sig.xy, sig.xy, sig.y^2), 2, 2, byrow=TRUE)
}

GenerateBiNormMtx <- function(rho.xy, n=100, seed=123, mu.x, mu.y, sig.x, sig.y, sigma.xy)
{
  #---- Assert use the rmvnorm() function to simulate from bivariate normal
  set.seed(seed)
  xy.vals = rmvnorm(n, mean=c(mu.x, mu.y), sigma=sigma.xy) 
}

#|------------------------------------------------------------------------------------------|
#|                                M A I N   P R O C E D U R E                               |
#|------------------------------------------------------------------------------------------|
#---- Assert THREE (3) plots on the same chart
layout(matrix(1:3,3,1,byrow=TRUE))

muX   = 0.05
sigX  = 0.10
muY   = 0.025
sigY  = 0.05

#---- Assert generate random values for rhoXY =  0.9
sigmaXY <- CalcSigmaMtx(rho.xy=0.9, sigX, sigX)
sigmaXY
valXY   <- GenerateBiNormMtx(rho.xy=0.9, n=100, seed=123, muX, muY, sigX, sigY, sigmaXY)
head(valXY)

#---- Assert scatterplot
plot(valXY[,1], valXY[,2], pch=16, cex=2, col="blue", xlab="x", ylab="y")
title("Bivariate normal: rho=0.9")
abline(h=muY, v=muX)

#---- Assert compute area under bivariate standard normal distribution
#       Find P( -00 < X < 0 and -00 < Y < 0)
pmvnorm(lower=c(-Inf, -Inf), upper=c(0, 0), mean=c(muX, muY), sigma=sigmaXY)

#---- Assert generate random values for rhoXY = -0.9
sigma2XY <- CalcSigmaMtx(rho.xy=-0.9, sigX, sigX)
sigma2XY
val2XY   <- GenerateBiNormMtx(rho.xy=-0.9, n=100, seed=231, muX, muY, sigX, sigY, sigma2XY)
head(val2XY)

#---- Assert scatterplot
plot(val2XY[,1], val2XY[,2], pch=16, cex=2, col="blue", xlab="x", ylab="y")
title("Bivariate normal: rho=-0.9")
abline(h=muY, v=muX)

#---- Assert compute area under bivariate standard normal distribution
#       Find P( -00 < X < 0 and -00 < Y < 0)
pmvnorm(lower=c(-Inf, -Inf), upper=c(0, 0), mean=c(muX, muY), sigma=sigma2XY)

#---- Assert generate random values for rhoXY =  0
sigma3XY <- CalcSigmaMtx(rho.xy=0, sigX, sigX)
sigma3XY
val3XY   <- GenerateBiNormMtx(rho.xy=0, n=100, seed=321, muX, muY, sigX, sigY, sigma3XY)
head(val3XY)

#---- Assert scatterplot
plot(val3XY[,1], val3XY[,2], pch=16, cex=2, col="blue", xlab="x", ylab="y")
title("Bivariate normal: rho=0")
abline(h=muY, v=muX)

#---- Assert compute area under bivariate standard normal distribution
#       Find P( -00 < X < 0 and -00 < Y < 0)
pmvnorm(lower=c(-Inf, -Inf), upper=c(0, 0), mean=c(muX, muY), sigma=sigma3XY)

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|