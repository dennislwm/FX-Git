#|------------------------------------------------------------------------------------------|
#|                                                    Peng_Wk_04_As_02_Part_01-04_lattice.R |
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
#|  (1) Plot the THIRTY(30)-day mortality rates for heart attack.                           |
#|                                                                                          |
#|    Read the outcome data into R via the read.csv() function and look at the first few    |
#|  rows.                                                                                   |
#|                                                                                          |
#|    > outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")       |
#|    > head(outcome)                                                                       |
#|                                                                                          |
#|    There are many columns in this dataset. You can see how many by typing ncol(outcome)  |
#|  (you can see the number of rows with the nrow() function). In addition, you can see the |
#|  names of each column by typing names(outcome) (the names are also in the PDF document). |
#|                                                                                          |
#|    To make a simple histogram of the THIRTY(30)-day death rates from heart attack        |
#|  (column ELEVEN (11) in the outcome dataset), run:                                       |
#|                                                                                          |
#|    > outcome[, 11] <- as.numeric(outcome[, 11])                                          |
#|    > hist(outcome[, 11])                                                                 |
#|                                                                                          |
#|    Because we originally read the data in as character (by specifying colClasses =       |
#|  "character" we need to coerce the column to be numeric. You may get a warning about NAs |
#|  being introduced but that is okay. This code creates a histogram of the death rates but |
#|  could benefit from some better labelling.                                               |
#|                                                                                          |
#|    (a) Add a label to the x-axis that says "30-day Death Rate";                          |
#|    (b) Add a title for the histogram that says "Heart Attack 30-day Death Rate"          |
#|                                                                                          |
#|  (2) Plot the THIRTY(30)-day mortality rates for heart attack, heart failure, and        |
#|      pneumonia.                                                                          |
#|                                                                                          |
#|    If you haven't already, read in the outcome-of-care-measures.csv dataset:             |
#|                                                                                          |
#|    (a) Identify which columns of the data frame contain the THIRTY(30)-day death rate    |
#|        from heart attack, heart failure, and pneumonia.                                  |
#|    (b) Coerce these columns to be numeric using the as.numeric function as above.        |
#|    (c) Make histograms of the death rates for EACH outcome and put the histograms on the |
#|        same plot window. This can be done by running par(mfrow = c(3, 1)) before calling |
#|        hist(). This sets the plot window to have THREE (3) rows by ONE (1) column.       |
#|    (d) For EACH plot, make sure the x-axis label is "30-day Death Rate".                 |
#|    (e) For EACH plot, set the title of the plot to be the outcome (i.e. heart attack,    |
#|        heart failure, or pneumonia).                                                     |
#|    (f) EACH time you call hist(), a new plot is constructed using the data to be         |
#|        plotted. However, this makes it difficult to compare histograms across outcomes.  |
#|        Set ALL of the histograms to have the same numerical range on the x-axis using    |
#|        the xlim argument. You can calculate the range of a vector of numbers by using    |
#|        the range() function.                                                             |
#|                                                                                          |
#|    Try the following variations on this plot:                                            |
#|                                                                                          |
#|    (g) Instead of plotting the histograms on top of each other, plot them ALL in a row,  |
#|        side by side.                                                                     |
#|    (h) Using the median and the abline() function, draw a vertical line on EACH          |
#|        histogram at the location of the median for that outcome.                         |
#|    (i) In the title of EACH histogram, put in parentheses the mean death rate by adding  |
#|        (¯X = ??) where ?? is the actual mean for that outcome. Consult the help page for |
#|        plotmath to see how to get the ¯X to appear on the plot.                          |
#|    (j) Add a smooth density estimate on top of the histogram. To do this you need to use |
#|        the density() function and you need to set prob=TRUE when calling hist().         |
#|                                                                                          |
#|  (3) Plot THIRTY(30)-day death rates by state.                                           |
#|                                                                                          |
#|    The outcome-of-care-measures.csv file contains information about what state EACH      |
#|  hospital is located in (in the State variable). The goal of this part is to plot the    |
#|  hospital THIRTY(30)-day death rates by state.                                           |
#|                                                                                          |
#|    First, check to see how many hospitals are included in the dataset by state. We want  |
#|  to remove some states where there are very few hospitals. You can use the table()       |
#|  function to count the number of observations in EACH state.                             |
#|                                                                                          |
#|    > table(outcome$State)                                                                |
#|                                                                                          |
#|    Subset the original dataset and EXCLUDE states that contain LESS THAN TWENTY (20)     |
#|  hospitals. Name this new subsetted dataset outcome2.                                    |
#|                                                                                          |
#|    A basic boxplot of the death rates by state can be made running the following code:   |
#|                                                                                          |
#|    > death <- outcome2[, 11]                                                             |
#|    > state <- outcome2$State                                                             |
#|    > boxplot(death ~ state)                                                              |
#|                                                                                          |
#|    Add the following aspects to the plot:                                                |
#|                                                                                          |
#|    (a) Add a label to the y-axis "30-day Death Rate".                                    |
#|    (b) Add a title for the histogram "Heart Attack 30-day Death Rate by State".          |
#|    (c) Set the x- and y-axis tick labels to be perpendicular to the axes (see las).      |
#|    (d) Order the states by the MEDIAN THIRTY(30)-day death rate and plot the boxplot.    |
#|    (e) Shrink the x-axis tick labels so that the abbreviated state names do NOT overlap  |
#|        EACH other.                                                                       |
#|    (f) Alter the x-axis tick labels so that they include the number of hospitals in that |
#|        state in parentheses. For example, the label for the state of Connecticut would   |
#|        be CT (32). You will need the axis() function and when you call the boxplot()     |
#|        function you will want to set the option xaxt to be "n".                          |
#|                                                                                          |
#|  (4) Plot 30-day death rates and numbers of patients.                                    |
#|                                                                                          |
#|    The lattice package can be used to plot relationships while conditioning on various   |
#|  factor variables. The goal of this part is the plot the relationship between the number |
#|  of patients a hospital sees for a certain outcome and the THIRTY(30)-day death rate for |
#|  that outcome. The hypothesis is that the more patients a hospital sees, the better the  |
#|  outcome for the patients. We are going to examine this relationship by the hospital     |
#|  ownership type.                                                                         |
#|                                                                                          |
#|    First we need to read in the outcome data and the hospital data.                      |
#|                                                                                          |
#|    > outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")       |
#|    > hospital <- read.csv("hospital-data.csv", colClasses = "character")                 |
#|                                                                                          |
#|    Then we are going to want to merge the TWO (2) datasets together to match the         |
#|  Hospital.Ownership variable to the death rate data:                                     |
#|                                                                                          |
#|    > outcome.hospital <- merge(outcome, hospital, by = "Provider.Number")                |
#|                                                                                          |
#|    From here, we can create the relevant variables that we want to plot:                 |
#|                                                                                          |
#|    > death <- as.numeric(outcome.hospital[, 11]) ## Heart attack outcome                 |
#|    > npatient <- as.numeric(outcome.hospital[, 15])                                      |
#|    > owner <- factor(outcome.hospital$Hospital.Ownership)                                |
#|                                                                                          |
#|    (a) Use the xyplot() function in the lattice package to make a plot of the            |
#|        relationship between THIRTY(30)-day death rate for heart attack versus the number |
#|        of patients seen. The number of patients should be on the x-axis. Make sure you   |
#|        run library(lattice) before calling xyplot().                                     |
#|    (b) Set the x-axis label to be "Number of Patients Seen".                             |
#|    (c) Set the y-axis label to be "30-day Death Rate".                                   |
#|    (d) Set the title of the plot to be "Heart Attack 30-day Death Rate by Ownership".    |
#|    (e) In EACH panel of the plot, add a linear regression line highlighting the          |
#|        relationship between number of patients seen and the death rate. Use the          |
#|        panel.lmline() function for this.                                                 |
#|                                                                                          |
#|    There is NOTHING to submit for Part 1-4 of the assignment.                            |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Computing in Data Analysis (Roger Peng) Assignment 2 Part 1-4 Week 4:  |
#|            Input:    TWO (2) data files (.csv) in 'ProgAssignment2-data' folder.         |
#|            Output:   (1) ONE (1) histogram.                                              |
#|                      (2) THREE (3) histograms, with variations.                          |
#|                      (3) ONE (1) boxplot.                                                |
#|                      (4) ONE (1) xyplot.                                                 |
#|------------------------------------------------------------------------------------------|
library(lattice)

#|------------------------------------------------------------------------------------------|
#|                                I N I T I A L I Z A T I O N                               |
#|------------------------------------------------------------------------------------------|
Init <- function(fileStr, workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/ProgAssignment2-data")
{
  setwd(workDirStr)
  retDfr <- read.csv(fileStr, colClasses = "character")
  return(retDfr)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
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

#--- Init loading outcome data
outcomeDfr <- Init("outcome-of-care-measures.csv")
#--- Count of cols of data
ncol(outcomeDfr)
#--- Count of rows of data
nrow(outcomeDfr)
#--- Names of header
names(outcomeDfr)

#--- Coerce character into numeric
outcomeDfr[, 11] <- as.numeric(outcomeDfr[, 11])
outcomeDfr[, 17] <- as.numeric(outcomeDfr[, 17])
outcomeDfr[, 23] <- as.numeric(outcomeDfr[, 23])

#|------------------------------------------------------------------------------------------|
#|                            P A R T   O N E   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#--- Plot a simple histogram of the THIRTY(30)-day death rates from heart attack
#       (a) Add a label to the x-axis that says "30-day Death Rate"
#       (b) Add a title for the histogram that says "Heart Attack 30-day Death Rate"
outcomeDfr[, 11] <- as.numeric(outcomeDfr[, 11])
hist(outcomeDfr[, 11], xlab="30-day Death Rate", main="Heart Attack 30-day Death Rate")

#|------------------------------------------------------------------------------------------|
#|                            P A R T   T W O   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#--- Plot a simple histogram the THIRTY(30)-day mortality rates for:
#       (1) heart attack (column ELEVEN (11))
#       (2) heart failure (column SEVENTEEN (17))
#       (3) pneumonia (column TWENTY-THREE (23))
#--- Set ALL of the histograms to have the same numerical range on the x-axis
#       Calculate the min and max of all THREE (3) numerical vectors
allRangeNum <- c(range(na.omit(outcomeDfr[, 11])), range(na.omit(outcomeDfr[, 17])), range(na.omit(outcomeDfr[, 23])))
xMinNum <- floor(min(allRangeNum))
xMaxNum <- ceiling(max(allRangeNum))
par(mfrow = c(3, 1))
hist(outcomeDfr[, 11], xlab="30-day Death Rate", main="Heart Attack 30-day Death Rate", 
     xlim=c(xMinNum, xMaxNum))
hist(outcomeDfr[, 17], xlab="30-day Death Rate", main="Heart Failure 30-day Death Rate",
     xlim=c(xMinNum, xMaxNum))
hist(outcomeDfr[, 23], xlab="30-day Death Rate", main="Pneumonia 30-day Death Rate",
     xlim=c(xMinNum, xMaxNum))
#--- Plot a variation of the same histogram.
#       (a) Add a median line to EACH plot.
#       (b) Change the x-axis label to show the mean of the plot.
#       (c) Add a smoothed density line to EACH plot
par(mfcol = c(1, 3))
hist(outcomeDfr[, 11], xlab="30-day Death Rate", xlim=c(xMinNum, xMaxNum), prob=TRUE,
     main=substitute("Heart Attack 30-day Death Rate (" * bar(X) * " = " * k * ")", 
                     list(k=round(mean(outcomeDfr[, 11], na.rm = TRUE), digits=2))))
abline(v = median(outcomeDfr[, 11], na.rm = TRUE), col="blue")
lines(density(na.omit(outcomeDfr[, 11])), col="red", lwd=2)
hist(outcomeDfr[, 17], xlab="30-day Death Rate", xlim=c(xMinNum, xMaxNum), prob=TRUE,
     main=substitute("Heart Failure 30-day Death Rate (" * bar(X) * " = " * k * ")", 
                     list(k=round(mean(outcomeDfr[, 17], na.rm = TRUE), digits=2))))
abline(v = median(outcomeDfr[, 17], na.rm = TRUE), col="blue")
lines(density(na.omit(outcomeDfr[, 17])), col="red", lwd=2)
hist(outcomeDfr[, 23], xlab="30-day Death Rate", xlim=c(xMinNum, xMaxNum), prob=TRUE,
     main=substitute("Pneumonia 30-day Death Rate (" * bar(X) * " = " * k * ")", 
                     list(k=round(mean(outcomeDfr[, 23], na.rm = TRUE), digits=2))))
abline(v = median(outcomeDfr[, 23], na.rm = TRUE), col="blue")
lines(density(na.omit(outcomeDfr[, 23])), col="red", lwd=2)

#|------------------------------------------------------------------------------------------|
#|                          P A R T   T H R E E   P R O C E D U R E                         |
#|------------------------------------------------------------------------------------------|
#--- Count of freq by state
table(outcomeDfr$State)
#--- Create a data frame of freq by state
#       Remove row.names
tableDfr <- data.frame(State=names(tapply(outcomeDfr$State, outcomeDfr$State, length)),
                       Freq=tapply(outcomeDfr$State, outcomeDfr$State, length))
rownames(tableDfr) <- NULL

#--- Create a subset
outcome2Dfr <- outcomeDfr[outcomeDfr$State %in% subset(tableDfr$State, tableDfr$Freq>=20), ]
#--- Count of rows of data
nrow(outcome2Dfr)
#--- Count of freq by state
table(outcome2Dfr$State)

#--- Plot a simple boxplot of the THIRTY(30)-day death rates by state
#       (a) Add a label to the y-axis "30-day Death Rate"
#       (b) Add a title for the histogram "Heart Attack 30-day Death Rate by State"
#       (c) Set the x- and y-axis tick labels to be perpendicular to the axes (see las)
#       (d) Order the states by the MEDIAN THIRTY(30)-day death rate and plot the boxplot.
#       (e) Shrink the x-axis tick labels so that the abbreviated state names do NOT overlap
#           EACH other.
#       (f) Alter the x-axis tick labels so that they include the number of hospitals in that
#           state in parentheses. For example, the label for the state of Connecticut would
#           be CT (32). You will need the axis() function and when you call the boxplot()
#           function you will want to set the option xaxt to be "n".
death <- outcome2Dfr[, 11]
state <- reorder(outcome2Dfr$State, outcome2Dfr[, 11], median, na.rm=TRUE)
par(mfrow = c(1, 1), las=2)
boxplot(death ~ state, ylab="30-day Death Rate", xaxt="n",
        main="Heart Attack 30-day Death Rate by State")
orderVtr <- levels(state["scores"])
countVtr <- freqVtr(tableDfr, orderVtr)
axis(1, at=seq_along(orderVtr), cex.axis=0.7,
     labels=eval(substitute(paste(st," (",n,")",sep=""), list(st=orderVtr, n=countVtr) )))

#|------------------------------------------------------------------------------------------|
#|                          P A R T   F O U R   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#--- Init loading hospital data
hospitalDfr <- Init("hospital-data.csv")
#--- Count of cols of data
ncol(hospitalDfr)
#--- Count of rows of data
nrow(hospitalDfr)
#--- Names of header
names(hospitalDfr)

#--- Merge outcome and hospital data
mergeDfr <- merge(outcomeDfr, hospitalDfr, by = "Provider.Number")

#--- Coerce character into numeric
mergeDfr[, 11] <- as.numeric(mergeDfr[, 11])
mergeDfr[, 15] <- as.numeric(mergeDfr[, 15])

#--- Plot a simple xyplot of the the relationship between THIRTY(30)-day death rate for
#       heart attack versus the number of patients seen.
#       (a) Use the xyplot() function in the lattice package to make a plot of the            
#           relationship between THIRTY(30)-day death rate for heart attack versus the number
#           of patients seen. The number of patients should be on the x-axis. Make sure you 
#           run library(lattice) before calling xyplot().                                     
#       (b) Set the x-axis label to be "Number of Patients Seen".                             
#       (c) Set the y-axis label to be "30-day Death Rate".                                   
#       (d) Set the title of the plot to be "Heart Attack 30-day Death Rate by Ownership".    
#       (e) In EACH panel of the plot, add a linear regression line highlighting the          
#           relationship between number of patients seen and the death rate. Use the          
#           panel.lmline() function for this.                                                 
death <- mergeDfr[, 11]
npatient <- mergeDfr[, 15]
owner <- factor(mergeDfr$Hospital.Ownership)
par(mfrow = c(3, 3))
xyplot(death ~ npatient | owner, ylab="30-day Death Rate", xlab="Number of Patients Seen",
       main="Heart Attack 30-day Death Rate by Ownership",
       panel =  function(x, y, ...) {
         panel.xyplot(x, y, ...)
         panel.lmline(x, y, col="black")
       } )

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
