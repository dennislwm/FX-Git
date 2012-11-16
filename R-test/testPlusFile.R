#|------------------------------------------------------------------------------------------|
#|                                                                           testPlusFile.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script perform unit tests on both read and write functions in PlusFile.R.  |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusFile.R")

context("PlusFile checks")

test_that( "fileReadDfr",
  {
    #---  Backup user environment for restore
    user.wd <- getwd()
    
    #---  Set working directory
    test.wd <- "C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-test"
    setwd(test.wd)
    #---  Write multiple CSV files for testing
    #       (1) Empty data file
    #       (2) Data file with ONE (1) row
    #       (3) Data file with TWO (2) rows
    #       (4) Data file with TWO (2) rows and NO header
    datDfr <- data.frame(NULL)
    write.table( datDfr, file=paste0(test.wd, "/1.csv"), sep=",", quote=FALSE, row.names=FALSE, col.names=TRUE )
    datDfr <- data.frame(a=c("a"), b=c("b"), stringsAsFactors=FALSE)
    write.table( datDfr, file=paste0(test.wd, "/2.csv"), sep=",", quote=FALSE, row.names=FALSE, col.names=TRUE )
    da2Dfr <- rbind(datDfr, datDfr)
    write.table( da2Dfr, file=paste0(test.wd, "/3.csv"), sep=",", quote=FALSE, row.names=FALSE, col.names=TRUE )
    write.table( da2Dfr, file=paste0(test.wd, "/4.csv"), sep=",", quote=FALSE, row.names=FALSE, col.names=FALSE )
    
    expect_that( fileReadDfr("0", workDirStr=test.wd), is_identical_to(NULL) )
    expect_that( fileReadDfr("1", workDirStr=test.wd), is_identical_to(NULL) )
    expect_that( fileReadDfr("2", workDirStr=test.wd), is_identical_to(datDfr) )
    expect_that( fileReadDfr("3", workDirStr=test.wd), is_identical_to(da2Dfr) )
    expect_that( fileReadDfr("4", workDirStr=test.wd, header=FALSE), is_equivalent_to(da2Dfr) )
    
    #---  Restore user environment
    setwd(user.wd)
  }
)