#|------------------------------------------------------------------------------------------|
#|                                                                            testPlusPdf.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script perform unit tests on functions in PlusPdf.R.                       |
#|------------------------------------------------------------------------------------------|
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R")
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusPdf.R")

context("PlusPdf checks")

test_that( "pdfGmailNum",
{
  #---  Assert TWO (2) arguments:   
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-03/")
  setwd(test.wd)
  
  #---  Test without any data
  #       (1) File attachment does not exist
  expect_that( pdfGmailNum("fake.pdf"), throws_error() )
  
  #       (2) Message file does not exist
  #       (4) Empty toChr
  writeLines("test_attached", "test_attached.pdf")
  expect_that( pdfGmailNum("test_attached.pdf", "fake.txt"), throws_error() )
  expect_that( pdfGmailNum("test_attached.pdf", toChr=""), throws_error() )
  
  #---  Test with incorrect uni data
  #       (10) Invalid toChr format
  #       (11) Invalid ccChr format
  expect_that( pdfGmailNum("test_attached.pdf", toChr="fakemail@"), throws_error() )
  expect_that( pdfGmailNum("test_attached.pdf", ccChr="fakemail@"), throws_error() )
  
  #---  Test with correct uni data
  #       (13) Send an email with ONE (1) file attachment
  #            with a message file and subject to ONE (1)
  #            receipient in toChr and ccChr EACH
  writeLines("test message", "test_message.txt")
  
  expect_that( pdfGmailNum("test_attached.pdf", msgFileChr="test_message.txt",
                           subjChr="Hello world - testPlusPdf",
                           toChr="dennislwm@yahoo.com.au",
                           ccChr="dennislwm@gmail.com"), 
               is_equivalent_to(0) )
  
  #---  Test with correct multi data
  #       (14) Send an email with TWO (2) file attachment
  #            with a message file and subject to TWO (2)
  #            receipients in toChr and ccChr EACH
  expect_that( pdfGmailNum("test_attached.pdf", msgFileChr="test_message.txt",
                           subjChr="Hello world 2 testPlusPdf",
                           toChr=c("dennislwm@yahoo.com.au","6y588@notsharingmy.info"),
                           ccChr=c("dennislwm@gmail.com","6y588a@gmail.com")), 
               is_equivalent_to(0) )
  
  file.remove("test_message.txt")
  file.remove("test_attached.pdf")
  
  #---  Restore user environment
  #       Restore user files
  setwd(user.wd)
}
)

test_that( "PdfNomuraSeqNum",
{
  #---  Assert TWO (2) arguments:   
  
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  #       Backup user files
  test.wd <- paste0(RegGetRDir(),"R-test-03/")
  setwd(test.wd)
  nonsource.wd <- RegGetRNonSourceDir()
  userFileChr <- paste0(nonsource.wd, "pdfNomura")
  backFileChr <- paste0(nonsource.wd, "pdfNomuraBack")
  if( file.exists( paste0(userFileChr, ".csv") ) )
    file.rename( paste0(userFileChr, ".csv"),
                 paste0(backFileChr, ".csv") )
  
  #---  Test without any data
  #       (1) Empty pidChr
  retDfr <- dataFrame( colClasses=c( pid="character" ), 
                       nrow=0 )
  re1Dfr <- data.frame( "" )
  names(re1Dfr) <- names( retDfr )
  fileWriteCsv( re1Dfr, userFileChr )
  
  expect_that( PdfNomuraSeqNum(toNum=2, silent=TRUE), is_equivalent_to(2) )
  
  #---  Test with dummy data
  #       (2) ONE (2) incorrect value in pidChr
  #       (3) ONE (1) correct value in symChr
  #       (4) TWO (2) correct values in symChr
  #       (5) TWO (2) values: ONE (1) correct and ONE (1) incorrect value in symChr
  #       (6) TWO (2) incorrect values in symChr
  #       (7) ONE (1) correct value in symChr with special character, e.g ^
  re2Dfr <- data.frame( "abc" )
  names(re2Dfr) <- names( retDfr )
  fileWriteCsv( re2Dfr, userFileChr )
  
  expect_that( PdfNomuraSeqNum(toNum=2, silent=TRUE), is_equivalent_to(2) )
  
  file.remove( paste0(userFileChr, ".csv") )
  
  #---  Restore user environment
  #       Restore user files
  if( file.exists( paste0(backFileChr, ".csv") ) )
    file.rename( paste0(backFileChr, ".csv"),
                 paste0(userFileChr, ".csv") )
  
  setwd(user.wd)
}
)
