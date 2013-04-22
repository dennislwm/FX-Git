#|------------------------------------------------------------------------------------------|
#|                                                                            testPlusMtr.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script perform unit tests on TWO (2) functions in source "PlusMtr.R":      |
#|          (a) MtrFindCmtDfr(); and (b) MtrIsComment(). Todo: Unit tests for FIVE (5)      |
#|          functions: (i) MtrConvertStr(); (ii) MtrFindLoopDfr(); (iii) MtrFindFunDfr();   |
#|          (iv) MtrBetweenLoopDfr(); and (v) MtrBetweenFunDfr().                           |
#|------------------------------------------------------------------------------------------|
if( Sys.info()["sysname"] == "Linux" )
  suppressPackageStartupMessages(source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
if( Sys.info()["sysname"] == "Windows" )
  suppressPackageStartupMessages(source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
suppressPackageStartupMessages(source(paste0(RegRSourceDir(),"PlusMtr.R"), echo=FALSE))
suppressPackageStartupMessages(library(testthat))
suppressPackageStartupMessages(library(R.utils))

context("PlusMtr MtrFindCmtDfr() checks")

test_that( "MtrFindCmtDfr",
{
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- paste0(RegGitDir(),"R-test/R-test-09-mtr/")
  setwd(test.wd)

  #---  Test for univariate
  #       (1) line has only //
  #       (2) line has code and //
  #       (3) line has only /* */
  #       (4) line has code and /* */
  #       (5) line has /* */ followed by code
  #       (6) line has code and /* */ followed by code
  m1.list <- list(c('','','//this','is','a','comment'))
  m2.list <- list(c('','{','//this','is','a','comment'))
  m3.list <- list(c('','','/*this','is','a','comment*/'))
  m4.list <- list(c('','{','/*this','is','a','comment*/'))
  m5.list <- list(c('','','/*this','is','a','comment*/', '}'))
  m6.list <- list(c('','{','/*this','is','a','comment*/', '}'))
  
  expect_that(MtrFindCmtDfr(m1.list)$First[1], equals(3))
  expect_that(MtrFindCmtDfr(m2.list)$First[1], equals(3))
  expect_that(MtrFindCmtDfr(m3.list)$First[1], equals(3))
  expect_that(MtrFindCmtDfr(m4.list)$First[1], equals(3))
  expect_that(MtrFindCmtDfr(m5.list)$Last[1], equals(6))
  expect_that(MtrFindCmtDfr(m6.list)$First[1], equals(3))
  expect_that(MtrFindCmtDfr(m6.list)$Last[1], equals(6))
  
  #---  Test for multivariate
  #       (7) TWO (2) lines: (1) has only /*; (2) has only */
  #       (8) TWO (2) lines: (1) has code and /*; (2) has */ followed by code
  #       (9) extend ABOVE to THREE (3) lines OR more
  m7.list <- list(c('','','/*this','is'),c('','','a','comment*/'))
  expect_that(MtrFindCmtDfr(m7.list)$Open[1], equals(1))
  expect_that(MtrFindCmtDfr(m7.list)$Close[1], equals(2))
  expect_that(MtrFindCmtDfr(m7.list)$First[1], equals(3))
  expect_that(MtrFindCmtDfr(m7.list)$Last[1], equals(4))
  #       (8) TWO (2) lines: (1) has code and /*; (2) has only */
  m8.list <- list(c('','{','/*this','is'),c('','','a','comment*/','}'))
  expect_that(MtrFindCmtDfr(m8.list)$Open[1], equals(1))
  expect_that(MtrFindCmtDfr(m8.list)$Close[1], equals(2))
  expect_that(MtrFindCmtDfr(m8.list)$First[1], equals(3))
  expect_that(MtrFindCmtDfr(m8.list)$Last[1], equals(4))
  
  #---  Restore user environment
  setwd(user.wd)
}
)

context("PlusMtr MtrIsComment() checks")

test_that( "MtrIsComment",
{
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- paste0(RegGitDir(),"R-test/R-test-09-mtr/")
  setwd(test.wd)
  
  #---  Test for univariate
  #       (1) line has only //
  #       (2) line has code and //
  #       (3) line has only /* */
  #       (4) line has code and /* */
  #       (5) line has /* */ followed by code
  m1.list <- list(c('','','//for','example,','this','is','a','comment'))
  m2.list <- list(c('','for','//for','example,','this','is','a','comment'))
  m3.list <- list(c('','','/*for','example,','this','is','a','comment*/'))
  m4.list <- list(c('','for','/*for','example,','this','is','a','comment*/'))
  m5.list <- list(c('','','/*for','example,','this','is','a','comment*/', 'for'))
  
  expect_that(MtrIsComment(m1.list, "for", 1, MtrFindCmtDfr(m1.list)), is_true())
  expect_that(MtrIsComment(m2.list, "for", 1, MtrFindCmtDfr(m2.list)), is_false())
  expect_that(MtrIsComment(m3.list, "for", 1, MtrFindCmtDfr(m3.list)), is_true())
  expect_that(MtrIsComment(m4.list, "for", 1, MtrFindCmtDfr(m4.list)), is_false())
  expect_that(MtrIsComment(m5.list, "for", 1, MtrFindCmtDfr(m5.list)), is_false())
  
  #---  Test for multivariate
  #       (6) TWO (2) lines: (1) has only /*; (2) has only */
  #       (7) TWO (2) lines: (1) has code and /*; (2) has only */
  #       (9) extend ABOVE to THREE (3) lines OR more
  m6.list <- list(c('','','','','/*for', 'example', 'this','is'),
                  c('a','comment*/'))
  m7.list <- list(c('','','','for','/*for', 'example', 'this','is'),
                  c('a','comment*/'))
  expect_that(MtrIsComment(m6.list, "for", 1, MtrFindCmtDfr(m6.list)), is_true())
  expect_that(MtrIsComment(m7.list, "for", 1, MtrFindCmtDfr(m7.list)), is_false())
  
  #       (8) TWO (2) lines: (1) has only /*; (2) has */ followed by code
  m8.list <- list(c('','','','','/*for', 'example', 'this','is'),
                  c('a','comment*/','','','for'))
  expect_that(MtrIsComment(m8.list, "for", 1, MtrFindCmtDfr(m8.list)), is_true())
  expect_that(MtrIsComment(m8.list, "for", 2, MtrFindCmtDfr(m8.list)), is_false())

  #       (9) extend ABOVE to THREE (3) lines OR more
  m9.list <- list(c('','','','','/*for', 'example', 'this','is'),
                  c('a','very','for','long'),
                  c('comment*/','','','for'))
  expect_that(MtrIsComment(m9.list, "for", 1, MtrFindCmtDfr(m9.list)), is_true())
  expect_that(MtrIsComment(m9.list, "for", 2, MtrFindCmtDfr(m9.list)), is_true())
  expect_that(MtrIsComment(m9.list, "for", 3, MtrFindCmtDfr(m9.list)), is_false())
  
  #---  Restore user environment
  setwd(user.wd)
}
)