#|------------------------------------------------------------------------------------------|
#|                                                                            testPlusRtt.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script performs unit tests on functions in library "PlusRtt" 1.0.1, and    |
#|          ANY assertions would be included OR errors fixed by the next version of the     |
#|          library, i.e. "PlusRtt" 1.0.2.                                                  |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusReg.R")
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusRtt.R")
library(testthat)
library(R.utils)

context("PlusRtt RttTrainDoDfr() checks")

test_that( "RttTrainDoDfr",
{
  #---  Assert SIX (6) arguments:                                                   
  #       data:     a data frame of at LEAST TWO (2) columns and (minSize + 1) rows
  #       trainNum: an integer for the number of rows used for training
  #       testNum:  an integer for the number of rows used for testing (default: NULL)
  #       seedNum:  an integer for the random seed (default: 1234)
  #       minSize:  an integer for the minimum number of rows used for training (default: 10)
  #       replace:  a boolean for sampling with OR without replacement (default: FALSE)
  #       retDfr:   a data frame of shuffled data consisting of train set followed by 
  #                 test set
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-06-Rtt/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) data is NULL
  #       (2) trainNum is NULL
  expect_that( RttTrainDoDfr(NULL, 10), throws_error() )
  expect_that( RttTrainDoDfr(dataFrame( colClasses=c(t="character"), nrow=0), NULL), throws_error() )
  
  #---  Test with incorrect uni data
  #       (3) data is a data frame with NO data
  expect_that( RttTrainDoDfr(dataFrame( colClasses=c(t="character"), nrow=0), 10), throws_error() )

  #       (4) data is a data frame with ONE (1) row and ONE (1) column
  data <- data.frame(col="text")
  expect_that( RttTrainDoDfr(data, 1, minSize=1), throws_error() )

  #       (5) nrow(data) < trainNum
  #       (6) nrow(data) < minSize
  data <- data.frame(text="text", outcome=2)
  expect_that( RttTrainDoDfr(data, 2, minSize=1), throws_error() )
  expect_that( RttTrainDoDfr(data, 1, minSize=2), throws_error() )

  #       (7) data has ONE (1) row, trainNum=1, minSize=1
  data <- data.frame(text="text", outcome=2)
  expect_that( RttTrainDoDfr(data, 1, minSize=1), throws_error() )

  #       (8) data has TWO (1) rows, trainNum=1, minSize=1, testNum=2
  data <- data.frame(text=c("text", "text2"), out=c(2,4))
  expect_that( RttTrainDoDfr(data, 1, minSize=1, testNum=2), throws_error() )
  
  #---  Test with correct uni data at limits
  #       (9) data has TWO (2) rows, trainNum=1, minSize=1
  data <- data.frame(text=c("text", "text2"), out=c(2,4))
  expect_that( nrow(RttTrainDoDfr(data, 1, minSize=1)), is_equivalent_to(2) )
    
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)

context("PlusRtt RttTrainCheckDfr() checks")

test_that( "RttTrainCheckDfr",
{
  #---  Assert FIVE (5) arguments:                                                   
  #       data:     a data frame of at LEAST TWO (2) columns and (minSize + 1) rows
  #       trainNum: an integer for the number of rows used for training
  #       testRng:  an integer for the number of rows used for testing (default: NULL)
  #       seedNum:  an integer for the random seed (default: 1234)
  #       minSize:  an integer for the minimum number of rows used for training (default: 10)
  #       retDfr:   a data frame of shuffled data consisting of train set followed by 
  #                 test set
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-06-Rtt/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) data is NULL
  #       (2) trainNum is NULL
  expect_that( RttTrainCheckDfr(NULL, 10), throws_error() )
  expect_that( RttTrainCheckDfr(dataFrame( colClasses=c(t="character"), nrow=0), NULL), throws_error() )
  
  #---  Test with incorrect uni data
  #       (3) data is a data frame with NO data
  expect_that( RttTrainCheckDfr(dataFrame( colClasses=c(t="character"), nrow=0), 10), throws_error() )
  
  #       (4) data is a data frame with ONE (1) row and ONE (1) column
  data <- data.frame(col="text")
  expect_that( RttTrainCheckDfr(data, 1, minSize=1), throws_error() )
  
  #       (5) nrow(data) < trainNum
  #       (6) nrow(data) < minSize
  data <- data.frame(text="text", outcome=2)
  expect_that( RttTrainCheckDfr(data, 2, minSize=1), throws_error() )
  expect_that( RttTrainCheckDfr(data, 1, minSize=2), throws_error() )
  
  #       (7) data has ONE (1) complete row, trainNum=1, minSize=1
  data <- data.frame(text="text", outcome=2)
  expect_that( RttTrainCheckDfr(data, 1, minSize=1), throws_error() )
  
  #       (8) data has ONE (1) incomplete row, trainNum=1, minSize=1
  data <- data.frame(text="text", outcome=NA)
  expect_that( RttTrainCheckDfr(data, 1, minSize=1), throws_error() )
  
  #       (9) testRng is incorrect
  #       (10) testRng is negative
  #       (11) testRng is out of bounds
  data <- data.frame(text=c("text", "text2"), outcome=c(2,NA))
  expect_that( RttTrainCheckDfr(data, 1, minSize=1, testRng=1), throws_error() )
  expect_that( RttTrainCheckDfr(data, 1, minSize=1, testRng=-1:0), throws_error() )
  expect_that( RttTrainCheckDfr(data, 1, minSize=1, testRng=2:3), throws_error() )
  
  #---  Test with correct uni data at limits
  #       (12) data has TWO (2) rows, trainNum=1, minSize=1, testRng=2:2
  data <- data.frame(text=c("text", "text2"), outcome=c(2,NA))
  expect_that( nrow(RttTrainCheckDfr(data, 1, minSize=1, testRng=2:2)), is_equivalent_to(2) )
  
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)

context("PlusRtt RttTrainPlan.ctn() checks")

test_that( "RttTrainPlan.ctn",
{
  #---  Although there are SIX (6) arguments, however the arguments have been checked when
  #       calling the internal functions rttTrainDoDfr() and rttTrainCheckDfr().
  #     Assert ONE (1) important argument:
  #       data:     a data frame of at LEAST TWO (2) columns, i.e. "text" AND "outcome"
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-06-Rtt/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) data is NULL
  #       (2) data has ONE (1) column "text"
  #       (3) data has ONE (1) column "outcome"
  expect_that( RttTrainPlan.ctn(NULL, 10), throws_error() )
  expect_that( RttTrainPlan.ctn(dataFrame( colClasses=c(text="character"), nrow=0), 10), throws_error() )
  expect_that( RttTrainPlan.ctn(dataFrame( colClasses=c(outcome="numeric"), nrow=0), 10), throws_error() )
  
  #---  Test with incorrect uni data
  #       (4) data is a data frame with NO data
  data <- dataFrame( colClasses=c(text="character", outcome="numeric"), nrow=0)
  expect_that( RttTrainPlan.ctn(data, 10), throws_error() )
    
  #---  Test with correct uni data at limits
  #       (5) data has TWO (2) complete cases with TOO FEW text
  text1 <- "Market TalkPetroleum distribution: AKR Corporindo (AKRA.IJ) announces that it will issue Rp1.5t bond. The bond issuance is divided by two series. A series has 5year term maturity, and B series is maturing in 7 years. Pg. 2 Oil & gas: Medco Energi International (MEDC.IJ) will issue IDR4.5t bond over the next two years. The bond issuance is divided in several phases. For the first phase, the company"
  text2 <- "derived from the 56%-owned FNH. Excluding beer, its overall F&B business contributed 32.4% and 13% of group revenue and EBIT respectively in FY9/12. At SGD2.7b, our calculation shows that FNH is worth MYR21.20/share, which translates to 25.5x 2013 PER. Potential counter bid? Should TCC intend to defend its position in FNN, it would have to counter with a higher offer price. As at 8 Nov, TCC owns a 33.6% stake in FNN."
  len <- 10
  data <- data.frame(text=c(substr(text1,1,len), substr(text2,1,len-5)), outcome=c(2,2))
  expect_that( RttTrainPlan.ctn(data, 1, minSize=1), throws_error() )
  
  #       (6) data has TWO (2) complete cases
  data <- data.frame(text=c(text1, text2), outcome=c(2,2))
  expect_that( RttTrainPlan.ctn(data, 1, minSize=1)$container@virgin, is_false() )
  
  #       (7) data has ONE (1) complete case and ONE (1) incomplete case
  data <- data.frame(text=c(text1, text2), outcome=c(2,NA))
  expect_that( RttTrainPlan.ctn(data, 1, minSize=1)$container@virgin, is_true() )
  
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)
