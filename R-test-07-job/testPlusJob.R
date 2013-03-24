#|------------------------------------------------------------------------------------------|
#|                                                                            testPlusJob.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.1   The saved CSV files have been deprecated, and replaced by RDA files. The test   |
#|          functions works with BOTH an RDA file and a CSV file, but a warning is given    |
#|          for the latter. This script performs unit tests on functions in PlusJob.R 1.0.3 |
#|  1.0.0   This script perform unit tests on functions in PlusJob.R 1.0.2+.                |
#|------------------------------------------------------------------------------------------|
library(R.utils)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 FX Git/R-source/PlusReg.R")
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusJob.R")

context("PlusJob JobEfcUpdateJobDfr() checks")

test_that( "JobEfcUpdateJobDfr",
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
  
  expect_that( JobEfcUpdateJobDfr( datDfr ), is_identical_to( NULL ) )
  expect_that( JobEfcUpdateJobDfr( da2Dfr ), is_identical_to( NULL ) )
  expect_that( JobEfcUpdateJobDfr( da3Dfr ), is_identical_to( NULL ) )
  expect_that( JobEfcUpdateJobDfr( da4Dfr ), is_identical_to( NULL ) )
  
  #---  Restore user environment
  setwd(user.wd)
}
)

context("PlusJob JobEfcUpdateNum() checks")

test_that( "JobEfcUpdateNum",
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
  expect_that( JobEfcUpdateNum( "Accounting" ), throws_error() )
  expect_that( JobEfcUpdateNum( c("Research","Trading") ), throws_error() )
  
  #---  For EACH sector do this once
  #       (3) Return value is a numeric
  #       (4) File CSV is written successfully
  for( sectorStr in typeStr )
  {
    expect_that( is.numeric(JobEfcUpdateNum( sectorStr )), is_true() )
  
    fileStr <- paste0(RegGetRNonSourceDir(), "jobEfc_", sectorStr, ".rda")
    deprecatedBln <- !file.exists(fileStr)
    if( !deprecatedBln )
    {
      if( exists("retDfr") ) rm("retDfr")
      load(fileStr)
      if( !exists("retDfr") )
        deprecatedBln <- TRUE
    }
    if( deprecatedBln )
    {
      warning("The CSV file has been deprecated. Call the function JobEfcCreateRdaNum() to create an RDA file.")
      expect_that( file.exists(paste0("../R-nonsource/jobEfc_", sectorStr, ".csv")), is_true() )
    }
    else
    {
      expect_that( file.exists(fileStr), is_true() )
    }
    
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
    fileStr <- paste0(RegGetRNonSourceDir(), "jobEfc_", sectorStr, ".rda")
    deprecatedBln <- !file.exists(fileStr)
    if( !deprecatedBln )
    {
      if( exists("retDfr") ) rm("retDfr")
      load(fileStr)
      if( !exists("retDfr") )
        deprecatedBln <- TRUE
    }
    if( deprecatedBln )
    {
      warning("The CSV file has been deprecated. Call the function JobEfcCreateRdaNum() to create an RDA file.")
      da5Dfr <- fileReadDfr(paste0("jobEfc_", sectorStr))
      expect_that( length(which(duplicated(da5Dfr$hjob)))==0, is_true() )
      expect_that( length(grep(",",da5Dfr$content))==0, is_true() )
      expect_that( sum(is.na(da5Dfr$hjob))==0, is_true() )
      expect_that( sum(is.na(da5Dfr$content))==0, is_true() )
    } else {
      expect_that( length(which(duplicated(retDfr$hjob)))==0, is_true() )
      expect_that( length(grep(",",retDfr$content))==0, is_true() )
      expect_that( sum(is.na(retDfr$hjob))==0, is_true() )
      expect_that( sum(is.na(retDfr$content))==0, is_true() )
    }
  }
  
  #---  Restore user environment
  setwd(user.wd)
}
)

context("PlusJob RDA file checks")

test_that( "RDA",
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
  #       (1) File RDA is newer than CSV file
  #       (2) Exists column "outcome" in RDA file
  for( sectorStr in typeStr )
  {
    da5Dfr  <- fileReadDfr(paste0("jobEfc_", sectorStr))
    fileStr <- paste0(RegGetRNonSourceDir(), "jobEfc_", sectorStr, ".rda")
    deprecatedBln <- !file.exists(fileStr)
    if( !deprecatedBln )
    {
      if( exists("retDfr") ) rm("retDfr")
      load(fileStr)
      if( !exists("retDfr") )
        deprecatedBln <- TRUE
    }
    if( deprecatedBln )
    {
      warning("The CSV file has been deprecated. Call the function JobEfcCreateRdaNum() to create an RDA file.")
    } else {
      expect_that( nrow(retDfr)>=nrow(da5Dfr), is_true() )
      expect_that( length(which(names(retDfr)=="outcome"))>0, is_true() )
    }
  }
  
  #---  Restore user environment
  setwd(user.wd)
}
)