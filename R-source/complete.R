#|------------------------------------------------------------------------------------------|
#|                                                                               complete.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    Write a function that reads a directory full of files and reports the number of       |
#|  completely observed cases in each data file. The function should return a data frame    |
#|  where the first column is the name of the file and the second column is the number of   |
#|  complete cases.                                                                         |
#|                                                                                          |
#|    Please save your code to a file named complete.R. To run the test script for this     |
#|  part, make sure your working directory has the file complete.R in it and the run:       |
#|                                                                                          |
#|    > source("http://spark-public.s3.amazonaws.com/compdata/scripts/complete-test.R")     |
#|    > complete.testscript()                                                               |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Computing in Data Analysis (Roger Peng) Assignment 1 Part 2 Week 2:    |
#|            Input:    THREE HUNDRED AND TWENTY TWO (322) data files (.csv) in 'specdata'  |
#|                        folder.                                                           |
#|            Output:   ONE (1) data frame as ID = 1.                                       |
#|                      ONE (1) data frame as ID = 2,4,6,8,10.                              |
#|                      ONE (1) data frame as ID = 30...25.                                 |
#|                      ONE (1) data frame as ID = 3.                                       |
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

#--- Get data frame as ID = 1
complete("specdata", 1)

#--- Get data frame as ID = 2,4,6,8,10
complete("specdata", c(2, 4, 8, 10, 12))

#--- Get data frame and summary as ID = 30..25
complete("specdata", 30:25)

#--- Get data frame and summary as ID = 3
complete("specdata", 3)

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
