#|------------------------------------------------------------------------------------------|
#|                                                                        Realis_04_psych.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The data for this R script comes from the URA Realis web site (www.ura.gov.sg, click  |
#|  on Realis menu) The purpose of the web site is to provide data and information about    |
#|  the caveats lodged for EVERY property transaction in Singapore.                         |
#|                                                                                          |
#|    The URA Realis web site contains a lot of data and we will only look at a small       |
#|  subset for this R script. The files for this script are as follows:                     |
#|    (1) realis_ten_projects_treasure_newsub_2000_jan_2012_oct_18.csv                      |
#|          Contains information about NEW (incl SUB) properties for TEN (10) projects      |
#|          (including Treasure Mansions) from July 2012 to current (16 October 2012).      |
#|    (2) realis_ten_projects_treasure_resale_2000_jan_2012_oct_18.csv                      |
#|          Contains information about RESALE properties for TEN (10) projects (including   |
#|          Treasure Mansions) from January 2000 to current (18 October 2012).              |
#|                                                                                          |
#| Assert Script                                                                            |
#|                                                                                          |
#|  (2) Null Hypothesis Significance Test of EQUAL means for TWO (2) different groups.      |
#|                                                                                          |
#|  (a) Hypothesis for the independent t-test                                               |
#|                                                                                          |
#|    The null hypothesis for the independent t-test is that the population means from the  |
#|  TWO (2) unrelated groups are equal.                                                     |
#|                                                                                          |
#|  (b) Assumption of normality of the dependent variable                                   |
#|                                                                                          |
#|    The independent t-test requires that the dependent variable is approximately normally |
#|  distributed within EACH group. We can test for this using a multitude of tests, but the |
#|  Shapiro-Wilks Test or a graphical method, such as a Q-Q Plot, are very common.          |
#|                                                                                          |
#|  (c) What to do when you violate the normality assumption                                |
#|                                                                                          |
#|    If you find that either ONE (1) OR BOTH of your group's data is NOT approximately     |
#|  normally distributed and groups sizes differ greatly then you have TWO (2) options:     |
#|                                                                                          |
#|    (i)   transform your data so that the data becomes normally distributed; OR           |
#|    (ii)  run the Mann-Whitney U Test, which is a non-parametric test that does NOT       |
#|          require the assumption of normality.                                            |
#|                                                                                          |
#|  (d) Assumption of Homogeneity of Variance                                               |
#|                                                                                          |
#|    The independent t-test assumes the variances of the TWO (2) groups you are measuring  |
#|  to be equal. The assumption of homogeneity of variance can be tested using Levene's     |
#|  Test of Equality of Variances.                                                          |
#|                                                                                          |
#|  (e) Overcoming a Violation of the Assumption of Homogeneity of Variance                 |
#|                                                                                          |
#|    If the Levene's Test for Equality of Variances is statistically significant, and      |
#|  therefore, indicates unequal variances, we can correct for this violation by NOT using  |
#|  the pooled estimate for the error term for the t-statistic and also making adjustments  |
#|  to  the degrees of freedom using the Welch-Satterthwaite method.                        |
#|                                                                                          |
#|  (f) Method                                                                              |
#|                                                                                          |
#|    For the THREE (3) dependent variables Area, Price and Psf, the results of Shapiro     |
#|  tests indicates that normality of Psf > Area > Price, therefore Psf should be the       |
#|  dependent variable for the independent t-test. As the Levene's Test for Equality of     |
#|  Variances is statistically significant, and therefore indicates unequal variance, we    |
#|  performed the Welch independent t-test.                                                 |
#|                                                                                          |
#|  (g) Result                                                                              |
#|                                                                                          |
#|    The result of the t-test is insignificant (p=0.6923>0.05), and therefore indicates    |
#|  that the population means are equal.                                                    |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Realis Part 04                                                                  |
#|            Input:    TWO (2) data files (.csv), which may be separated into parts.       |
#|            Output:   NHST of population means that are EQUAL for TWO (2) groups.         |
#|------------------------------------------------------------------------------------------|
library(psych)
library(car)
library(ltm)
library(gclus)
library(RColorBrewer)
library(wordcloud)

#|------------------------------------------------------------------------------------------|
#|                                I N I T I A L I Z A T I O N                               |
#|------------------------------------------------------------------------------------------|
RealisReadDfr <- function(fileStr, partNum=1, 
                          workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert THREE (3) arguments:                                                   
  #       fileStr:      name of the file (without the suffix "_part_xx" and extension ".csv"
  #       partNum:      number of parts                                               
  #       workDirStr:   working directory                                             
  
  #---  Check that partNum is valid (between 1 to 99)                                 
  if( as.numeric(partNum) < 1 || as.numeric(partNum) > 99 ) 
    stop("partNum MUST be between 1 AND 99")
  #---  Set working directory                                                         
  setwd(workDirStr)
  #---  Read data from split parts
  #       Append suffix to the fileStr
  #       Read each part and merge them together
  
  if( as.numeric(partNum) > 1 )
  {
    retDfr <- read.csv( paste( fileStr, "_part01.csv", sep="" ), colClasses = "character" )
    
    for( id in 2:partNum )
    {
      #---  rbind() function will bind two data frames with the same header together
      partStr <- paste( fileStr, "_part", sprintf("%02d", as.numeric(id)), ".csv", sep="" )
      tmpDfr <- read.csv( partStr, colClasses = "character")
      retDfr <- rbind( retDfr, tmpDfr )
    }
  }
  else
    retDfr <- read.csv( paste( fileStr, ".csv", sep="" ), colClasses = "character" )
  
  #---  Return a data frame
  return(retDfr)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
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
#|                                M A I N   P R O C E D U R E                               |
#|------------------------------------------------------------------------------------------|
#---  Init loading data
rawDfr <- RealisReadDfr("realis_ten_projects_treasure_newsub_2000_jan_2012_oct_18")
postDfr <- RealisReadDfr("realis_ten_projects_treasure_resale_2000_jan_2012_oct_18")
#---  Count of rows of data
nrow(rawDfr)
#---  Count of rows of data
nrow(postDfr)

#--- Coerce character into numeric or date
rawDfr[, 4] <- suppressWarnings( as.numeric( rawDfr[, 4] ) )    # Area sqm
rawDfr[, 6] <- suppressWarnings( as.numeric( rawDfr[, 6] ) )    # Transacted Price
rawDfr[, 7] <- suppressWarnings( as.numeric( rawDfr[, 7] ) )    # Unit Price psm
rawDfr[, 8] <- suppressWarnings( as.numeric( rawDfr[, 8] ) )    # Unit Price psf
rawDfr[, 9] <- as.Date(rawDfr[, 9], "%d-%b-%Y")
#--- Coerce character into numeric or date
postDfr[, 4] <- suppressWarnings( as.numeric( postDfr[, 4] ) )    # Area sqm
postDfr[, 6] <- suppressWarnings( as.numeric( postDfr[, 6] ) )    # Transacted Price
postDfr[, 7] <- suppressWarnings( as.numeric( postDfr[, 7] ) )    # Unit Price psm
postDfr[, 8] <- suppressWarnings( as.numeric( postDfr[, 8] ) )    # Unit Price psf
postDfr[, 9] <- as.Date(postDfr[, 9], "%d-%b-%Y")

#--- Split address into parts and merge new columns
rawDfr <- cbind( rawDfr, RealisAddressSplitDfr(rawDfr[, 2]) )
postDfr <- cbind( postDfr, RealisAddressSplitDfr(postDfr[, 2]) )

## Part ONE (1)A: What is the median value of New and Resale properties?

### This part answers a really simple question: What is the median price, area and psf for New and Resale properties?

#### For new sales, there were TWO HUNDRED AND NINETY THREE (293) units sold with a median price of $848,000 and an area 
#### of ONE HUNDRED AND NINE (109) sqm, at a median psf of EIGHT HUNDRED AND FIFTEEN $815.

#### For resales, there were NINETY EIGHT (98) old units sold with a median price of $884,000 and an area 
#### of ONE HUNDRED AND FOUR (104) sqm, at a median psf of EIGHT HUNDRED AND TWO $802.

#|------------------------------------------------------------------------------------------|
#|                            P A R T   O N E   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#---  Count of rows of data
nrow(rawDfr)
describe(rawDfr[, 4])
describe(rawDfr[, 6])
describe(rawDfr[, 8])
nrow(postDfr)
describe(postDfr[, 4])
describe(postDfr[, 6])
describe(postDfr[, 8])
#--- Plot a simple histogram 
par( mfcol = c(3,2), las=2, mar=c(5.1,5.1,4.1,2.1) )
#hist( rawDfr[, 4], xlab="Area Sqm", main="Distribution of Floor Area" )
boxplot( rawDfr[, 4], outchar = T, ylim=c(30, 300), main = "Boxplot of Floor Area", col = "slateblue1")
#hist( rawDfr[, 6], xlab="", main="Distribution of Purchase Price" )
boxplot( rawDfr[, 6], outchar = T, ylim=c(300000, 3000000), main = "Boxplot of Purchase Price", col = "slateblue1")
#hist( rawDfr[, 8], xlab="Unit Price Psf", main="Distribution of Unit Price Psf" )
boxplot( rawDfr[, 8], outchar = T, ylim=c(300, 1500), main = "Boxplot of Unit Price Psf", col = "slateblue1")
#hist( rawDfr[, 4], xlab="Area Sqm", main="Distribution of Floor Area" )
boxplot( postDfr[, 4], outchar = T, ylim=c(30, 300), main = "Boxplot of Floor Area (Resale)", col = "orangered1")
#hist( rawDfr[, 6], xlab="", main="Distribution of Purchase Price" )
boxplot( postDfr[, 6], outchar = T, ylim=c(300000, 3000000), main = "Boxplot of Purchase Price (Resale)", col = "orangered1")
#hist( rawDfr[, 8], xlab="Unit Price Psf", main="Distribution of Unit Price Psf" )
boxplot( postDfr[, 8], outchar = T, ylim=c(300, 1500), main = "Boxplot of Unit Price Psf (Resale)", col = "orangered1")

#--- Make a bubble plot
par( mfrow = c(1,2), las=2, mar=c(5.1,5.1,4.1,2.1) )
#--- Size the circles
radius <- (rawDfr[, 4]/ pi)
pal <- colorRampPalette(brewer.pal(3, "Blues"))
symbols( rawDfr[, 8], rawDfr[, 6], circles=radius, inches=0.3, fg="white", bg=pal(10), 
         xlim=c(300, 1500), ylim=c(300000, 3000000),
         ylab="", xlab="Unit Price Psf", main="Purchase Price vs Unit Price Psf")
text( rawDfr[, 8], rawDfr[, 6], rawDfr[, 4], cex=0.6, col="slateblue1" )
text( 815, 848000, "MEDIAN", cex=1.2, col="blue" )
#--- Make a bubble plot
radius <- (postDfr[, 4]/ pi)
palr <- colorRampPalette(brewer.pal(3, "Reds"))
symbols( postDfr[, 8], postDfr[, 6], circles=radius, inches=0.3, fg="white", bg=palr(10),
         xlim=c(300, 1500), ylim=c(300000, 3000000),
         ylab="", xlab="Unit Price Psf", main="Purchase Price vs Unit Price Psf (Resale)")
text( postDfr[, 8], postDfr[, 6], postDfr[, 4], cex=0.6, col="white" )
text( 802, 884000, "MEDIAN", cex=1.2, col="red" )

### This part answers a really simple question: Which period had the most transactions since launch?

#--- Plot a timeline
par( mfrow = c(1,1), las=2, mar=c(5.1,5.1,4.1,2.1) )
tempDfr <- rawDfr
tempDfr <- tempDfr[complete.cases(tempDfr[, 8]), ]
tempDfr <- tempDfr[complete.cases(tempDfr[, 9]), ]
plot( tempDfr[, 8] ~ tempDfr[, 9], col=rgb(red=0, green=0, blue=1, alpha=0.21),
      ylim=c(300, 1500), xlim=c(as.Date("01-01-02", "%d-%m-%y"), as.Date("30-09-12", "%d-%m-%y")), 
      xlab="Date", ylab="", main="Timeline of Unit Price Psf (Red: Resale)")
temprDfr <- postDfr
temprDfr <- temprDfr[complete.cases(temprDfr[, 8]), ]
temprDfr <- temprDfr[complete.cases(temprDfr[, 9]), ]
points( temprDfr[, 8] ~ temprDfr[, 9], pch=21, col=rgb(red=1, green=0, blue=0, alpha=0.51), 
        ylim=c(300, 1500), xlim=c(as.Date("01-01-02", "%d-%m-%y"), as.Date("30-09-12", "%d-%m-%y")))

## Part ONE (1)B: Which is the most popular project in Singapore?

### This part answers a really simple question: Which project has sold the MOST units in Singapore?

#### The project that sold the MOST units in Singapore is Parc Centros with THREE HUNDRED AND EIGHTY NINE (389) sales.

#|------------------------------------------------------------------------------------------|
#|                          P A R T   C O U N T   P R O C E D U R E                         |
#|------------------------------------------------------------------------------------------|
#--- Plot a wordcloud
if( length(unique(rawDfr$Project.Name)) > 1 )
{
  par( mfrow = c(1,2), mar=c(2.1,2.1,2.1,2.1) )
  
  nameDfr <- rawDfr$Project.Name
  wordcloud(gsub(" ", ".", rawDfr$Project.Name), scale=c(4,.5), colors=brewer.pal(6,"Set2"), random.order=FALSE)
  namerDfr <- postDfr$Project.Name
  wordcloud(gsub(" ", ".", postDfr$Project.Name), scale=c(4,.5), colors=brewer.pal(6,"Dark2"), random.order=FALSE)
}

## Part ONE (1)C: Which project is the MOST expensive for New and Resale?

### This part answers a really simple question: Which project has the highest MEDIAN psf for New and Resale?

#### The MOST expensive project in Singapore is 1919, with a median psf of about TWO THOUSAND $2,000.

if( length(unique(rawDfr$Project.Name)) > 1 )
{
  par(mfrow = c(1, 2), las=2, mar=c(15.1,5.1,4.1,2.1))
  #--- Create a boxplot with given arguments
  nameDfr <- rawDfr
  aColNum <- 1
  bColNum <- 8
  thresholdNum <- 0
  nameFun <- median
  mainStr <- "Unit Price Psf by Project (New)"
  ylabStr <- "Unit Price Psf"
  #--- Start
  tableDfr <- freqDfr(nameDfr[, aColNum])
  outcomeDfr <- nameDfr[nameDfr[, aColNum] %in% subset(tableDfr$name, tableDfr$freq>=thresholdNum), ]
  outDfr <- data.frame(name=outcomeDfr[, aColNum], value=outcomeDfr[, bColNum])
  nameFtr <- RealisBoxplotFtr(data.frame(name=outDfr$name, value=outDfr$value), nameFun,
                              ylab=ylabStr, main=mainStr, col="slateblue1", ylim=c(300,1500))
  #--- Create a boxplot with given arguments
  nameDfr <- postDfr
  aColNum <- 1
  bColNum <- 8
  thresholdNum <- 0
  nameFun <- median
  mainStr <- "Unit Price Psf by Project (Resale)"
  ylabStr <- "Unit Price Psf"
  #--- Start
  tableDfr <- freqDfr(nameDfr[, aColNum])
  outcomeDfr <- nameDfr[nameDfr[, aColNum] %in% subset(tableDfr$name, tableDfr$freq>=thresholdNum), ]
  outDfr <- data.frame(name=outcomeDfr[, aColNum], value=outcomeDfr[, bColNum])
  nameFtr <- RealisBoxplotFtr(data.frame(name=outDfr$name, value=outDfr$value), nameFun,
                              ylab=ylabStr, main=mainStr, col="orangered1", ylim=c(300,1500))
  
  par(mfrow = c(1, 2), las=2, mar=c(15.1,5.1,4.1,2.1))
  #--- Create a boxplot with given arguments
  nameDfr <- rawDfr
  aColNum <- 1
  bColNum <- 4
  thresholdNum <- 0
  nameFun <- median
  mainStr <- "Floor Area by Project (New)"
  ylabStr <- "Area Sqm"
  #--- Start
  tableDfr <- freqDfr(nameDfr[, aColNum])
  outcomeDfr <- nameDfr[nameDfr[, aColNum] %in% subset(tableDfr$name, tableDfr$freq>=thresholdNum), ]
  outDfr <- data.frame(name=outcomeDfr[, aColNum], value=outcomeDfr[, bColNum])
  nameFtr <- RealisBoxplotFtr(data.frame(name=outDfr$name, value=outDfr$value), nameFun,
                              ylab=ylabStr, main=mainStr, col="slateblue4", ylim=c(30,300))
  #--- Create a boxplot with given arguments
  nameDfr <- postDfr
  aColNum <- 1
  bColNum <- 4
  thresholdNum <- 0
  nameFun <- median
  mainStr <- "Floor Area by Project (Resale)"
  ylabStr <- "Area Sqm"
  #--- Start
  tableDfr <- freqDfr(nameDfr[, aColNum])
  outcomeDfr <- nameDfr[nameDfr[, aColNum] %in% subset(tableDfr$name, tableDfr$freq>=thresholdNum), ]
  outDfr <- data.frame(name=outcomeDfr[, aColNum], value=outcomeDfr[, bColNum])
  nameFtr <- RealisBoxplotFtr(data.frame(name=outDfr$name, value=outDfr$value), nameFun,
                              ylab=ylabStr, main=mainStr, col="orangered4", ylim=c(30,300))
}

postDfr[postDfr$Project.Name=="TREASURE MANSIONS", c(4,6,8,9,20,21)]

## Part TWO (2): Are the population means for New and Resale different?

### This part answers a complex question: Are the population means of Unit Price Psf statistically different?

#### We conclude that mean Unit Price psf of New (mean: 803.8) and Resale (mean: 815.0) are statistically the SAME.
#|------------------------------------------------------------------------------------------|
#|                            P A R T   T W O   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|

#--- Create subsets of TWO (2) groups
#       Replace sub with new
bothDfr <- rbind(rawDfr, postDfr)
nrow(bothDfr)
bothDfr[, 13] <- gsub("Sub Sale", "New Sale", bothDfr[, 13])
nsDfr <- subset(bothDfr, bothDfr[, 13] == "New Sale")
rsDfr <- subset(bothDfr, bothDfr[, 13] == "Resale")
nrow(nsDfr)
nrow(rsDfr)

#--- Check for normality p>0.05 is normal
#       Layout
layout(matrix(1:6, 3, 2, byrow = TRUE))
for (cNum in c(4,6,8)) {
  cNum <- as.numeric(cNum)
  #--- Check for normality p>0.05 is normal
  p <- shapiro.test(nsDfr[, cNum])$p.value
  hist(nsDfr[, cNum], prob = T, 
       main = c(paste("New Sale ", names(nsDfr)[cNum]), 
                paste("Shapiro p=", prettyNum(p, digits = 2), " (if p>0.05 then normal)")), 
       xlab = names(nsDfr)[cNum])
  lines(density(nsDfr[, cNum]))
  #--- Check for normality
  qqnorm(nsDfr[, cNum])
}

#--- Check for normality p>0.05 is normal
#       Layout
layout(matrix(1:6, 3, 2, byrow = TRUE))
for (cNum in c(4,6,8)) {
  cNum <- as.numeric(cNum)
  #--- Check for normality p>0.05 is normal
  p <- shapiro.test(rsDfr[, cNum])$p.value
  hist(rsDfr[, cNum], prob = T, 
       main = c(paste("Resale Sale ", names(rsDfr)[cNum]), 
                paste("Shapiro p=", prettyNum(p, digits = 2), " (if p>0.05 then normal)")), 
       xlab = names(nsDfr)[cNum])
  lines(density(rsDfr[, cNum]))
  #--- Check for normality
  qqnorm(rsDfr[, cNum])
}

#--- Independent t-test
t.test(bothDfr[, 8] ~ bothDfr[, 13], var.equal = T)

#--- Levene's test for homogeneity of variance A large F-value means
#       significant, therefore violate homogeneity of variance
leveneTest(bothDfr[, 8], bothDfr[, 13], center = "mean")

#--- Independent t-test
t.test(bothDfr[, 8] ~ bothDfr[, 13], var.equal = F)

#--- Calculate effect size for independent t-test 
#       SD_Pooled ^ 2 = (DF_1/DF_Total) * SD_1 ^ 2 + (DF_2/DF_Total) * SD_2 ^ 2 d 
#       Effect size   = (Mean(X_1) - Mean(X_2)) / SD_Pooled
nsDescDfr <- describe(nsDfr[, 8])
rsDescDfr <- describe(rsDfr[, 8])
nsDfNum <- nrow(nsDfr) - 1
rsDfNum <- nrow(rsDfr) - 1
totDfNum <- nsDfNum + rsDfNum
sdPooledNum <- sqrt(nsDfNum/totDfNum * nsDescDfr[1, 4]^2 + rsDfNum/totDfNum * rsDescDfr[1, 4]^2)
(rsDescDfr[1, 3] - nsDescDfr[1, 3])/sdPooledNum

## Part THREE (3): Which resale property can we buy for an area of similar size?

### This part answers a really simple question: Which property can we buy for an area of size between 90 sqm and 100 sqm?

#### There were FIFTEEN (15) units sold with a median price of $740,000 at a median psf of $702.

#|------------------------------------------------------------------------------------------|
#|                          P A R T   T H R E E   P R O C E D U R E                         |
#|------------------------------------------------------------------------------------------|
subDfr <- postDfr[postDfr[, 4]>90, ]
subDfr <- subDfr[subDfr[, 4]<100, ]
#---  Count of rows of data
nrow(subDfr)
describe(subDfr[, 4])
describe(subDfr[, 6])
describe(subDfr[, 8])

#--- Make a bubble plot
par( mfrow = c(1,1), las=2, mar=c(5.1,5.1,4.1,2.1) )
#--- Size the circles
radius <- subDfr$level
symbols( subDfr[, 8], subDfr[, 6], circles=radius, inches=0.3, fg="white", bg="lightblue",
         ylab="", xlab="Unit Price Psf", main="Purchase Price vs Unit Price Psf (Resale)")
text( subDfr[, 8], subDfr[, 6], subDfr$level, cex=0.8, col="red" )
text( 702, 740000, "MEDIAN", cex=1.2, col="red" )

## Part FOUR (4): Which resale property can we buy for an amount of money?

### This part answers a really simple question: Which property can we buy for between $0.7m and $0.9m?

#### There were TWENTY ONE (21) units sold with a median area of NINETY EIGHT (98) sqm which were purchased
#### for a median psf of SEVEN HUNDRED AND THIRTY ONE $731.

#|------------------------------------------------------------------------------------------|
#|                          P A R T   F O U R   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
subDfr <- postDfr[postDfr[, 6]>700000, ]
subDfr <- subDfr[subDfr[, 6]<900000, ]
#---  Count of rows of data
nrow(subDfr)
describe(subDfr[, 4])
describe(subDfr[, 6])
describe(subDfr[, 8])


#--- Make a bubble plot
par( mfrow = c(1,1), las=2, mar=c(5.1,5.1,4.1,2.1) )
#--- Size the circles
radius <- (subDfr[, 4]/ pi)
symbols( subDfr[, 8], subDfr[, 6], circles=radius, inches=0.3, fg="white", bg=pal(5),
         ylab="", xlab="Unit Price Psf", main="Purchase Price vs Unit Price Psf (Resale)")
text( subDfr[, 8], subDfr[, 6], subDfr[, 4], cex=0.8, col="red" )
text( 731, 805000, "MEDIAN", cex=1.2, col="red" )
## Part FIVE (5): What is a good predictor of price for the project?

### This part answers a really simple question: Which variable can be used to predict price accurately?

#### The variable 'area' is a BELOW AVERAGE (44.5%) predictor of price for a resale property, but an ABOVE AVERAGE (61.3%) 
#### predictor of price for a new property.

#### Note: the same variable explains 44.3% of price for a property in Singapore (Watertown: 87.3%), with other unknown
#### variables accounting for the rest of price.

#|------------------------------------------------------------------------------------------|
#|                          P A R T   F I V E   P R O C E D U R E                           |
#|------------------------------------------------------------------------------------------|
#--- Scatterplot and Correlation Analysis (library gclus and ltm)
# Scatterplot
subDfr <- data.frame(price=rawDfr[,6], area=rawDfr[,4], psf=rawDfr[,8])
par( mfrow = c(1,1), las=1 )
cpairs(subDfr, gap = 0.5, panel.colors = dmat.color(abs(cor(subDfr))), col=rgb(0,0,0,0.1),
       main = "RAW Variables Ordered and Colored by Correlations (New)")

# --- Correlation matrix
cor(subDfr)

# --- Perform correlation test for matrix (library ltm) Correlation null
# hypothesis is that the correlation is zero (not correlated) If the
# p-value is less than the alpha level, then the null hypothesis is
# rejected Check for correlation p<0.05 is correlated
rcor.test(subDfr)

# --- Simple Regression (unstandardized) Y = price; X = area;
raw1Lm <- lm(subDfr$price ~ subDfr$area)
summary(raw1Lm)

subrDfr <- data.frame(price=postDfr[,6], area=postDfr[,4], psf=postDfr[,8])
# --- Correlation matrix
cor(subrDfr)

# --- Perform correlation test for matrix (library ltm) Correlation null
# hypothesis is that the correlation is zero (not correlated) If the
# p-value is less than the alpha level, then the null hypothesis is
# rejected Check for correlation p<0.05 is correlated
rcor.test(subrDfr)

# --- Simple Regression (unstandardized) Y = price; X = area;
rawr1Lm <- lm(subrDfr$price ~ subrDfr$area)
summary(rawr1Lm)

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|