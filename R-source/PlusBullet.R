#|------------------------------------------------------------------------------------------|
#|                                                                             PlusBullet.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The data for this R script comes from Yahoo Finance, which is NOT 100% reliable as    |
#|  there have been documented cases of missing data, e.g. dividends. We use the adjusted   |
#|  close prices as these have been adjusted for BOTH splits and dividends. This means that |
#|  the returns on the adjusted close prices are the Total Shareholder Returns (TSRs),      |
#|  which includes BOTH percent capital gain and dividend yield.                            |
#|                                                                                          |
#| Assert Function                                                                          |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This library contains external R functions to perform portfolio analysis.       |
#|------------------------------------------------------------------------------------------|
library(corpcor)
library(tseries)
library(zoo)
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/portfolio_noshorts.R")

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
BulletCerParameterLst <- function( dcgZoo )
{
  #---  Check integrity of data
  #       Check ALL symbols have been downloaded
  #       Check for NAs
  if( isZoo.na(dcgZoo) )
    dcgZoo <- bulletRepZoo(dcgZoo)
  
  retZoo <- diff(log(dcgZoo))
  
  #---  Compute estimates of CER model parameters
  muHat.num <-  apply(retZoo, 2, mean)
  varHat.num <- apply(retZoo, 2, var)
  sdHat.num <-  apply(retZoo, 2, sd)
  cov.mat <-    var(retZoo)
  cor.mat <-    cor(retZoo)
  
  #---  Check for positive definite using package corpcor
  if( !is.positive.definite(cov.mat) )
    cov.mat <- make.positive.definite(cov.mat)
  
  ans <- list("muHat"     = muHat.num,
              "varHat"    = varHat.num,
              "sigmaHat"  = sdHat.num,
              "covHat"    = cov.mat,
              "corHat"    = cor.mat
              )
  ans
}

BulletPortMuNum <- function( wt.num, muHat.num )
{
  as.numeric( crossprod(wt.num, muHat.num) )
}

BulletPortSigmaNum <- function( wt.num, cov.mat )
{
  var.num <- t(wt.num)%*%cov.mat%*%wt.num
  as.numeric( sqrt(var.num) )
}

BulletGetHistZoo <- function( symChr, startDate="2004-01-01", finishDate="2012-10-31" )
{
  #---  Assert TWO (2) arguments:                                                   
  #       symChr:       a character vector of symbols from Yahoo finance
  #       startDate:    a string value for start date in YYYY-MM-DD (default: "2004-01-01")
  #       finishDate:   a string value for end date in YYYY-MM-DD (default: "2012-10-31") 
  
  #---  Check that arguments are valid
  if( length(which(symChr=="")) > 0 )
    stop("symChr MUST contain ONLY valid symbols from Yahoo Finance")
  
  #---  Assert create an empty zoo
  mergeZoo <- zoo(0)
  namesChr <- as.character(NULL)
  
  for( tickerChr in symChr )
  {
    tickerZoo = tryCatch( suppressWarnings(get.hist.quote( instrument=tickerChr, start=startDate, 
                                                           end=finishDate,       quote="AdjClose", 
                                                           provider="yahoo",     origin="1970-01-01",
                                                           compression="m",      quiet=TRUE,      
                                                           retclass="zoo")),
                          error=function(e) { NULL }, finally={} )
    
    if( is.null(tickerZoo) ) 
    {
      warning( paste0("Unable to download data for symbol ", tickerChr),
               immediate. = TRUE )
    }
    else
    {
      #--- Change class of time index to yearmon which is appropriate for monthly data
      #       index() and as.yearmon() are functions in the zoo package 
      index(tickerZoo) = as.yearmon(index(tickerZoo))
      
      #--- Create merged price data
      if( is.null(nrow(mergeZoo)) )
        mergeZoo <- tickerZoo
      else
        mergeZoo <- merge(mergeZoo, tickerZoo)
      namesChr <- c(namesChr, tickerChr)
    }
  }
  if( is.null(nrow(mergeZoo)) )
    return( NULL )
  else
  {
    #--- Rename columns
    colnames(mergeZoo) = namesChr
    
    #--- Return value is a zoo
    return(mergeZoo)
  }
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
isZoo.na <- function( priceZoo )
{
  #---  Check that arguments are valid
  if( is.null(priceZoo) ) return( FALSE )
  
  r0.num <- nrow(priceZoo)
  r1.num <- nrow(priceZoo[complete.cases(priceZoo), ])

  return( !(r0.num==r1.num) )
}

bulletRepZoo <- function( priceZoo )
{
  #---  Check that arguments are valid
  #       Zoo object is NULL
  #       Zoo object has at least ONE (1) column with first element as NA
  #       Zoo object has LESS THAN TWO (2) rows
  if( is.null(priceZoo) ) return( NULL )
  
  val.num <- priceZoo[1, ]
  if( length(which(apply(val.num, 2, is.na)))>0 )
    stop("Object contains at least ONE (1) column with first element as NA")
  
  if( nrow(priceZoo) < 2 ) return( priceZoo )
  
  for( i in 2:nrow(priceZoo) )
  {
    naCol.num <- which(apply(priceZoo[i, ], 2, is.na))
    #---  Replace NA with previous month's value
    if(length(naCol.num)>0)
    {
      for( j in 1:length(naCol.num) )
      {
        naCol <- naCol.num[j]
        priceZoo[i, naCol] <- val.num[1, naCol]
      }
    }
    val.num <- priceZoo[i, ]
  }
  priceZoo
}

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|