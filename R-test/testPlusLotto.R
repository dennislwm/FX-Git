#|------------------------------------------------------------------------------------------|
#|                                                                          testPlusLotto.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script tests ONE (1) function lottoUpdateBln() in PlusLotto.R.             |
#|------------------------------------------------------------------------------------------|
library(testthat)
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusLotto.R")

context("PlusLotto checks")

test_that( "lottoUpdateBln",
{
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working directory
  test.wd <- "C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-test"
  setwd(test.wd)
  
  #---  Prepare mock data for multiple testing
  #       (1) today is Mon, and gtimestamp >= 6 hours
  #       (2) today is Mon, and gtimestamp < 6 hours
  #       (3) today is Wed, and gtimestamp >= 30 hours
  #       (4) today is Wed, and gtimestamp < 30 hours
  timeStamp.POSIXct <- as.POSIXct(ISOdatetime(2012,11,06,13,0,0))
  now.POSIXct <- as.POSIXct(ISOdatetime(2012,11,12,13,0,0))
  tim2Stamp.POSIXct <- as.POSIXct(ISOdatetime(2012,11,12,19,0,0))
  no2.POSIXct <- as.POSIXct(ISOdatetime(2012,11,14,13,0,0))
  
  #---  Assert expectations
  expect_that( lottoUpdateBln(timeStamp.POSIXct, now.POSIXct), is_identical_to(TRUE) )
  expect_that( lottoUpdateBln(tim2Stamp.POSIXct, now.POSIXct), is_identical_to(FALSE) )
  expect_that( lottoUpdateBln(timeStamp.POSIXct, no2.POSIXct), is_identical_to(TRUE) )
  expect_that( lottoUpdateBln(tim2Stamp.POSIXct, no2.POSIXct), is_identical_to(FALSE) )
  
  #---  Restore user environment
  setwd(user.wd)
}
)