#|------------------------------------------------------------------------------------------|
#|                                                                             PlusRealis.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The data for this R script comes from the URA Realis web site (www.ura.gov.sg, click  |
#|  on Realis menu) The purpose of the web site is to provide data and information about    |
#|  the caveats lodged for EVERY property transaction in Singapore.                         |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.1   Function RealisReadDfr() allows multipart files to be read into a data frame    |
#|          starting from ANY number to ANY number, instead of from ONE (1) to ANY number.  |
#|  1.0.0   Contains R functions to manipulate data from the URA Realis web site.           |
#|          Functions include RealisReadDfr(), RealisBoxplotFtr(), RealisDateSplitDfr(),    |
#|          and RealisAddressSplitDfr().                                                    |
#|------------------------------------------------------------------------------------------|
library(psych)
library(car)
library(ltm)
library(gclus)
library(RColorBrewer)
library(wordcloud)
library(quantmod)
library(ggplot2)
library(reshape2)
library(plyr)
library(scales)

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
RealisReadDfr <- function(fileStr, seqNum=1:1, 
                          workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert THREE (3) arguments:                                                   
  #       fileStr:      name of the file (without the suffix "_part_xx" and extension ".csv"
  #       seqNum:       numeric vector with bgn:end (default: 1:1)                                               
  #       workDirStr:   working directory                                             
  
  #---  Check that partNum is valid (between 1 to 999)                                 
  if( as.numeric(seqNum[1]) < 1 || as.numeric(seqNum[length(seqNum)]) > 999 ) 
    stop("seqNum MUST be between 1 AND 999")
  #---  Set working directory                                                         
  setwd(workDirStr)
  #---  Read data from split parts
  #       Append suffix to the fileStr
  #       Read each part and merge them together
  
  if( length(seqNum) > 1 )
  {
    for( id in seqNum )
    {
      #---  rbind() function will bind two data frames with the same header together
      partStr <- paste0( fileStr, "_part", sprintf("%03d", as.numeric(id)), ".csv" )
      if( id==seqNum[1] )
        retDfr <- read.csv( partStr, colClasses = "character" )
      else
      {
        tmpDfr <- read.csv( partStr, colClasses = "character" )
        retDfr <- rbind( retDfr, tmpDfr )
      }
    }
  }
  else
    retDfr <- read.csv( paste0( fileStr, ".csv" ), colClasses = "character" )
  
  #---  Return a data frame
  return(retDfr)
}

RealisBoxplotFtr <- function(inDfr, FUN=median, ...)
{
  #--- Plot a simple boxplot of the values by name
  #       (a) Order the names by the MEDIAN value and plot the boxplot.
  #       (e) Shrink the x-axis tick labels so that the abbreviated state names do NOT overlap
  #           EACH other.
  #       (f) Alter the x-axis tick labels so that they include the number of hospitals in that
  #           state in parentheses. For example, the label for the state of Connecticut would
  #           be CT (32). You will need the axis() function and when you call the boxplot()
  #           function you will want to set the option xaxt to be "n".
  valueNum <- inDfr$value
  nameFtr <- reorder(inDfr$name, inDfr$value, FUN, na.rm=TRUE)
  orderVtr <- levels(nameFtr["scores"])
  countVtr <- freqVtr(tableDfr, orderVtr)
  
  boxplot(valueNum ~ nameFtr, xaxt="n", ...)
  axis(1, at=seq_along(orderVtr), cex.axis=0.8, 
       labels=eval(substitute(paste(st," (",n,")",sep=""), list(st=orderVtr, n=countVtr) )))  
  return(nameFtr)
}

RealisDateSplitDfr <- function( dateVtr )
{
  # We will facet by year ~ month, and each subgraph will show week-of-month versus weekday
  # the year is simple
  yearVtr<-as.numeric(as.POSIXlt(dateVtr)$year+1900)
  # the month too
  monthVtr<-as.numeric(as.POSIXlt(dateVtr)$mon+1)
  # but turn months into ordered facors to control the appearance/ordering in the presentation
  monthFtr<-factor(monthVtr,levels=as.character(1:12),labels=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),ordered=TRUE)
  # the day of week is again easily found
  weekdayVtr = as.POSIXlt(dateVtr)$wday
  # again turn into factors to control appearance/abbreviation and ordering
  # I use the reverse function rev here to order the week top down in the graph
  # you can cut it out to reverse week order
  weekdayFtr<-factor(weekdayVtr,levels=rev(1:7),labels=rev(c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")),ordered=TRUE)
  # the monthweek part is a bit trickier
  # first a factor which cuts the data into month chunks
  dateYrm<-as.yearmon(dateVtr)
  dateFtr<-factor(dateYrm)
  # then find the "week of year" for each day
  weekdayNum <- as.numeric(format(dateVtr,"%W"))
  
  #---  Return a data frame         
  return(data.frame(year=yearVtr,
                    month=monthVtr,
                    monthf=monthFtr,
                    weekday=weekdayVtr,
                    weekdayf=weekdayFtr,
                    yearmonth=dateYrm,
                    yearmonthf=dateFtr,
                    week=weekdayNum))
}

RealisAddressSplitDfr <- function( inChr )                                             
{                                                                                   
  #---  Assert THREE (3) arguments:                                                   
  #       inChr:      vector of addresses                                             
  
  #---  Split address into parts      
  subChr <- substring(inChr, regexpr('#', inChr)) 
  lvlChr <- substr(subChr, 2, 3)
  untChr <- substr(subChr, 5, 6)
  
  #---  Return a data frame         
  return(data.frame(level=lvlChr, unit=untChr))
}                                                                                   

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
freqDfr <- function(inVtr)
{
  nameDfr <- inVtr
  
  #--- Count of freq by name
  table(nameDfr)
  #--- Create a data frame of freq by name
  #       Remove row.names
  tableDfr <- data.frame(name=names(tapply(nameDfr, nameDfr, length)), freq=tapply(nameDfr, nameDfr, length))
  rownames(tableDfr) <- NULL
  
  #--- Create a subset
  return(tableDfr)
}

freqVtr <- function(inDfr, orderVtr) 
{
  #---  Assert 'directory' is a character vector of length 1 indicating the location of the
  #       CSV files.
  #     'threshold' is a numeric vector of length 1 indicating the number of completely
  #       observed observations (on all variables) required to compute the correlation 
  #       between nitrate and sulfate; the default is 0.
  #     Return a numeric vector of correlations.
  
  #---  Assert create an empty numeric vector
  outVtr <- numeric(0)
  
  for(ord in orderVtr)
  {
    #---  Append numeric vector
    outVtr <- c(outVtr, inDfr[inDfr$name==ord,2])
  }
  
  #---  Assert return value is a numeric vector
  return(outVtr)
}

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|