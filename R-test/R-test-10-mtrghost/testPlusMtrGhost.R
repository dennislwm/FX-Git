#|------------------------------------------------------------------------------------------|
#|                                                                       testPlusMtrGhost.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.1   Added a test for ONE (1) function MtrLookupJFun().                              |
#|  1.0.0   This script perform unit tests on TWO (2) functions in source "PlusMtr.R":      |
#|          (a) MtrLookupJCmt(); and (b) MtrIsComment(). Todo: Unit tests for FIVE (5)      |
#|          functions: (i) MtrConvertStr(); (ii) MtrFindLoopDfr(); (iii) MtrLookupJFun();   |
#|          (iv) MtrBetweenLoopDfr(); and (v) MtrBetweenFunDfr(). Note: This file was       |
#|          previously named "testPlusMtr.R".                                               |
#|------------------------------------------------------------------------------------------|
if( Sys.info()["sysname"] == "Linux" )
  suppressPackageStartupMessages(source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
if( Sys.info()["sysname"] == "Windows" )
  suppressPackageStartupMessages(source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
suppressPackageStartupMessages(source(paste0(RegRSourceDir(),"PlusMtrGhost.R"), echo=FALSE))
suppressPackageStartupMessages(library(testthat))
suppressPackageStartupMessages(library(R.utils))

#|------------------------------------------------------------------------------------------|
#|                            T E S T   B   F U N C T I O N S                               |
#|------------------------------------------------------------------------------------------|
context("PlusMtrGhost MtrLookupJFun() checks")
test_that( "MtrLookupJFun",
{
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- paste0(RegGitDir(),"R-test/R-test-10-mtrghost/")
  setwd(test.wd)
  
  #---  Test for univariate
  #       (1) class has ONE (1) function init() only
  #       (2) class has ONE (1) function and ONE (1) block comment /* */
  #       (3) class has ONE (1) function and ONE (1) comment line //
  m1.list <- list(c('package','unknown;'),
                  c(character(0)),
                  c('class','test1'),
                  c('{'),
                  cs(4,'//','External','variable\\(s\\)'),
                  cs(4,'private','double','Lot','=','0.1;'),
                  cs(4,'private','int','Slippage','=','3;'),
                  cs(4),
                  cs(4,'public','int','init()'),
                  cs(4,'{'),
                  cs(8,'if(Digits','==','5','||','Digits','==','3)'),
                  cs(12,'Slippage','*=','10;'),
                  cs(4,'}'),
                  c('}'))
  fun1Dfr <- MtrLookupJFun(m1.list, MtrLookupJCmt(m1.list))
  expect_that(nrow(fun1Dfr)==1, is_true())
  expect_that(as.numeric(fun1Dfr$Open[1])==9,   is_true())
  expect_that(as.numeric(fun1Dfr$Close[1])==13, is_true())
  expect_that(as.numeric(fun1Dfr$First[1])==5,  is_true())
  #       (2) class has ONE (1) function and ONE (1) block comment /* */
  m2.list <- m1.list
  m2.list <- append(m2.list, list(c('*/')), after=13)
  m2.list <- append(m2.list, list(c('/*')), after=8)
  fun2Dfr <- MtrLookupJFun(m2.list, MtrLookupJCmt(m2.list))
  expect_that(nrow(fun2Dfr)==0, is_true())
  #       (3) class has ONE (1) function and ONE (1) comment line //
  m3.list <- m1.list
  m3.list <- append(m3.list, list(cs(4,'//public','int','init()')), after=8)
  fun3Dfr <- MtrLookupJFun(m3.list, MtrLookupJCmt(m3.list))
  expect_that(nrow(fun3Dfr)==1, is_true())
  expect_that(as.numeric(fun3Dfr$Open[1])==10,  is_true())
  expect_that(as.numeric(fun3Dfr$Close[1])==14, is_true())
  
  #---  Test for multivariate
  #       (4) class has TWO (2) functions init() and deinit() only
  #       (5) class has TWO (2) functions and ONE (1) block comment /* */
  #       (6) class has TWO (2) functions and TWO (2) comment lines //
  m4.list <- m1.list
  m4.list <- append(m1.list, list(cs(4),
                                  cs(4,'public','int','deinit()'),
                                  cs(4,'{'),
                                  cs(8,'return(0);'),
                                  cs(4,'}')), after=13)
  fun4Dfr <- MtrLookupJFun(m4.list, MtrLookupJCmt(m4.list))
  expect_that(nrow(fun4Dfr)==2, is_true())
  expect_that(as.numeric(fun4Dfr$Open[1])==9,   is_true())
  expect_that(as.numeric(fun4Dfr$Close[1])==13, is_true())
  expect_that(as.numeric(fun4Dfr$First[1])==5,  is_true())
  expect_that(as.numeric(fun4Dfr$Open[2])==15,  is_true())
  expect_that(as.numeric(fun4Dfr$Close[2])==18, is_true())
  expect_that(as.numeric(fun4Dfr$First[2])==5,  is_true())
  #       (5) class has TWO (2) functions and ONE (1) block comment /* */
  m5.list <- m4.list
  m5.list <- append(m5.list, list(c('*/')), after=18)
  m5.list <- append(m5.list, list(c('/*')), after=8)
  fun5Dfr <- MtrLookupJFun(m5.list, MtrLookupJCmt(m5.list))
  expect_that(nrow(fun5Dfr)==0, is_true())
  #       (6) class has TWO (2) functions and TWO (2) comment lines //
  m6.list <- m4.list
  m6.list <- append(m6.list, list(cs(4,'//public','int','init()')), after=9)
  m6.list <- append(m6.list, list(cs(4,'//public','int','init()')), after=8)
  fun6Dfr <- MtrLookupJFun(m6.list, MtrLookupJCmt(m6.list))
  expect_that(nrow(fun6Dfr)==2, is_true())
  expect_that(as.numeric(fun6Dfr$Open[1])==10,  is_true())
  expect_that(as.numeric(fun6Dfr$Close[1])==15, is_true())
  
  #---  Restore user environment
  setwd(user.wd)
}
)

#|------------------------------------------------------------------------------------------|
#|                            T E S T   A   F U N C T I O N S                               |
#|------------------------------------------------------------------------------------------|
context("PlusMtrGhost MtrLookupJCmt() checks")
test_that( "MtrLookupJCmt",
{
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- paste0(RegGitDir(),"R-test/R-test-10-mtrghost/")
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
  
  expect_that(MtrLookupJCmt(m1.list)$First[1], equals(3))
  expect_that(MtrLookupJCmt(m2.list)$First[1], equals(3))
  expect_that(MtrLookupJCmt(m3.list)$First[1], equals(3))
  expect_that(MtrLookupJCmt(m4.list)$First[1], equals(3))
  expect_that(MtrLookupJCmt(m5.list)$Last[1], equals(6))
  expect_that(MtrLookupJCmt(m6.list)$First[1], equals(3))
  expect_that(MtrLookupJCmt(m6.list)$Last[1], equals(6))
  
  #---  Test for multivariate
  #       (7) TWO (2) lines: (1) has only /*; (2) has only */
  #       (8) TWO (2) lines: (1) has code and /*; (2) has */ followed by code
  #       (9) extend ABOVE to THREE (3) lines OR more
  m7.list <- list(c('','','/*this','is'),c('','','a','comment*/'))
  expect_that(MtrLookupJCmt(m7.list)$Open[1], equals(1))
  expect_that(MtrLookupJCmt(m7.list)$Close[1], equals(2))
  expect_that(MtrLookupJCmt(m7.list)$First[1], equals(3))
  expect_that(MtrLookupJCmt(m7.list)$Last[1], equals(4))
  #       (8) TWO (2) lines: (1) has code and /*; (2) has only */
  m8.list <- list(c('','{','/*this','is'),c('','','a','comment*/','}'))
  expect_that(MtrLookupJCmt(m8.list)$Open[1], equals(1))
  expect_that(MtrLookupJCmt(m8.list)$Close[1], equals(2))
  expect_that(MtrLookupJCmt(m8.list)$First[1], equals(3))
  expect_that(MtrLookupJCmt(m8.list)$Last[1], equals(4))
  
  #---  Restore user environment
  setwd(user.wd)
}
)

context("PlusMtrGhost MtrIsComment() checks")
test_that( "MtrIsComment",
{
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- paste0(RegGitDir(),"R-test/R-test-10-mtrghost/")
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
  
  expect_that(MtrIsComment(m1.list, "for", 1, MtrLookupJCmt(m1.list)), is_true())
  expect_that(MtrIsComment(m2.list, "for", 1, MtrLookupJCmt(m2.list)), is_false())
  expect_that(MtrIsComment(m3.list, "for", 1, MtrLookupJCmt(m3.list)), is_true())
  expect_that(MtrIsComment(m4.list, "for", 1, MtrLookupJCmt(m4.list)), is_false())
  expect_that(MtrIsComment(m5.list, "for", 1, MtrLookupJCmt(m5.list)), is_false())
  
  #---  Test for multivariate
  #       (6) TWO (2) lines: (1) has only /*; (2) has only */
  #       (7) TWO (2) lines: (1) has code and /*; (2) has only */
  #       (9) extend ABOVE to THREE (3) lines OR more
  m6.list <- list(c('','','','','/*for', 'example', 'this','is'),
                  c('a','comment*/'))
  m7.list <- list(c('','','','for','/*for', 'example', 'this','is'),
                  c('a','comment*/'))
  expect_that(MtrIsComment(m6.list, "for", 1, MtrLookupJCmt(m6.list)), is_true())
  expect_that(MtrIsComment(m7.list, "for", 1, MtrLookupJCmt(m7.list)), is_false())
  
  #       (8) TWO (2) lines: (1) has only /*; (2) has */ followed by code
  m8.list <- list(c('','','','','/*for', 'example', 'this','is'),
                  c('a','comment*/','','','for'))
  expect_that(MtrIsComment(m8.list, "for", 1, MtrLookupJCmt(m8.list)), is_true())
  expect_that(MtrIsComment(m8.list, "for", 2, MtrLookupJCmt(m8.list)), is_false())

  #       (9) extend ABOVE to THREE (3) lines OR more
  m9.list <- list(c('','','','','/*for', 'example', 'this','is'),
                  c('a','very','for','long'),
                  c('comment*/','','','for'))
  expect_that(MtrIsComment(m9.list, "for", 1, MtrLookupJCmt(m9.list)), is_true())
  expect_that(MtrIsComment(m9.list, "for", 2, MtrLookupJCmt(m9.list)), is_true())
  expect_that(MtrIsComment(m9.list, "for", 3, MtrLookupJCmt(m9.list)), is_false())
  
  #---  Restore user environment
  setwd(user.wd)
}
)
#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|