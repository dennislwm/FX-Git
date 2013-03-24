#|------------------------------------------------------------------------------------------|
#|                                                                            testPlusJob.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script perform unit tests on functions in PlusJob.R 1.0.2+.                |
#|------------------------------------------------------------------------------------------|
library(R.utils)
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusJob.R")

context("PlusJob jobEfcUpdateJobDfr() checks")

test_that( "jobEfcUpdateJobDfr",
  {
    #---  Assert TWO (2) arguments:                                                   
    #       retDfr:       a data frame
    #       waitNum:      integer value for seconds to wait between EACH query (default: 1) 
    
    #---  Backup user environment for restore
    user.wd <- getwd()
    
    #---  Set working environment
    test.wd <- "C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-test"
    setwd(test.wd)
    
    #---  Write multiple CSV files for testing (Note: it is trivial to test for WaitNum)
    #       (1) Empty data frame
    #       (2) Data frame with incorrect headers
    #       (3) Data frame with too many columns
    #       (4) Data frame with correct headers but no rows
    #       (5) Todo: Data frame has an element containing commas
    #       (6) Todo: Data frame contains values in columns 3..9
    datDfr <- data.frame(NULL)
    da2Dfr <- data.frame(a=c("a"), b=c("b"), stringsAsFactors=FALSE)
    da3Dfr <- dataFrame( colClasses=c( hjob="character", date="character",
                                       company="character", location="character",
                                       remuneration="character", postype="character",
                                       employtype="character", ref="character",
                                       content="character", dummy="character" ), 
                         nrow=0 ) 
    da4Dfr <- dataFrame( colClasses=c( hjob="character", date="character",
                                       company="character", location="character",
                                       remuneration="character", postype="character",
                                       employtype="character", ref="character",
                                       content="character" ), 
                         nrow=0 ) 
    
    expect_that( jobEfcUpdateJobDfr( datDfr ), is_identical_to( NULL ) )
    expect_that( jobEfcUpdateJobDfr( da2Dfr ), is_identical_to( NULL ) )
    expect_that( jobEfcUpdateJobDfr( da3Dfr ), is_identical_to( NULL ) )
    expect_that( jobEfcUpdateJobDfr( da4Dfr ), is_identical_to( NULL ) )
    
    #---  Restore user environment
    setwd(user.wd)
  }
)

context("PlusJob jobEfcUpdateNum() checks")

test_that( "jobEfcUpdateNum",
{
  #---  Assert TWO (2) arguments:                                                   
  #       sectorStr:    MUST specify EITHER "Accounting_Finance", "Asset_Management", 
  #                     "Capital_Markets", "Commodities", "Equities", "FX_Money_Markets",
  #                     "Hedge_Funds", "Quantitative_Analytics", "Research", OR "Trading"
  #       waitNum:      integer value for seconds to wait between EACH query (default: 1) 
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- "C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-test"
  setwd(test.wd)
  typeStr <- c("Accounting_Finance", "Asset_Management", 
               "Capital_Markets",    "Commodities", 
               "Equities",           "FX_Money_Markets",
               "Hedge_Funds",        "Quantitative_Analytics", 
               "Research",           "Trading")
  
  #---  Write multiple CSV files for testing (Note: it is trivial to test for WaitNum)
  #       (1) sectorStr is not a valid string
  #       (2) sectorStr is a vector
  expect_that( jobEfcUpdateNum( "Accounting" ), throws_error() )
  expect_that( jobEfcUpdateNum( c("Research","Trading") ), throws_error() )

  #---  For EACH sector do this once
  #       (3) Return value is a numeric
  #       (4) File CSV is written successfully
  for( sectorStr in typeStr )
  {
    expect_that( is.numeric(jobEfcUpdateNum( sectorStr )), is_true() )
    expect_that( file.exists(paste0("../R-nonsource/jobEfc_", sectorStr, ".csv")), is_true() )
  }
  
  #---  Restore user environment
  setwd(user.wd)
}
)

context("PlusJob data integrity checks")

test_that( "data",
{
  #---  Assert TWO (2) arguments:                                                   
  #       sectorStr:    MUST specify EITHER "Accounting_Finance", "Asset_Management", 
  #                     "Capital_Markets", "Commodities", "Equities", "FX_Money_Markets",
  #                     "Hedge_Funds", "Quantitative_Analytics", "Research", OR "Trading"
  #       waitNum:      integer value for seconds to wait between EACH query (default: 1) 
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- "C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-test"
  setwd(test.wd)
  typeStr <- c("Accounting_Finance", "Asset_Management", 
               "Capital_Markets",    "Commodities", 
               "Equities",           "FX_Money_Markets",
               "Hedge_Funds",        "Quantitative_Analytics", 
               "Research",           "Trading")
  
  #---  For EACH sector do this once
  #       (1) No duplicate rows in CSV file
  #       (2) No comma (,) in content
  #       (3) No NA in hjob AND content
  for( sectorStr in typeStr )
  {
    da5Dfr <- fileReadDfr(paste0("jobEfc_", sectorStr))
    expect_that( length(which(duplicated(da5Dfr$hjob)))==0, is_true() )
    expect_that( length(grep(",",da5Dfr$content))==0, is_true() )
    expect_that( sum(is.na(da5Dfr$hjob))==0, is_true() )
    expect_that( sum(is.na(da5Dfr$content))==0, is_true() )
  }
  
  #---  Restore user environment
  setwd(user.wd)
}
)