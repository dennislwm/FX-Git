#|------------------------------------------------------------------------------------------|
#|                                                    Peng_Wk_04_As_02_Part_05-07_lattice.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The data for this assignment come from the Hospital Compare web site                  |
#|  (http://hospitalcompare.hhs.gov) run by the U.S. Department of Health and Human         |
#|  Services. The purpose of the web site is to provide data and information about the      |
#|  quality of care at over FOUR THOUSAND (4,000) Medicare-certied hospitals in the U.S.    |
#|  This dataset essentially covers all major U.S. hospitals. This dataset is used for a    |
#|  variety of purposes, including determining whether hospitals should be fined for not    |
#|  providing high quality care to patients (see http://goo.gl/jAXFX for some background    |
#|  on this particular topic).                                                              |
#|                                                                                          |
#|    The Hospital Compare web site contains a lot of data and we will only look at a small |
#|  subset for this assignment. The zip file for this assignment contains THREE (3) files   |
#|    (1) outcome-of-care-measures.csv: Contains information about THIRTY(30)-day           |
#|        mortality and readmission rates for heart attacks, heart failure, and pneumonia   |
#|        for over FOUR THOUSAND (4,000) hospitals;                                         |
#|    (2) hospital-data.csv: Contains information about each hospital;                      |
#|    (3) Hospital_Revised_Flatfiles.pdf: Descriptions of the variables in each file (i.e   |
#|        the code book).                                                                   |
#|                                                                                          |
#|    A description of the variables in each of the files is in the included PDF file named |
#|  Hospital_Revised_Flatfiles.pdf. This document contains information about many other     |
#|  files that are not included with this programming assignment. You will want to focus on |
#|  the variables for Number NINETEEN (19) ("Outcome of Care Measures.csv") and Number      |
#|  ELEVEN (11) ("Hospital Data.csv"). You may find it useful to print out this document    |
#|  (at least the pages for Table NINETEEN (19) and ELEVEN (11)) to have next to you while  |
#|  you work on this assignment. In particular, the numbers of the variables for each table |
#|  indicate column indices in each table (i.e. "Hospital Name" is column TWO (2) in the    |
#|  outcome-of-care-measures.csv file).                                                     |
#|                                                                                          |
#| Assert Question                                                                          |
#|  (5) Finding the best hospital in a state.                                               |
#|                                                                                          |
#|    Write a function called best() that takes TWO (2) arguments: (a) the TWO(2)-character |
#|  abbreviated name of a state; and (b) an outcome name. The function reads the            |
#|  outcome-of-care-measures.csv file and returns a character vector with the name of the   |
#|  hospital that has the best (i.e. LOWEST) 30-day mortality for the specified outcome in  |
#|  that state. The hospital name is the name provided in the Hospital.Name variable. The   |
#|  outcomes can be one of "heart attack", "heart failure", or "pneumonia". The function    |
#|  should use the following template.                                                      |
#|                                                                                          |
#|    > best <- function(state, outcome) {                                                  |
#|              ## Read outcome data                                                        |
#|              ## Check that state and outcome are valid                                   |
#|              ## Return hospital name in that state with lowest 30-day death rate         |
#|      }                                                                                   |
#|                                                                                          |
#|    The function should check the validity of its arguments. If an invalid state value is |
#|  passed to best(), the function should throw an error via the stop() function with the   |
#|  exact message "invalid state". If an invalid outcome value is passed to best(), the     |
#|  function should throw an error via the stop() function with the exact message "invalid  |
#|  outcome".                                                                               |
#|                                                                                          |
#|    Save your code for this function to a file named best.R. To run the test script for   |
#|  this part, make sure your working directory has the file best.R in it.                  |
#|                                                                                          |
#|  (6) Ranking hospitals by outcome in a state.                                            |
#|                                                                                          |
#|    Write a function called rankhospital() that takes THREE (3) arguments: (a) the        |
#|  TWO(2)-character abbreviated name of a state (state); (b) an outcome (outcome); and (c) |
#|  the ranking of a hospital in that state for that outcome (num). The function reads the  |
#|  outcome-of-care-measures.csv file and returns a character vector with the name of the   |
#|  hospital that has the ranking specified by the num argument. For example, the call:     |
#|                                                                                          |
#|    > rankhospital("MD", "heart failure", 5)                                              |
#|                                                                                          |
#|  would return a character vector containing the name of the hospital with the FIFTH      |
#|  (5th) LOWEST THIRTY(30)-day death rate for heart failure. The num argument can take     |
#|  values "best", "worst", or an integer indicating the ranking (SMALLER numbers are       |
#|  better). If the number given by num is LARGER THAN the number of hospitals in that      |
#|  state, then the function should return NA. The function should use the following        |
#|  template.                                                                               |
#|                                                                                          |
#|    > rankhospital <- function(state, outcome, num = "best") {                            |
#|                      ## Read outcome data                                                |
#|                      ## Check that state and outcome are valid                           |
#|                      ## Return hospital name in that state with the given rank           |
#|                      ## THIRTY(30)-day death rate                                        |
#|      }                                                                                   |
#|                                                                                          |
#|    Hospitals that do NOT have data on a particular outcome should be excluded from the   |
#|  set of hospitals when deciding the rankings.                                            |
#|                                                                                          |
#|    If there is MORE THAN ONE (1) hospital for a given ranking, then the hospital names   |
#|  should be sorted in alphabetical order and the FIRST (1st) hospital in that set should  |
#|  be returned (i.e. if hospitals "b", "c", and "f" are tied for a given rank, then        |
#|  hospital "b" should be returned).                                                       |
#|                                                                                          |
#|    The function should check the validity of its arguments. If an invalid state value is |
#|  passed to rankhospital(), the function should throw an error via the stop() function    |
#|  with the exact message "invalid state". If an invalid outcome value is passed to        |
#|  rankhospital(), the function should throw an error via the stop() function with the     |
#|  exact message "invalid outcome". The num variable can take values "best", "worst", or   |
#|  an integer indicating the ranking (SMALLER numbers are better). If the number given     |
#|  by num is larger than the number of hospitals in that state, then the function should   |
#|  return NA.                                                                              |  
#|                                                                                          |
#|    Save your code for this function to a file named rankhospital.R. To run the test      |
#|  script for this part, make sure your working directory has the file rankhospital.R in   |
#|  it.                                                                                     |
#|                                                                                          |
#|  (7) Ranking hospitals in all states                                                     |
#|                                                                                          |
#|    Write a function called rankall() that takes TWO (2) arguments: (a) an outcome name   |
#|  (outcome); and (b) a hospital ranking (num). The function reads the outcome-of-care-    |
#|  measures.csv file and returns a TWO(2)-column data frame containing the hospital in     |
#|  EACH state that has the ranking specified in num. For example the function call         |
#|                                                                                          |
#|    > rankall("heart attack", "best")                                                     |
#|                                                                                          |
#|  would return a data frame containing the names of the hospitals that are the best in    |
#|  their respective states for THIRTY(30)-day heart attack death rates. The function       |
#|  should return a value for EVERY state (some may be NA). The FIRST (1st) column in the   |
#|  data frame is named hospital, which contains the hospital name, and the SECOND (2nd)    |
#|  column is named state, which contains the TWO(2)-character abbreviation for the state   |
#|  name. The function should use the following template.                                   |
#|                                                                                          |
#|    > rankall <-  function(outcome, num = "best") {                                       |
#|                  ## Read outcome data                                                    |
#|                  ## For each state, find the hospital of the given rank                  |
#|                  ## Return a data frame with the hospital names and the (abbreviated)    |
#|                  ## state name                                                           |
#|      }                                                                                   |
#|                                                                                          |
#|    Hospitals that do NOT have data on a particular outcome should be excluded from the   |
#|  set of hospitals when deciding the rankings.                                            |
#|                                                                                          |
#|    If there is MORE THAN ONE (1) hospital for a given ranking, then the hospital names   |
#|  should be sorted in alphabetical order and the FIRST (1st) hospital in that set should  |
#|  be returned (i.e. if hospitals "b", "c", and "f" are tied for a given rank, then        |
#|  hospital "b" should be returned).                                                       |
#|                                                                                          |
#|    NOTE: For the purpose of this part of the assignment (and for efficiency), your       |
#|  function should NOT call the rankhospital() function from the previous section.         |
#|                                                                                          |
#|    The function should check the validity of its arguments. If an invalid outcome value  |
#|  is passed to rankall(), the function should throw an error via the stop() function with |
#|  the exact message "invalid outcome". The num variable can take values "best", "worst",  |
#|  or an integer indicating the ranking (SMALLER numbers are better). If the number given  |
#|  by num is larger than the number of hospitals in that state, then the function should   |
#|  return NA.                                                                              |
#|                                                                                          |
#|    Save your code for this function to a file named rankall.R. To run the test script    |
#|  for this part, make sure your working directory has the file rankall.R in it.           |                                                                                    |
#|                                                                                          |
#|  Assert Grading                                                                          |
#|    This assignment will be graded using unit tests executed via the submit script that   |
#|  you run on your computer. To obtain the submit script, run the following code in R:     |
#|                                                                                          |
#|    > source("http://spark-public.s3.amazonaws.com/compdata/scripts/submitscript.R")      |
#|                                                                                          |
#|    The FIRST (1st) time you run the submit script it will prompt you for your Submission |
#|  login AND Submission password:                                                          |
#|                                                                                          |
#|    User ID:              71658                                                           |
#|    Submission Login:     dennislwm@yahoo.com.au                                          |
#|    Submission Password:  SYVCcKFBjX                                                      |
#|                                                                                          |
#|  To execute the submit script, type                                                      |
#|                                                                                          |
#|    > submit()                                                                            |
#|                                                                                          |
#|    NOTE that the submit script requires that you be connected to the Internet in order   |
#|  to work properly. When you execute the submit script in R, you will see the following   |
#|  menu (after typing in your submission login email and password):                        |
#|                                                                                          |
#|    [1] 'best' part 1                                                                     |
#|    [2] 'best' part 2                                                                     |
#|    [3] 'best' part 3                                                                     |
#|    [4] 'rankhospital' part 1                                                             |
#|    [5] 'rankhospital' part 2                                                             |
#|    [6] 'rankhospital' part 3                                                             |
#|    [7] 'rankhospital' part 4                                                             |
#|    [8] 'rankall' part 1                                                                  |
#|    [9] 'rankall' part 2                                                                  |
#|    [10] 'rankall' part 3                                                                 |
#|    Which part are you submitting [1-10]?                                                 |
#|                                                                                          |
#|    Entering a number between ONE (1) AND TEN (10) will execute the corresponding part of |
#|  the homework. We will compare the output of your functions to the correct output. For   |
#|  EACH test passed you receive the specified number of points on the Assignments List web |
#|  page. There are TEN (10) tests to pass (each worth THREE (3) points) for a TOTAL of     |
#|  THIRTY (30) points for the entire assignment.                                           |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Computing in Data Analysis (Roger Peng) Assignment 2 Part 5-7 Week 4:  |
#|            Input:    TWO (2) data files (.csv) in 'ProgAssignment2-data' folder.         |
#|            Output:   (5) THREE (3) characters.                                           |
#|                      (6) THREE (3) characters.                                           |
#|                      (7) SEVEN (7) data frames.                                          |
#|------------------------------------------------------------------------------------------|
library(lattice)

#|------------------------------------------------------------------------------------------|
#|                                I N I T I A L I Z A T I O N                               |
#|------------------------------------------------------------------------------------------|
Init <- function(fileStr, workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source")
{
  setwd(workDirStr)
  retDfr <- read.csv(fileStr, colClasses = "character")
  return(retDfr)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
rankall <- function(outcomeChr, rankObj="best")
{
#--- Init loading outcome data
  outcomeDfr <- Init("ProgAssignment2-data/outcome-of-care-measures.csv")
  
#--- Coerce character into numeric
  suppressWarnings( outcomeDfr[, 11] <- as.numeric(outcomeDfr[, 11]) )
  suppressWarnings( outcomeDfr[, 17] <- as.numeric(outcomeDfr[, 17]) )
  suppressWarnings( outcomeDfr[, 23] <- as.numeric(outcomeDfr[, 23]) )
  
#--- Create a data frame of freq by state
#       Remove row.names
  tableDfr <- data.frame(State=names(tapply(outcomeDfr$State, outcomeDfr$State, length)),
                         Freq=tapply(outcomeDfr$State, outcomeDfr$State, length))
  rownames(tableDfr) <- NULL
  
#--- Create a data frame of possible inputs and respective columns
  inputDfr <- data.frame(Outcome=c("heart attack", "heart failure","pneumonia"), Col=c(11, 17, 23))
  
#--- Check that outcome is valid
  if( nrow(inputDfr[inputDfr$Outcome==outcomeChr,]) == 0 ) stop( "invalid outcome" )

#---  Assert create an empty vector
#       Add column rank for debug
  nameChr <- character(0)
  #rankChr <- character(0)
  
#--- Return hospital name in that state with the ranked THIRTY(30)-day death rate
#       Create a data frame with given ONE (1) state
#       Determine the relevant column
#       Reorder the new data frame from best to worst
  for(stateChr in tableDfr$State)
  {
    stateDfr <- outcomeDfr[outcomeDfr$State==stateChr, ]
    colNum <- inputDfr[inputDfr$Outcome==outcomeChr, 2]
    stateDfr <- stateDfr[complete.cases(stateDfr[, colNum]), ]
    stateDfr <- stateDfr[order(stateDfr[, colNum], stateDfr$Hospital.Name), ]
  
#--- Convert "best" and "worst" to numeric
#       Determine the relevant row
    if( rankObj=="best" )   rankNum <- 1
    else if( rankObj=="worst" )  rankNum <- nrow(stateDfr)
    else suppressWarnings( rankNum <- as.numeric(rankObj) )
    
#---  Append hospital name to character vector
    nameChr <- c( nameChr, stateDfr[rankNum, ]$Hospital.Name )
    #rankChr <- c( rankChr, rankNum )
  }
  
#--- Return value is a data frame (hospital, state)
  return( data.frame(hospital=nameChr, state=tableDfr$State) )
}

rankhospital <- function(stateChr, outcomeChr, rankObj)
{
#--- Init loading outcome data
  outcomeDfr <- Init("ProgAssignment2-data/outcome-of-care-measures.csv")
  
#--- Coerce character into numeric
  suppressWarnings( outcomeDfr[, 11] <- as.numeric(outcomeDfr[, 11]) )
  suppressWarnings( outcomeDfr[, 17] <- as.numeric(outcomeDfr[, 17]) )
  suppressWarnings( outcomeDfr[, 23] <- as.numeric(outcomeDfr[, 23]) )
  
#--- Create a data frame of freq by state
#       Remove row.names
  tableDfr <- data.frame(State=names(tapply(outcomeDfr$State, outcomeDfr$State, length)),
                         Freq=tapply(outcomeDfr$State, outcomeDfr$State, length))
  rownames(tableDfr) <- NULL
  
#--- Create a data frame of possible inputs and respective columns
  inputDfr <- data.frame(Outcome=c("heart attack", "heart failure","pneumonia"), Col=c(11, 17, 23))
  
#--- Check that state and outcome are valid
  if( nrow(tableDfr[tableDfr$State==stateChr,]) == 0 ) stop( "invalid state" )
  if( nrow(inputDfr[inputDfr$Outcome==outcomeChr,]) == 0 ) stop( "invalid outcome" )
  
#--- Return hospital name in that state with the ranked THIRTY(30)-day death rate
#       Create a data frame with given ONE (1) state
#       Determine the relevant column
#       Reorder the new data frame from best to worst
  stateDfr <- outcomeDfr[outcomeDfr$State==stateChr, ]
  colNum <- inputDfr[inputDfr$Outcome==outcomeChr, 2]
  stateDfr <- stateDfr[complete.cases(stateDfr[, colNum]), ]
  stateDfr <- stateDfr[order(stateDfr[, colNum], stateDfr$Hospital.Name), ]
  
#--- Convert "best" and "worst" to numeric
#       "Worst" code is not valid if omit NA from results
#       Determine the relevant row
  if( rankObj=="best" )   rankObj <- 1
  if( rankObj=="worst" )  rankObj <- nrow(stateDfr)
  #  if( rankObj=="worst" )  rankObj <- tableDfr[tableDfr$State==stateChr, 2]
  suppressWarnings( rankNum <- as.numeric(rankObj) )
  
#--- Return value is a character
#       Return data frame for debug
  return( stateDfr[rankNum, ]$Hospital.Name )
  #return(stateDfr)
}

best <- function(stateChr, outcomeChr)
{
#--- Init loading outcome data
  outcomeDfr <- Init("ProgAssignment2-data/outcome-of-care-measures.csv")
  
#--- Coerce character into numeric
  suppressWarnings( outcomeDfr[, 11] <- as.numeric(outcomeDfr[, 11]) )
  suppressWarnings( outcomeDfr[, 17] <- as.numeric(outcomeDfr[, 17]) )
  suppressWarnings( outcomeDfr[, 23] <- as.numeric(outcomeDfr[, 23]) )
  
#--- Create a data frame of freq by state
#       Remove row.names
  tableDfr <- data.frame(State=names(tapply(outcomeDfr$State, outcomeDfr$State, length)),
                         Freq=tapply(outcomeDfr$State, outcomeDfr$State, length))
  rownames(tableDfr) <- NULL
  
#--- Create a data frame of possible inputs and respective columns
  inputDfr <- data.frame(Outcome=c("heart attack", "heart failure","pneumonia"), Col=c(11, 17, 23))
  
#--- Check that state and outcome are valid
  if( nrow(tableDfr[tableDfr$State==stateChr,]) == 0 ) stop( "invalid state" )
  if( nrow(inputDfr[inputDfr$Outcome==outcomeChr,]) == 0 ) stop( "invalid outcome" )
  
#--- Return hospital name in that state with lowest THIRTY(30)-day death rate
#       Create a data frame with given ONE (1) state
#       Determine the relevant row and column
  stateDfr <- outcomeDfr[outcomeDfr$State==stateChr, ]
  colNum <- inputDfr[inputDfr$Outcome==outcomeChr, 2]
  rowNum <- which.min(stateDfr[, colNum])
  return( stateDfr[rowNum, ]$Hospital.Name )
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
    outVtr <- c(outVtr, inDfr[inDfr$State==ord,2])
  }
  
  #---  Assert return value is a numeric vector
  return(outVtr)
}

#|------------------------------------------------------------------------------------------|
#|                                M A I N   P R O C E D U R E                               |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                          P A R T   F I V E   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
best("TX", "heart attack")
best("TX", "heart failure")
best("MD", "heart attack")
best("MD", "pneumonia")

#|------------------------------------------------------------------------------------------|
#|                            P A R T   S I X   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
rankhospital("TX", "heart failure", 4)
rankhospital("MD", "heart attack", "worst")
rankhospital("NC", "heart attack", "worst")

#|------------------------------------------------------------------------------------------|
#|                          P A R T   S E V E N   P R O C E D U R E                         |
#|------------------------------------------------------------------------------------------|
head(rankall("heart attack", 20), 10)
tail(rankall("pneumonia", "worst"), 3)
tail(rankall("heart failure"), 10)
rankall("pneumonia", "worst")
rankall ("heart attack", "best")
rankall ("heart failure", "best")
rankall ("pneumonia", "best")

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
