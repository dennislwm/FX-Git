#|------------------------------------------------------------------------------------------|
#|                                                                          testPlusMonte.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script perform unit tests on functions in PlusMonte.R.                     |
#|          Added test_that() for functions monteShuffleIndexNum() and                      |
#|          monteSimulateReturnsZoo(). TODO: MonteGrowReturns() function.                   |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusMonte.R")

context("PlusMonte checks")

test_that( "monteShuffleIndexNum",
{
  #---  Assert TWO (2) arguments:                                                   
  #       n:        an integer for the length of vector
  #       r:        an integer for the size of block
  #       retNum:   a numeric vector of shuffled index with length n and r blocks
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-05/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) n is NULL
  #       (2) r is NULL
  expect_that( monteShuffleIndexNum(NULL, 1), throws_error() )
  expect_that( monteShuffleIndexNum(2, NULL), throws_error() )
  
  #---  Test with incorrect uni data
  #       (3) n is a character
  #       (4) r is a character
  #       (5) n < 2
  #       (6) r < 1
  #       (7) r > n
  expect_that( suppressWarnings(monteShuffleIndexNum("a", 1)), throws_error() )
  expect_that( suppressWarnings(monteShuffleIndexNum(2, "b")), throws_error() )
  expect_that( monteShuffleIndexNum(1, 1), throws_error() )
  expect_that( monteShuffleIndexNum(2, 0), throws_error() )
  expect_that( monteShuffleIndexNum(5, 6), throws_error() )
  
  #---  Test with correct uni data at limits
  #       (8) n = 2, r = 1
  #       (9) n >> r
  #       (10) n >> 0, r==n
  expect_that( length(monteShuffleIndexNum(2, 1)), is_equivalent_to(2) )
  expect_that( length(monteShuffleIndexNum(100, 3)), is_equivalent_to(100) )
  expect_that( length(monteShuffleIndexNum(100, 100)), is_equivalent_to(100) )
    
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)

test_that( "monteSimulateReturnsZoo",
{
  #---  Assert FIVE (5) arguments:                                                   
  #       tradesNum is an integer for number of trades
  #       pAvgNum is a double for average profit in dollars
  #       lAvgNum is a double for average loss in dollars
  #       wPctNum is a double for the winning percentage
  #       initNum is a double for initial starting capital in dollars (default: 10000)
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-05/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) tradesNum is NULL
  #       (2) pAvgNum is NULL
  #       (3) lAvgNum is NULL
  #       (4) wPctNum is NULL
  #       (5) initNum is NULL
  expect_that( monteSimulateReturnsZoo(NULL, 4, -8, 0.5), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, NULL, -8, 0.5), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, 4, NULL, 0.5), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, 4, -8, NULL), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, 4, -8, 0.5, initNum=NULL), throws_error() )
  
  #---  Test with incorrect uni data
  #       (7) tradesNum is a character
  #       (8) pAvgNum is a character
  #       (9) lAvgNum is a character
  #       (10) wPctNum is a character
  #       (11) initNum is a character
  expect_that( suppressWarnings(monteSimulateReturnsZoo("a", 4, -8, 0.5)), throws_error() )
  expect_that( suppressWarnings(monteSimulateReturnsZoo(5, "b", -8, 0.5)), throws_error() )
  expect_that( suppressWarnings(monteSimulateReturnsZoo(5, 4, "c", 0.5)), throws_error() )
  expect_that( suppressWarnings(monteSimulateReturnsZoo(5, 4, -8, "d")), throws_error() )
  expect_that( suppressWarnings(monteSimulateReturnsZoo(5, 4, -8, 0.5, initNum="e")),
               throws_error() )
  
  #       (12) tradesNum < 3
  #       (13) pAvgNum <= 0
  #       (14) lAvgNum >= 0
  #       (15) wPctNum <= 0 | wPctNum >= 1
  #       (16) initNum <= 0 | 
  #       (17) initNum << Abs( lAvg * tradesNum * (1 - wPct) )
  expect_that( monteSimulateReturnsZoo(2, 4, -8, 0.5), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, 0, -8, 0.5), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, 4, 0, 0.5), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, 4, -8, 1), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, 4, -8, 0.5, initNum=0), throws_error() )
  expect_that( monteSimulateReturnsZoo(5, 4, -8, 0.5, 
                                       initNum=abs(-8*(5-1)*0.5)), throws_error() )
  
  #---  Test with correct uni data at limits
  #       (17) tradesNum = 3
  #       (18) pAvgNum = 1
  #       (19) lAvgNum = -1
  #       (20) wPctNum = 0.01
  #       (21) initNum = 1+2*Abs( lAvg * (tradesNum * (1 - wPct) * 100%) )
  expect_that( NROW(monteSimulateReturnsZoo(3, 4, -8, 0.5)), 
               is_equivalent_to(3) ) 
  expect_that( NROW(monteSimulateReturnsZoo(5, 1, -8, 0.5)), 
               is_equivalent_to(5) )
  expect_that( NROW(monteSimulateReturnsZoo(5, 4, -1, 0.5)), 
               is_equivalent_to(5) )
  expect_that( NROW(monteSimulateReturnsZoo(5, 4, -8, 0.01)), 
               is_equivalent_to(5) )
  expect_that( NROW(monteSimulateReturnsZoo(5, 4, -8, 0.5, 
                                       initNum=1+2*abs(-8*5*0.5))), 
               is_equivalent_to(5) )
  
  #       (22) tradesNum >> 3
  #       (23) pAvgNum >> 0
  #       (24) lAvgNum << 0
  #       (25) wPctNum >> 0.01 | wPctNum << 0.99
  #       (26) initNum >> Abs( lAvg * (tradesNum * (1 - wPct) * 100%) )
  
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)


test_that( "MonteGrowReturns",
{
  #---  Assert FIVE (5) arguments:                                                   
  #       rawZoo is a zoo object of returns
  #       setNum is an integer of number of sets to grow
  #       sizeNum is an integer of block size, where blocks of returns are kept together (default: 1)
  #       initNum is a double for initial starting capital in dollars (default: 10000)
  #       replaceBln is a boolean for sampling replacement (default: TRUE)
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-05/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) rawZoo is NULL
  #       (2) setNum is NULL
  #       (3) sizeNum is NULL
  #       (4) initNum is NULL
  expect_that( MonteGrowReturns(NULL, 30, 1), throws_error() )
  
  #---  Test with incorrect uni data
  
  #---  Test with correct uni data at limits
  
  #---  Test with correct multi data at limits
  
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)
