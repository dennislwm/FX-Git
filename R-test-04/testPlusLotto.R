#|------------------------------------------------------------------------------------------|
#|                                                                          testPlusLotto.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.1   Added test_that() for function lottoArimaConfZooDfr().                          |
#|  1.0.0   This script perform unit tests on functions in PlusPdf.R.                       |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusLotto.R")

context("PlusLotto checks")

test_that( "lottoArimaConfZooDfr",
{
  #---  Assert THREE (3) arguments:                                                   
  #       rawZoo:       a zoo object with AT LEAST (3 rows x 1 col) to be forecasted
  #       lNum:         a numeric vector with lower bounds                 
  #       uNum:         a numeric vector with upper bounds (default: NULL)                 
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-04/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) rawZoo is NULL or EMPTY
  testZoo <- zoo(numeric(0))
  expect_that( lottoArimaConfZooDfr(NULL, 0), throws_error() )
  expect_that( lottoArimaConfZooDfr(testZoo, 0), throws_error() )
  
  #       (3) lNum is NULL or EMPTY
  #       (5) uNum is EMPTY
  rDte <- Sys.Date()
  tes2Zoo <- zoo(matrix(c(10,20,5,10,20,5), ncol=2, nrow=3), 
                 c(rDte,rDte+1,rDte+2))
  expect_that( lottoArimaConfZooDfr(tes2Zoo, NULL), throws_error() )
  expect_that( lottoArimaConfZooDfr(tes2Zoo, numeric(0)), throws_error() )
  expect_that( lottoArimaConfZooDfr(tes2Zoo, 1, numeric(0)), throws_error() )
  
  #---  Test with incorrect uni data
  #       (7) rawZoo has TWO (2) columns and THREE (3) rows of NA
  tes3Zoo <- zoo(matrix(c(NA,NA,NA,NA,NA,NA), ncol=2, nrow=3))
  expect_that( lottoArimaConfZooDfr(tes3Zoo, 1), throws_error() )
  
  #       (8) rawZoo has TWO (2) columns and THREE (3) row of characters
  tes4Zoo <- zoo(matrix(c("a","b","c","a","b","c"), ncol=2, nrow=3))
  expect_that( lottoArimaConfZooDfr(tes4Zoo, 1), throws_error() )
  
  #       (9) lNum is negative
  #       (10) lNum is greater than length ONE (1) but not EQUAL to number of columns 
  #            in the matrix
  #       (11) uNum is negative
  #       (12) uNum is less than lNum
  #       (13) uNum is greater than length ONE (1) but not EQUAL to number of columns 
  #            in the matrix
  expect_that( lottoArimaConfZooDfr(tes2Zoo, -1), is_a("data.frame") )
  expect_that( lottoArimaConfZooDfr(tes2Zoo, c(-1,-1)), throws_error() )
  expect_that( nrow(lottoArimaConfZooDfr(tes2Zoo, -1, -1)), is_equivalent_to(3) )
  expect_that( lottoArimaConfZooDfr(tes2Zoo, 1, -40), throws_error() )
  expect_that( lottoArimaConfZooDfr(tes2Zoo, 1, c(-1,-1)), throws_error() )
  
  #---  Test with correct uni data
  #       (14) rawMtx has TWO (2) columns and THREE (3) rows of numeric data
  expect_that( lottoArimaConfZooDfr(tes2Zoo, 1, 36), is_a("data.frame") )
  
  #---  Test with correct multi data
  #       (15) rawMtx has multiple columns and rows of numeric data
  tes5Zoo <- zoo(matrix(c(10,20,5,14,25,34), ncol=2, nrow=3),
                 c(rDte,rDte+1,rDte+2))
  expect_that( nrow(lottoArimaConfZooDfr(tes5Zoo, 0, 36)), is_equivalent_to(3) )
  
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)

test_that( "lottoArimaConfDfr",
{
  #---  Assert THREE (3) arguments:                                                   
  #       rawMtx:       a numeric matrix with at least ONE (1) column to be forecasted
  #       lNum:         a numeric vector with lower bounds                 
  #       uNum:         a numeric vector with upper bounds (default: NULL)                 
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-04/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) rawMtx is NULL or EMPTY
  testMtx <- matrix(numeric(0), ncol=0, nrow=0)
  expect_that( lottoArimaConfDfr(NULL, 0), throws_error() )
  expect_that( lottoArimaConfDfr(testMtx, 0), throws_error() )
  
  #       (3) lNum is NULL or EMPTY
  #       (5) uNum is EMPTY
  tes2Mtx <- matrix(c(10,20,5), ncol=1, nrow=3)
  expect_that( lottoArimaConfDfr(tes2Mtx, NULL), throws_error() )
  expect_that( lottoArimaConfDfr(tes2Mtx, numeric(0)), throws_error() )
  expect_that( lottoArimaConfDfr(tes2Mtx, 1, numeric(0)), throws_error() )
  
  #---  Test with incorrect uni data
  #       (7) rawMtx has ONE (1) column and THREE (3) rows of NA
  tes3Mtx <- matrix(c(NA,NA,NA), ncol=1, nrow=3)
  expect_that( lottoArimaConfDfr(tes3Mtx, 1), throws_error() )
  
  #       (8) rawMtx has ONE (1) column and THREE (3) row of characters
  tes4Mtx <- matrix(c("a","b","c"), ncol=1, nrow=3)
  expect_that( lottoArimaConfDfr(tes4Mtx, 1), throws_error() )
  
  #       (9) lNum is negative
  #       (10) lNum is greater than length ONE (1) but not EQUAL to number of columns 
  #            in the matrix
  #       (11) uNum is negative
  #       (12) uNum is less than lNum
  #       (13) uNum is greater than length ONE (1) but not EQUAL to number of columns 
  #            in the matrix
  expect_that( lottoArimaConfDfr(tes2Mtx, -1), is_a("data.frame") )
  expect_that( lottoArimaConfDfr(tes2Mtx, c(-1,-1)), throws_error() )
  expect_that( nrow(lottoArimaConfDfr(tes2Mtx, -1, -1)), is_equivalent_to(2) )
  expect_that( lottoArimaConfDfr(tes2Mtx, 1, -40), throws_error() )
  expect_that( lottoArimaConfDfr(tes2Mtx, 1, c(-1,-1)), throws_error() )
  
  #---  Test with correct uni data
  #       (14) rawMtx has ONE (1) column and THREE (3) rows of numeric data
  expect_that( lottoArimaConfDfr(tes2Mtx, 1, 36), is_a("data.frame") )
  
  #---  Test with correct multi data
  #       (15) rawMtx has multiple columns and rows of numeric data
  tes5Mtx <- matrix(c(10,20,5,14,25,34), ncol=2, nrow=3)
  expect_that( nrow(lottoArimaConfDfr(tes5Mtx, 0, 36)), is_equivalent_to(3) )
  
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)
