#|------------------------------------------------------------------------------------------|
#|                                                                                   corr.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    Write a function that takes a directory of data files and a threshold for complete    |
#|  cases and calculates the correlation between sulfate and nitrate for monitor locations  |
#|  where the number of completely observed cases (on all variables) is greater than the    |
#|  threshold. The function should return a vector of correlations for the monitors that    |
#|  meet the threshold requirement. If no monitors meet the threshold requirement, then     |
#|  the function should return a numeric vector of length 0.                                |
#|                                                                                          |
#|    For this function you will need to use the 'cor' function in R which calculates the   |
#|  correlation between two vectors. Please read the help page for this function via '?cor' |
#|  and make sure that you know how to use it.                                              |
#|                                                                                          |
#|    Please save your code to a file named corr.R. To run the test script for this part,   |
#|  make sure your working directory has the file corr.R in it and then run:                |
#|                                                                                          |
#|    > source("http://spark-public.s3.amazonaws.com/compdata/scripts/corr-test.R")         |
#|    > corr.testscript()                                                                   |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Computing in Data Analysis (Roger Peng) Assignment 1 Part 3 Week 2:    |
#|            Input:    THREE HUNDRED AND TWENTY TWO (322) data files (.csv) in 'specdata'  |
#|                        folder.                                                           |
#|            Output:   ONE (1) correlations vector as threshold = 150.                     |
#|                      ONE (1) correlations vector as threshold = 400.                     |
#|                      ONE (1) correlations vector as threshold = 5000.                    |
#|                      ONE (1) correlations vector as threshold = 0.                       |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                                I N I T I A L I Z A T I O N                               |
#|------------------------------------------------------------------------------------------|
Init <- function(workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source")
{
  setwd(workDirStr)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
corr <- function(directory, threshold = 0) 
{
#---  Assert 'directory' is a character vector of length 1 indicating the location of the
#       CSV files.
#     'threshold' is a numeric vector of length 1 indicating the number of completely
#       observed observations (on all variables) required to compute the correlation 
#       between nitrate and sulfate; the default is 0.
#     Return a numeric vector of correlations.
  
#---  Assert create an empty numeric vector
  corrsNum <- numeric(0)
    
#---  Assert get a data frame as ID = 1:332
  nobsDfr <- complete("specdata")
    
#---  Assert apply threshold
  nobsDfr <- nobsDfr[ nobsDfr$nobs > threshold, ]
    
  for(cid in nobsDfr$id)
  {
  #---  Assert get a data frame as ID in $id
    monDfr <- getmonitor(cid, directory)

  #---  Assert calculate correlation between $sulfate and $nitrate
    corrsNum <- c(corrsNum, cor(monDfr$sulfate, monDfr$nitrate, use="pairwise.complete.obs"))
  }
  
  #---  Assert return value is a numeric vector of correlations
  return(corrsNum)
}

complete <- function(directory, id = 1:332) 
{
#---  Assert 'directory' is a character vector of length 1 indicating the location of the
#       CSV files.
#     'id' is an integer vector indicating the monitor ID numbers to be used
#     Return a data frame of the form:
#       id nobs
#       1  117
#       2  1041
#       ...
#       where 'id' is the monitor ID number and 'nobs' is the number of complete cases
  
#---  Assert create an empty vector
  nobsNum <- numeric(0)
  
  for(cid in id)
  {
  #---  Assert get data frame as ID
    cDfr <- getmonitor(cid, directory)
    
  #---  Assert count the number of complete cases and append to numeric vector
    nobsNum <- c( nobsNum, nrow(na.omit(cDfr)) )
  }
  
#---  Assert return value is a data frame with TWO (2) columns
  data.frame(id=id, nobs=nobsNum)
}

getmonitor <- function(id, directory, summarize = FALSE) 
{
#---  Assert 'id' is a vector of length 1 indicating the monitor ID number. The user can
#       specify 'id' as either an integer, a character, or a numeric.
#     'directory' is a character vector of length 1 indicating the location of the CSV files
#     'summarize' is a logical indicating whether a summary of the data should be printed to
#       the console; the default is FALSE

#---  Assert construct file name 
#       Directory is pre-appended to file name.
#       Use sprintf() to add leading zeroes.
#       E.g. "specdata/001.csv"
  fileStr <- paste(directory, "/", sprintf("%03d", as.numeric(id)), ".csv", sep="")

#---  Assert read csv
  rawDfr <- read.csv(fileStr)
  
#---  Assert summary if true
  if(summarize) 
  {
    print(summary(rawDfr))
  }
  
#---  Return value is a data frame
  return(rawDfr)
}

#|------------------------------------------------------------------------------------------|
#|                                M A I N   P R O C E D U R E                               |
#|------------------------------------------------------------------------------------------|

#--- Init set working directory
Init()

#--- Get correlations vector as threshold = 150
data <- corr("specdata", 150)
head(data)
summary(data)

#--- Get correlations vector as threshold = 400
data <- corr("specdata", 400)
head(data)
summary(data)

#--- Get correlations vector as threshold = 5000
data <- corr("specdata", 5000)
summary(data)
length(data)

#--- Get correlations vector as threshold = 0
data <- corr("specdata", 0)
summary(data)
length(data)

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
