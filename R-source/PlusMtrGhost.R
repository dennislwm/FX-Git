#|------------------------------------------------------------------------------------------|
#|                                                                           PlusMtrGhost.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Example                                                                                  |
#|    J.  > mt.list <- MtrTagInJClass(mt.list, name.str)                                    |
#|        > mt.list <- MtrTagInJLink(mt.list)                                               |
#|        > mt.list <- MtrTagInJExtern(mt.list)                                             |
#|        > cmtDfr  <- MtrLookupJCmt(mt.list)                                               |
#|        > funDfr  <- MtrLookupJFun(mt.list, cmtDfr)                                       |
#|        > mt.list <- MtrTagInJFun(mt.list, funDfr)                                        |
#|        > mt.list <- MtrTagInJGvar(mt.list, funDfr)                                       |
#|        > mt.list <- MtrJConvert(mt.list, funDfr)                                         |
#|        > mt.list <- MtrJType(mt.list)                                                    |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.1.2   Added THREE (3) MtrAddInRghostxxx() functions in new "C" section. For section   |
#|          "J", added ONE (1) function MtrJConvertName() and expanded function MtrJType()  |
#|          to include arrays. For section "A", added ONE (1) function MtrBraces() that     |
#|          generically finds the matching close braces "}".                                |
#|  1.1.1   Renamed test script to "R-test-10-mtrghost/testPlusMtrGhost.R" and test for ONE |
#|          (1) function MtrLookupJFun(). Renamed TWO (2) functions MtrFindFunDfr() and     |
#|          MtrFindCmtDfr() to MtrLookupJFun() and MtrLookupJCmt() respectively.            |
#|          Fixed TWO (2) errors in function MtrIsComment(): (a) typo "cmtDfr" changed to   |
#|          "cDfr"; (b) parameter "tokenStr" changed to "first" - if numeric, then "first"  |
#|          refers to the position within a line, else it is a "token" character.           |
#|  1.1.0   Added SEVEN (7) MtrJxxx() functions to re-convert a "normalized" java file back |
#|          into an mq4 file. The Rmd file "Mt4r_03_Keiji_probot_tseries" has an example of |
#|          converting an mq4 file into a SqLite file, with an intermediate java file.      |
#|          Todo: Test script for (a) FIVE (5) "B" functions; SEVEN (7) "J" functions.      |
#|  1.0.1   Fixed minor bugs: (a) missing argument for MtrIsComment(); (b) empty rowNum in  |
#|          functions MtrBetweenxxx(). Note: This file was previously named "PlusMtr.R".    |
#|  1.0.0   Added test script "R-test-09-mtr/testPlusMtr.R" for TWO (2) functions           |
#|          MtrLookupJCmt() and MtrIsComment(). Todo: Test script for FIVE (5) functions    |
#|          MtrConvertStr(), MtrFindLoopDfr(), MtrLookupJFun(), MtrBetweenLoopDfr(), and    |
#|          MtrBetweenFunDfr().                                                             |
#|  0.9.0   This library contains external R functions to interact with MetaTrader 4.       |
#|------------------------------------------------------------------------------------------|
if( Sys.info()["sysname"] == "Linux" )
{
  suppressPackageStartupMessages(source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
}
if( Sys.info()["sysname"] == "Windows" )
{
  suppressPackageStartupMessages(source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
}
suppressPackageStartupMessages(source(paste0(RegRSourceDir(),"PlusAddThat.R"), echo=FALSE))
suppressPackageStartupMessages(source(paste0(RegRSourceDir(),"PlusMtr.R"), echo=FALSE))
suppressPackageStartupMessages(library(R.utils))

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   J   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrJType <- function(mt.list)
{
  ret.list <- list()
  j <- 1
  for( i in seq_along(mt.list) )
  {
    #--- Read Line
    lineChr <- mt.list[[i]]
    
    #--- Data types
    lineChr <- gsub("Date",   "datetime", lineChr)
    lineChr <- gsub("String$", "string", lineChr)
    
    #--- Reverse arrays []
    first   <- grep("double\\[\\]", lineChr)
    last    <- length(lineChr)
    if( length(first)>0 & length(lineChr)>1 )
    {
      first     <- c("double")
      col       <- as.numeric(regexpr(";",lineChr[2]))
      if( col > 0 )
        second  <- paste0(substr(lineChr[2], 1, col-1),"[];")
      else
        second  <- lineChr[2]
      lineChr <- c(first, second, lineChr[3:last])
    }
    
    #--- Write Line
    ret.list[[j]] <- lineChr
    j <- j + 1
  }
  ret.list
}
MtrJConvertName <- function(mt.list, funDfr)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(funDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  
  #---  Save some tags
  name.tag  <- rep(NA, length(mt.list))
  pty.tag   <- w(mt.list,"jproperty")
  ext.tag   <- w(mt.list,"jextern")
  gvr.tag   <- w(mt.list,"jgvar")
  fun.tag   <- w(mt.list,"jfun")
  
  #---  Replace Jtag with actual tags
  if( length(pty.tag)>0 )   
    name.tag[pty.tag[length(pty.tag)]] <- "link"
  if( length(ext.tag)>0 )
    name.tag[ext.tag[length(ext.tag)]] <- "extern"
  if( length(gvr.tag)>0 )
    name.tag[gvr.tag[length(gvr.tag)]] <- "gvar"
  if( length(fun.tag)>0 )
  {
    cls.tag           <- as.numeric(funDfr$Close)
    name.tag[fun.tag] <- paste0("_", funDfr$Name)
    name.tag[cls.tag] <- paste0("_", funDfr$Name, "_end")
  }
  name.tag
}
MtrJConvert <- function(mt.list, funDfr)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(funDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  
  ret.list  <- list()
  nameChr   <- names(mt.list)
  nameChr[is.na(nameChr)] <- ""
  for( i in 1:length(mt.list) )
  {
    mt.line <- mt.list[[i]]
    mt.len  <- length(mt.line)
    if( nameChr[i]=="jproperty" )
      ret.list  <- append( ret.list, list(c(paste0('#',mt.line[6]),mt.line[7:mt.len])) )
    else if( nameChr[i]=="jextern" )
      ret.list  <- append( ret.list, list(c('extern',mt.line[6:mt.len])) )
    else if( nameChr[i]=="jgvar" )
      ret.list  <- append( ret.list, list(c(mt.line[6:mt.len])) )
    else if( nameChr[i]=="jfun" )
      ret.list  <- append( ret.list, list(c(mt.line[6:mt.len])))
    else if( mt.len < 5 )
      ret.list  <- append( ret.list, list(c('')) )
    else
      ret.list  <- append( ret.list, list(c(mt.line[5:mt.len])) )
  }
  ret.list
}
MtrTagInJGvar <- function(mt.list, funDfr)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(funDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  
  tokenChr  <- c("jclass","jproperty","jextern")
  openNum   <- 1
  for( i in seq_along(tokenChr) )
  {
    retNum  <- w(mt.list,tokenChr[i])
    if( max(retNum)>openNum )
      openNum <- max(retNum)
  }
  closeNum  <- length(mt.list)
  if( nrow(funDfr)>0 )
  {
    if( min(funDfr$Open) < closeNum )
      closeNum <- min(funDfr$Open)
  }

  tagNum <- c()
  rowNum <- which(lapply(mt.list, function(x) { sum(grep("private", x)) })>0)
  rowNum <- rowNum[rowNum>openNum & rowNum<closeNum]
  for( i in seq_along(rowNum) )
  {
    grepNum     <- grep("private", mt.list[[rowNum[i]]])
    if(grepNum[1]==5)
      extBln  <- TRUE
    else
      extBln  <- FALSE
    if( extBln )  tagNum <- c(tagNum, rowNum[i])
  }
  names(mt.list)[tagNum] <- "jgvar"
  mt.list
}
MtrTagInJFun <- function(mt.list, funDfr)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(funDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  
  rowNum <- c()
  for( i in 1:nrow(funDfr) )
    rowNum <- c(rowNum, as.numeric(funDfr$Open))
  names(mt.list)[rowNum] <- "jfun"
  mt.list
}
MtrTagInJClass <- function(mt.list, name.str)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(name.str)
  if( !is.null(stopStr) ) stop(stopStr)
  
  tagNum <- c()
  rowNum <- which(lapply(mt.list, function(x) { sum(grep(name.str, x)) })>0)
  for( i in seq_along(rowNum) )
  {
    grepNum     <- grep(name.str, mt.list[[rowNum[i]]])
    grepLeft    <- grep("class", mt.list[[rowNum[i]]])
    if( length(grepLeft)==0 )
      extBln    <- FALSE
    else
    {
      if(grepLeft[1]==(grepNum[1]-1) & grepLeft[1]==1)
        extBln  <- TRUE
      else
        extBln  <- FALSE
    }
    if( extBln )  tagNum <- c(tagNum, rowNum[i])
  }
  names(mt.list)[tagNum] <- "jclass"
  mt.list
}
MtrTagInJLink <- function(mt.list)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  
  tagNum <- c()
  rowNum <- which(lapply(mt.list, function(x) { sum(grep("property", x)) })>0)
  for( i in seq_along(rowNum) )
  {
    grepNum     <- grep("property", mt.list[[rowNum[i]]])
    grepLeft    <- grep("//", mt.list[[rowNum[i]]])
    if( length(grepLeft)==0 )
      extBln    <- FALSE
    else
    {
      if(grepLeft[1]==(grepNum[1]-1) & grepLeft[1]==5)
        extBln  <- TRUE
      else
        extBln  <- FALSE
    }
    if( extBln )  tagNum <- c(tagNum, rowNum[i])
  }
  names(mt.list)[tagNum] <- "jproperty"
  mt.list
}
MtrTagInJExtern <- function(mt.list)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  
  tagNum <- c()
  rowNum <- which(lapply(mt.list, function(x) { sum(grep("External", x)) })>0)
  for( i in seq_along(rowNum) )
  {
    grepNum     <- grep("External", mt.list[[rowNum[i]]])
    grepLeft    <- grep("//", mt.list[[rowNum[i]]])
    grepRight   <- grep("variable\\(s\\)", mt.list[[rowNum[i]]])
    if( length(grepLeft)==0 || length(grepRight)==0 )
      extBln    <- FALSE
    else
    {
      if(grepLeft[1]==(grepNum[1]-1) & grepLeft[1]==5
         & grepRight[1]==(grepNum[1]+1))
        extBln  <- TRUE
      else
        extBln  <- FALSE
    }
    if( extBln )  tagNum <- c(tagNum, rowNum[i])
  }
  names(mt.list)[tagNum+1] <- "jextern"
  mt.list
}

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   C   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrAddInRghostTop <- function(mt.list)
{
  mt.list <- MtrAddInLink(mt.list,'include','<PlusTurtle.mqh>','')
  mt.list <- MtrAddInLink(mt.list,'include','<PlusGhost.mqh>','')
  mt.list <- MtrAddInGvar(mt.list,'int','MaxAccountTrades=4')
  mt.list
}
MtrAddInRghostInit <- function(mt.list)
{
  openNum   <- w(mt.list,"_init")
  if( length(w1(mt.list,openNum))>0 ) 
    d <- w1(mt.list,openNum)[1]-1
  else
    d <- 0
  ins.list  <- list(cs(d+2,'TurtleInit();'),
                    cs(d+2,'GhostInit();'))
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_init_end")-2 )
  mt.list
}
MtrAddInRghostDeinit <- function(mt.list)
{
  d <- 0
  if( length(w(mt.list,"_deinit"))>0 )
  {
    openNum <- w(mt.list,"_deinit")
    if( length(w1(mt.list,openNum))>0 ) 
      d <- w1(mt.list,openNum)[1]-1
  }
  else
  {
    openNum <- 0
    mt.list <- append( mt.list, MtrAddDeinit(), after=w(mt.list,"_init_end") )
  }
  ins.list  <- list(cs(d+2,'GhostDeInit();'))
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_deinit_end")-2 )
  mt.list
}

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   B   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrBetweenFunDfr <- function(mt.list, funDfr, cmtDfr, funThatChr=NULL)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(cmtDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddNameMatch(names(funDfr), c("Token", "Open", "Close", "First", "Name"))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddNameMatch(names(cmtDfr), c("Open", "Close"))
  if( !is.null(stopStr) ) stop(stopStr)
  
  funChr <- c("OrderSend", "OrderModify", "OrderClose", funThatChr)
  endNum <- length(mt.list)
  retDfr <- dataFrame( colClasses=c(Token="character", Open="numeric", 
                                    Close="numeric", First="numeric",
                                    Name="character"), nrow=0 )
  for( n in seq_along(funDfr$Open) )
  {
    #---  Knowledge when "for" has OrderSelect and ONE (1) or more of OrderSend
    #     (1) check for OrderSelect
    #     (2) check for OrderSend
    #     (3) check for OrderModify
    #     (4) check for OrderClose
    #     (5) check for OrderDelete
    tokenStr  <- funDfr$Token[n]
    openNum   <- funDfr$Open[n]
    closeNum  <- funDfr$Close[n]
    firstNum  <- funDfr$First[n]
    nameStr   <- funDfr$Name[n]
    rowNum    <- which(lapply(mt.list[openNum:closeNum],
                              function(x) { sum(grep("OrderSelect", x)) })>0)
    if( length(rowNum)>0 )
    {
      cmtBln    <- MtrIsComment(mt.list, "OrderSelect", rowNum+openNum-1, cmtDfr)
      isOpenSelect <- sum(cmtBln)<length(cmtBln)
    } else isOpenSelect <- FALSE
    if( !isOpenSelect )
    {
      isOpenFun   <- FALSE
      for( o in seq_along(funChr) )
      {
        funStr    <- funChr[o]
        fRowNum   <- which(lapply(mt.list[openNum:closeNum],
                                  function(x) { sum(grep(funStr, x)) })>0)
        if( length(fRowNum)>0 )
        {
          fCmtBln   <- MtrIsComment(mt.list, funStr, fRowNum+openNum-1, cmtDfr)
          isOpenFun <- isOpenFun | (sum(fCmtBln)<length(fCmtBln))
        } else isOpenFun <- isOpenFun | FALSE
      }
      if( isOpenFun )
      {
        rDfr        <- data.frame( tokenStr, openNum, closeNum, firstNum, nameStr )
        names(rDfr) <- names(retDfr)
        retDfr      <- rbind(retDfr, rDfr)
      }
    }
  }  
  retDfr
}
MtrBetweenLoopDfr <- function(mt.list, loopDfr, cmtDfr, funThatChr=NULL)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(cmtDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddNameMatch(names(loopDfr), c("Token", "Open", "Close", "First"))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddNameMatch(names(cmtDfr), c("Open", "Close"))
  if( !is.null(stopStr) ) stop(stopStr)
  
  funChr <- c("OrderSend", "OrderModify", "OrderClose", funThatChr)
  endNum <- length(mt.list)
  retDfr <- dataFrame( colClasses=c(Token="character", Open="numeric", 
                                    Close="numeric", First="numeric"), nrow=0 )
  for( n in seq_along(loopDfr$Open) )
  {
    #---  Knowledge when "for" has OrderSelect and ONE (1) or more of OrderSend
    #     (1) check for OrderSelect
    #     (2) check for OrderSend
    #     (3) check for OrderModify
    #     (4) check for OrderClose
    #     (5) check for OrderDelete
    tokenStr  <- loopDfr$Token[n]
    openNum   <- loopDfr$Open[n]
    closeNum  <- loopDfr$Close[n]
    firstNum  <- loopDfr$First[n]
    rowNum    <- which(lapply(mt.list[openNum:closeNum],
                              function(x) { sum(grep("OrderSelect", x)) })>0)
    if( length(rowNum)>0 )
    {
      cmtBln <- MtrIsComment(mt.list, "OrderSelect", rowNum+openNum-1, cmtDfr)
      isOpenSelect <- sum(cmtBln)<length(cmtBln)
    } else isOpenSelect <- FALSE
    if( isOpenSelect )
    {
      isOpenFun   <- FALSE
      for( o in seq_along(funChr) )
      {
        funStr    <- funChr[o]
        fRowNum   <- which(lapply(mt.list[openNum:closeNum],
                                  function(x) { sum(grep(funStr, x)) })>0)
        if( length(fRowNum)>0 )
        {
          fCmtBln   <- MtrIsComment(mt.list, funStr, fRowNum+openNum-1, cmtDfr)
          isOpenFun <- isOpenFun | (sum(fCmtBln)<length(fCmtBln))
        } else isOpenFun <- isOpenFun | FALSE
      }
      if( isOpenFun )
      {
        rDfr        <- data.frame(tokenStr, openNum, closeNum, firstNum )
        names(rDfr) <- names(retDfr)
        retDfr      <- rbind(retDfr, rDfr)
      }
    }
  }  
  retDfr
}
MtrLookupJFun <- function(mt.list, cmtDfr)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(cmtDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddNameMatch(names(cmtDfr), c("Open", "Close"))
  if( !is.null(stopStr) ) stop(stopStr)
  
  tokenChr  <- c("public")
  offset    <- 3
  endNum <- length(mt.list)
  retDfr <- dataFrame( colClasses=c(Token="character", Open="numeric", 
                                    Close="numeric", First="numeric",
                                    Name="character"), nrow=0 )
  for( m in seq_along(tokenChr) )
  {
    tokenStr  <- tokenChr[m]
    rowNum    <- which(lapply(mt.list, function(x) { sum(grep(tokenStr, x)) })>0)
    cmtBln    <- MtrIsComment(mt.list, tokenStr, rowNum, cmtDfr)
    for( n in seq_along(rowNum) )
    {
      openNum     <- as.numeric(rowNum[n])
      indentNum   <- which(nchar(mt.list[[openNum]])>0)
      isOpenCmt   <- cmtBln[n]
      #---  Identify non-valid tokens
      #     (1) tokens may be within a string, i.e. " this is a string "
      if( length(indentNum)>1 )
        isOpenStr   <- sum(grep("\\(", mt.list[[openNum]][indentNum[offset]]))==0
      else
        isOpenStr   <- TRUE
      if( !isOpenCmt &  !isOpenStr )
      {
        #---  Knowledge when "for" has braces OR NOT
        #     (1) check if next token is "{"
        nameStr     <- substr(mt.list[[openNum]][indentNum[offset]], 1,
                              as.numeric(gregexpr("\\(", mt.list[[openNum]][indentNum[offset]]))-1)
        closeNum    <- MtrBraces(mt.list, indentNum[1], openNum, endNum, cmtDfr)
        rDfr        <- data.frame(tokenStr, openNum, closeNum, indentNum[1],
                                  nameStr)
        names(rDfr) <- names(retDfr)
        retDfr      <- rbind(retDfr, rDfr)
      }
    }
  }
  retDfr
}
MtrFindLoopDfr <- function(mt.list, cmtDfr, tokenChr=c("for"))
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(cmtDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddNameMatch(names(cmtDfr), c("Open", "Close"))
  if( !is.null(stopStr) ) stop(stopStr)
  
  endNum <- length(mt.list)
  retDfr <- dataFrame( colClasses=c(Token="character", Open="numeric", 
                                    Close="numeric", First="numeric"), nrow=0 )
  for( m in seq_along(tokenChr) )
  {
    tokenStr  <- tokenChr[m]
    rowNum    <- which(lapply(mt.list, function(x) { sum(grep(tokenStr, x)) })>0)
    if(length(rowNum)>0)
      cmtBln    <- MtrIsComment(mt.list, tokenStr, rowNum, cmtDfr)
    for( n in seq_along(rowNum) )
    {
      openNum     <- as.numeric(rowNum[n])
      indentNum   <- which(nchar(mt.list[[openNum]])>0)
      isOpenCmt   <- cmtBln[n]
      #---  Identify non-valid tokens
      #     (1) tokens may be within a string, i.e. " this is a string "
      if( length(indentNum)>1 )
        isOpenStr   <- substr(mt.list[[openNum]][indentNum[2]],1,1)!="("
      else
        isOpenStr   <- TRUE
      if( !isOpenCmt &  !isOpenStr )
      {
        #---  Knowledge when "for" has braces OR NOT
        #     (1) check if next token is "{"
        closeNum    <- MtrBraces(mt.list, indentNum[1], openNum, endNum, cmtDfr)
        rDfr        <- data.frame(tokenStr, openNum, closeNum, indentNum[1] )
        names(rDfr) <- names(retDfr)
        retDfr      <- rbind(retDfr, rDfr)
      }
    }
  }
  retDfr
}
MtrBraces <- function(mt.list, first, openNum, endNum, cmtDfr)
{
  for( mRow in (openNum+1):endNum )
  {
    isNextCmt <- MtrIsComment(mt.list,first,mRow,cmtDfr)
    if( !isNextCmt ) break
  }
  nextNum     <- mRow
  indnxtNum   <- which(nchar(mt.list[[nextNum]])>0)
  if( first==indnxtNum[1] )
    isOpenBrs <- substr(mt.list[[nextNum]][first],1,1)=='{'
  else
    isOpenBrs <- FALSE
  if( !isOpenBrs )
    startNum  <- nextNum
  else
    startNum  <- nextNum + 1
  for( mRow in startNum:endNum )
  {
    iNum  <- which(nchar(mt.list[[mRow]])>0)
    if( length(iNum)>0 )
      if( first==iNum[1] )
      {
        isCloseCmt  <- MtrIsComment(mt.list,first,mRow,cmtDfr)
        if( !isCloseCmt ) break
      }
  }
  if( !isOpenBrs )
    closeNum  <- mRow - 1
  else
    closeNum  <- mRow
  return( closeNum )
}
MtrConvertStr <- function(name.str, exe.dir=paste0(RegProgramDir(),"mq4_converter/"),
                          ea.dir=RegEaDir(), java.dir=RegJavaDir())
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(name.str)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddExistN(substr(exe.dir,1,nchar(exe.dir)-1))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddExistN(substr(ea.dir,1,nchar(ea.dir)-1))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddExistN(substr(java.dir,1,nchar(java.dir)-1))
  if( !is.null(stopStr) ) stop(stopStr)
  
  ea.str    <- paste0(name.str, ".mq4")
  java.str  <- paste0(name.str, ".java")
  exe.str   <- "mq4_writer.exe"
  
  stopStr <- AddExists(paste0(exe.dir, exe.str))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddExists(paste0(ea.dir, ea.str))  
  if( !is.null(stopStr) ) stop(stopStr)
  
  cmd.str   <- paste0('"', exe.dir, exe.str, '" "', ea.dir, ea.str, 
                      '" java "', java.dir, java.str, '"')
  
  errNum <- RegSystemNum(cmd.str)
  if( errNum!=0 | !file.exists(paste0(java.dir, java.str)) )
    return( paste0(errNum, ': ', java.str, ' is missing (OR NOT converted correctly)') )
  else
    return( paste0(java.dir, java.str) )
}

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   A   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrLookupJCmt <- function(mt.list)
{
  endNum <- length(mt.list)
  retDfr <- dataFrame( colClasses=c(Token="character", Open="numeric", Close="numeric",
                                    First="numeric", Last="numeric"), nrow=0 )
  rowNum <- which(lapply(mt.list, function(x) { sum(grep("//", x)) })>0)
  for( n in seq_along(rowNum) )
  {
    openNum     <- as.numeric(rowNum[n])
    betweenNum  <- grep("//", mt.list[[openNum]])
    rDfr        <- data.frame("cmt", openNum, openNum, betweenNum[1], 1e6 )
    names(rDfr) <- names(retDfr)
    retDfr      <- rbind(retDfr, rDfr)
  }
  rowNum    <- which(lapply(mt.list, function(x) { sum(grep("^\\/\\*", x)) })>0)
  rowcNum   <- which(lapply(mt.list, function(x) { sum(grep("\\*\\/", x)) })>0)
  for( n in seq_along(rowNum) )
  {
    openNum     <- as.numeric(rowNum[n])
    betweenNum  <- grep("\\/\\*", mt.list[[openNum]])
    closeNum    <- rowcNum[n]
    betweencNum <- grep("\\*\\/", mt.list[[closeNum]])
    rDfr        <- data.frame("cmt", openNum, closeNum, betweenNum[1], betweencNum[1] )
    names(rDfr) <- names(retDfr)
    retDfr      <- rbind(retDfr, rDfr)
  }
  retDfr
}
MtrIsComment <- function(mt.list, first, rowNum, cmtDfr)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(first)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(rowNum)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMore(rowNum, 0)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMoreE(length(mt.list), length(rowNum))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(cmtDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddNameMatch(names(cmtDfr), c("Open", "Close", "First", "Last"))
  if( !is.null(stopStr) ) stop(stopStr)
  
  retBln  <- NULL
  for( n in seq_along(rowNum) )
  {
    openNum     <- as.numeric(rowNum[n])
    if( is.numeric(first) )
      betweenNum  <- first
    else
      betweenNum  <- grep(first, mt.list[[openNum]])
    #---  Identify non-valid tokens
    #     (1) tokens may be within a comment: (a) // ; (b) /*  */
    cDfr        <- cmtDfr[cmtDfr$Open<=openNum & openNum<=cmtDfr$Close,]
    if( nrow(cDfr)>0 )
    {
      if( cDfr$Open==cDfr$Close )
        isBetween   <- betweenNum>=cDfr$First & betweenNum<=cDfr$Last 
      else
      {
        if( openNum==cDfr$Open )
          isBetween   <- betweenNum>=cDfr$First
        else if( openNum==cDfr$Close )
          isBetween   <- betweenNum<=cDfr$Last 
        else
          isBetween   <- betweenNum>=1 & betweenNum<=1e6
      }
      isCmt       <- sum(isBetween)==length(betweenNum)
    }
    else
      isCmt       <- FALSE
    retBln <- c(retBln, isCmt)
  }
  retBln
}
#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|