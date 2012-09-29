#|------------------------------------------------------------------------------------------|
#|                                                                             getmonitor.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Question                                                                          |
#|    Write a function named 'getmonitor' that takes THREE (3) arguments:                   |
#|    (1) 'id'                                                                              |
#|    (2) 'directory'                                                                       |
#|    (3) 'summarize'                                                                       |
#|                                                                                          |
#|    Given a monitor ID number, 'getmonitor' reads that monitor's particulate matter data  |
#|  from the directory specified in the 'directory' argument and returns a data frame       |
#|  containing that monitor's data. If 'summarize = TRUE', then 'getmonitor' produces a     |
#|  summary of the data frame with the 'summary' function and prints it to the console.     |
#|                                                                                          |
#|    Please save your code to a file named getmonitor.R. To run the test script for this   |
#|  part, make sure your working directory has the file getmonitor.R in it and the run:     |
#|                                                                                          |
#|    > source("http://spark-public.s3.amazonaws.com/compdata/scripts/getmonitor-test.R")   |
#|    > getmonitor.testscript()                                                             |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Computing in Data Analysis (Roger Peng) Assignment 1 Part 1 Week 2:    |
#|            Input:    THREE HUNDRED AND TWENTY TWO (322) data files (.csv) in 'specdata'  |
#|                        folder.                                                           |
#|            Output:   ONE (1) data frame as ID = 1.                                       |
#|                      ONE (1) data frame and summary as ID = 101.                         |
#|                      ONE (1) data frame and summary as ID = 200.                         |
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
data <- getmonitor(1, "specdata")
head(data)

#--- Get data frame and summary as ID = 101
data <- getmonitor(101, "specdata", TRUE)
head(data)

#--- Get data frame and summary as ID = 200
data <- getmonitor(200, "specdata", TRUE)

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
