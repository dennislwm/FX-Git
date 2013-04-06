#|------------------------------------------------------------------------------------------|
#|                                                                           testPlusBscd.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script perform unit tests on functions in PlusBscd.R. Added tests for (a)  |
#|          Kang (2004) Valuing NSC and (b) Haugh (2013) Coursera FERM Quiz.                |
#|------------------------------------------------------------------------------------------|
library(testthat)
library(R.utils)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 FX Git/R-source/PlusReg.R")
source("C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-source/PlusBscd.R")

context("PlusBscd Kang (2004) Partial NSC checks")

test_that( "Kang",
{
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- "C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-test-08-bscd"
  setwd(test.wd)
  
  #---  Valuing NSC as SIX(6)-Stage Sequential Compound Option
  #       (1) Stock lattice
  #       (2) Project Call Option
  #       (3) Phase FIVE (5) Call Option
  #       (4) Phase FOUR (4) Call Option
  nsc.bscd  <- BscdCreateModel(r=0.055, b=0.06, n=12, Time=12, sigma=0.25)
  aNum      <- c(13562513, 17414611, 22360804, 28711840, 36866733, 47337822, 60782966, 
                 78046874, 100214169, 128677541, 165225233, 212153398, 272410356)
  aLen      <- length(aNum)
  bNum      <- c(675238, 867022, 1113279, 1429478, 1835487, 2356811,
                 3026206, 3885725, 4989370, 6406478, 8226080, 10562496)
  bLen      <- length(bNum)
  prjNum    <- c(aNum, 
                 0, bNum[ bLen:bLen ], 
                 aNum[ 1:(  aLen - 2 ) ], 0,
                 0, bNum[(  bLen - 1 ):bLen ],
                 aNum[ 1:(  aLen - 4 ) ], 0, 0, 
                 0, bNum[(  bLen - 2 ):bLen ], 
                 aNum[ 1:(  aLen - 6 ) ], 0, 0, 0, 
                 0, bNum[(  bLen - 3 ):bLen ],
                 aNum[ 1:(  aLen - 8 ) ], 0, 0, 0, 0, 
                 0, bNum[(  bLen - 4 ):bLen ],
                 aNum[ 1:(  aLen - 10 ) ], 0, 0, 0, 0, 0, 
                 0, bNum[(  bLen - 5 ):bLen ],
                 aNum[ 1:(  aLen - 12 ) ], 0, 0, 0, 0, 0, 0,
                 0, bNum[(  bLen - 6 ):(  bLen - 1 ) ], 0, 0, 0, 0, 0, 0, 0, 
                 0, bNum[(  bLen - 7 ):(  bLen - 3 ) ], 0, 0, 0, 0, 0, 0, 0, 0,
                 0, bNum[(  bLen - 8 ):(  bLen - 5 ) ], 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, bNum[(  bLen - 9 ):(  bLen - 7 ) ], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, bNum[(  bLen - 10 ):( bLen - 9 ) ], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, bNum[   1:1 ] ) 
  prjMtx    <- t(matrix(prjNum, nrow=13, ncol=13))             
  expect_that( nsc.bscd$sRateMtx * aNum[1], is_equivalent_to( prjMtx ) )
  #       (2) Project Call Option
  aNum      <- aNum - 2023163 
  bNum      <- sapply(bNum - 2023163, max, 0)
  prjNum    <- c(aNum, 
                 0, bNum[ bLen:bLen ], 
                 aNum[ 1:(  aLen - 2 ) ], 0,
                 0, bNum[(  bLen - 1 ):bLen ],
                 aNum[ 1:(  aLen - 4 ) ], 0, 0, 
                 0, bNum[(  bLen - 2 ):bLen ], 
                 aNum[ 1:(  aLen - 6 ) ], 0, 0, 0, 
                 0, bNum[(  bLen - 3 ):bLen ],
                 aNum[ 1:(  aLen - 8 ) ], 0, 0, 0, 0, 
                 0, bNum[(  bLen - 4 ):bLen ],
                 aNum[ 1:(  aLen - 10 ) ], 0, 0, 0, 0, 0, 
                 0, bNum[(  bLen - 5 ):bLen ],
                 aNum[ 1:(  aLen - 12 ) ], 0, 0, 0, 0, 0, 0,
                 0, bNum[(  bLen - 6 ):(  bLen - 1 ) ], 0, 0, 0, 0, 0, 0, 0, 
                 0, bNum[(  bLen - 7 ):(  bLen - 3 ) ], 0, 0, 0, 0, 0, 0, 0, 0,
                 0, bNum[(  bLen - 8 ):(  bLen - 5 ) ], 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, bNum[(  bLen - 9 ):(  bLen - 7 ) ], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, bNum[(  bLen - 10 ):( bLen - 9 ) ], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, bNum[   1:1 ] ) 
  prjMtx    <- t(matrix(prjNum, nrow=13, ncol=13))             
  prjMtx[10,10:12]  <- c(66861, 164900, 406696) 
  prjMtx[9,9:10]    <- c(237246, 495911) 
  prjMtx[8,8:9]     <- c(543346, 1023498) 
  prjMtx[7,7]       <- 1049161 
  prjMtx            <- prjMtx / 1000000
  p.op      <- BscdOptionPrice(nsc.bscd, S=13.562513, X=2.023163, n=12, TypeFlag="ca")
  expect_that( abs(mean( p.op$ca - prjMtx )) < 0.001, is_true() )
  expect_that( p.op$ca[1,1], is_equivalent_to(prjMtx[1,1]) )
  
  #       (3) Phase FIVE (5) Call Option
  cNum      <- c(8408562, 12260660, 17206853, 23557889, 31712782, 42183871, 
                 55629015, 72892923, 95060218, 123523590, 160071282)
  cLen      <- length(cNum)
  dNum      <- c(0, 0, 0, 0, 83491, 
                 340293, 848832, 1708032, 3072129, 5408545)
  dLen      <- length(dNum)
  p5Num     <- c(cNum, 
                 0, dNum[ dLen:dLen ], 
                 cNum[ 1:(  cLen - 2 ) ], 0,
                 0, dNum[(  dLen - 1 ):dLen ],
                 cNum[ 1:(  cLen - 4 ) ], 0, 0, 
                 0, dNum[(  dLen - 2 ):dLen ], 
                 cNum[ 1:(  cLen - 6 ) ], 0, 0, 0, 
                 0, dNum[(  dLen - 3 ):dLen ],
                 cNum[ 1:(  cLen - 8 ) ], 0, 0, 0, 0, 
                 0, dNum[(  dLen - 4 ):dLen ],
                 cNum[ 1:(  cLen - 10 ) ], 0, 0, 0, 0, 0, 
                 0, dNum[(  dLen - 5 ):(  dLen - 1 ) ], 0, 0, 0, 0, 0, 0, 
                 0, dNum[(  dLen - 6 ):(  dLen - 3 ) ], 0, 0, 0, 0, 0, 0, 0,          
                 0, dNum[(  dLen - 7 ):(  dLen - 5 ) ], 0, 0, 0, 0, 0, 0, 0, 0,
                 0, dNum[(  dLen - 8 ):(  dLen - 7 ) ], 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, dNum[ 1:1 ] ) 
  p5Mtx     <- t(matrix(p5Num, nrow=11, ncol=11))
  p5Mtx[9,]     <- 0
  p5Mtx[8,]     <- 0
  p5Mtx[7,8:10] <- c(205915, 507852, 1252527)
  p5Mtx[6,7:8]  <- c(727867, 1520393)
  p5Mtx[5,6]    <- 1639425
  p5Mtx[4,5]    <- 3079928
  p5Mtx[3,3]    <- 3117046
  p5Mtx     <- p5Mtx / 1000000
  p5.op     <- BscdOptionPrice(nsc.bscd, S=2.361567, X=3.130788, subMtx=prjMtx, n=10, 
                               TypeFlag="ca")
  expect_that( abs(mean( p5.op$ca - p5Mtx )) < 0.001, is_true() )
  expect_that( p5.op$ca[1,1], is_equivalent_to(p5Mtx[1,1]) )

  #       (4) Phase FOUR (4) Call Option
  eNum      <- c(4401584, 7707931, 12654124, 19005160, 27160053,  
                 37631142, 51076286, 68340194, 90507489)
  eLen      <- length(eNum)
  fNum      <- c(0, 0, 0, 0,
                 104213, 433850, 1126452, 2359065)
  fLen      <- length(fNum)
  p4Num     <- c(eNum, 
                 0, fNum[ fLen:fLen ], 
                 eNum[ 1:(  eLen - 2 ) ], 0,
                 0, fNum[(  fLen - 1 ):fLen ],
                 eNum[ 1:(  eLen - 4 ) ], 0, 0, 
                 0, fNum[(  fLen - 2 ):fLen ], 
                 eNum[ 1:(  eLen - 6 ) ], 0, 0, 0, 
                 0, fNum[(  fLen - 3 ):fLen ],
                 eNum[ 1:1 ], 0, 0, 0, 0,
                 0, rep(0, 7),
                 0, rep(0, 11),
                 0, rep(0, 11) ) 
  p4Mtx     <- t(matrix(p4Num, nrow=9, ncol=9))
  p4Mtx[5,6:9]  <- c(257022, 633898, 1563395, 3855833)
  p4Mtx[4,5:7]  <- c(930959, 1953089, 3971109)
  p4Mtx[3,4:5]  <- c(2199290, 4181942)
  p4Mtx[2,3]    <- 4315143
  p4Mtx     <- p4Mtx / 1000000
  p4.op     <- BscdOptionPrice(nsc.bscd, S=4.274987, X=4.552729, subMtx=p5Mtx, n=8, 
                               TypeFlag="ca")
  expect_that( abs(mean( p4.op$ca - p4Mtx )) < 0.001, is_true() )
  
  #---  Restore user environment
  setwd(user.wd)
}
)

context("PlusBscd Haugh (2013) Quiz checks")

test_that( "Haugh",
{
  #---  Backup user environment for restore
  user.wd <- getwd()
  
  #---  Set working environment
  test.wd <- "C:/Users/denbrige/100 FXOption/103 FXOptionVerBack/080 FX Git/R-test-08-bscd"
  setwd(test.wd)
  
  #---  We compare output of functions with Quiz TWO (2) answers
  #       (1) Create model
  #       (2) Question ONE(1)-FOUR(4) are related
  #       (3) Question SIX(6)-SEVEN(7) are related
  #       (4) Question EIGHT(8) is a chooser
  quiz.bscd <- BscdCreateModel(r=0.02, b=0.01, n=15, Time=0.25, sigma=0.3)
  q1.op     <- BscdOptionPrice(quiz.bscd, S=100, X=110, n=15, TypeFlag=c("ca", "pa"))
  q1.early  <- BscdOptionEarly(quiz.bscd, S=100, X=110, n=15, TypeFlag="pa")
  q1.min    <- which(apply(q1.early$pa, 2, sum)>0)[1] - 1
  subMtx    <- quiz.bscd$fRateMtx*100
  q6.op     <- BscdOptionPrice(quiz.bscd, S=100, X=110, n=10, subMtx=subMtx, TypeFlag="ca")
  q6.early  <- BscdOptionEarly(quiz.bscd, S=100, X=110, n=10, subMtx=subMtx, TypeFlag="ca")
  q6.min    <- which(apply(q6.early$ca, 2, sum)>0)[1] - 1
  chooser.op    <- BscdOptionPrice(quiz.bscd, 100, 100)
  payChooserNum <- apply(cbind(chooser.op$ce[,11], chooser.op$pe[,11]), 1, max, 0) 
  payChooserNum <- payChooserNum[1:11]
  chooserMtx    <- BscdPayTwoLeafMtx( quiz.bscd$q, payChooserNum, scalar=quiz.bscd$RInv )
  
  expect_that( round(quiz.bscd$u, 4),     is_equivalent_to(1.0395) )
  expect_that( round(q1.op$ca[1,1], 2),   is_equivalent_to(2.60) )
  expect_that( round(q1.op$pa[1,1], 2),   is_equivalent_to(12.36) )
  expect_that( q1.min,                    is_equivalent_to(5) )
  expect_that( round(q6.op$ca[1,1], 2),   is_equivalent_to(1.66) )
  expect_that( q6.min,                    is_equivalent_to(7) )
  expect_that( round(chooserMtx[1,1], 2), is_equivalent_to(10.81) )
                                          
  #---  Restore user environment
  setwd(user.wd)
}
)
