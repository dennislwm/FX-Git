#|------------------------------------------------------------------------------------------|
#|                                                                                PlusMtr.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Added test script "R-test-09-mtr/testPlusMtr.R" for TWO (2) functions           |
#|          MtrFindCmtDfr() and MtrIsComment(). Todo: Test script for FIVE (5) functions    |
#|          MtrConvertStr(), MtrFindLoopDfr(), MtrFindFunDfr(), MtrBetweenLoopDfr(), and    |
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
suppressPackageStartupMessages(library(R.utils))

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
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
    cmtBln    <- MtrIsComment("OrderSelect", rowNum+openNum-1, cmtDfr)
    isOpenSelect <- sum(cmtBln)<length(cmtBln)
    if( !isOpenSelect )
    {
      isOpenFun   <- FALSE
      for( o in seq_along(funChr) )
      {
        funStr    <- funChr[o]
        fRowNum   <- which(lapply(mt.list[openNum:closeNum],
                                  function(x) { sum(grep(funStr, x)) })>0)
        fCmtBln   <- MtrIsComment(funStr, fRowNum+openNum-1, cmtDfr)
        isOpenFun <- isOpenFun | (sum(fCmtBln)<length(fCmtBln))
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
    cmtBln    <- MtrIsComment("OrderSelect", rowNum+openNum-1, cmtDfr)
    isOpenSelect <- sum(cmtBln)<length(cmtBln)
    if( isOpenSelect )
    {
      isOpenFun   <- FALSE
      for( o in seq_along(funChr) )
      {
        funStr    <- funChr[o]
        fRowNum   <- which(lapply(mt.list[openNum:closeNum],
                                  function(x) { sum(grep(funStr, x)) })>0)
        fCmtBln   <- MtrIsComment(funStr, fRowNum+openNum-1, cmtDfr)
        isOpenFun <- isOpenFun | (sum(fCmtBln)<length(fCmtBln))
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
MtrFindFunDfr <- function(mt.list, cmtDfr, tokenChr=c("public"), offset=3)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(cmtDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddNameMatch(names(cmtDfr), c("Open", "Close"))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMore(offset, 1)
  if( !is.null(stopStr) ) stop(stopStr)
  
  endNum <- length(mt.list)
  retDfr <- dataFrame( colClasses=c(Token="character", Open="numeric", 
                                    Close="numeric", First="numeric",
                                    Name="character"), nrow=0 )
  for( m in seq_along(tokenChr) )
  {
    tokenStr  <- tokenChr[m]
    rowNum    <- which(lapply(mt.list, function(x) { sum(grep(tokenStr, x)) })>0)
    cmtBln    <- MtrIsComment(tokenStr, rowNum, cmtDfr)
    for( n in seq_along(rowNum) )
    {
      openNum     <- rowNum[n]
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
        nextNum     <- openNum+1
        indnxtNum   <- which(nchar(mt.list[[nextNum]])>0)
        if( indentNum[1]==indnxtNum[1] )
          isOpenBrs   <- substr(mt.list[[nextNum]][indnxtNum[1]],1,1)=="{"
        else
          isOpenBrs   <- FALSE
        if( !isOpenBrs )
          startNum <- openNum + 1
        else
          startNum <- openNum + 2
        for( mRow in startNum:endNum )
        {
          iNum <- which(nchar(mt.list[[mRow]])>0)
          if( length(iNum)>0 )
            if( iNum[1]==indentNum[1] )
            {
              isCloseCmt  <- nrow(cmtDfr[cmtDfr$Open==mRow,])>0
              if( !isCloseCmt ) break
            }
        }
        if( !isOpenBrs ) 
          closeNum  <- mRow - 1
        else
          closeNum  <- mRow
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
      cmtBln    <- MtrIsComment(tokenStr, rowNum, cmtDfr)
    for( n in seq_along(rowNum) )
    {
      openNum     <- rowNum[n]
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
        nextNum     <- openNum+1
        indnxtNum   <- which(nchar(mt.list[[nextNum]])>0)
        if( indentNum[1]==indnxtNum[1] )
          isOpenBrs   <- substr(mt.list[[nextNum]][indnxtNum[1]],1,1)=="{"
        else
          isOpenBrs   <- FALSE
        if( !isOpenBrs )
          startNum <- openNum + 1
        else
          startNum <- openNum + 2
        for( mRow in startNum:endNum )
        {
          iNum <- which(nchar(mt.list[[mRow]])>0)
          if( length(iNum)>0 )
            if( iNum[1]==indentNum[1] )
            {
              isCloseCmt  <- nrow(cmtDfr[cmtDfr$Open==mRow,])>0
              if( !isCloseCmt ) break
            }
        }
        if( !isOpenBrs ) 
          closeNum  <- mRow - 1
        else
          closeNum  <- mRow
        rDfr        <- data.frame(tokenStr, openNum, closeNum, indentNum[1] )
        names(rDfr) <- names(retDfr)
        retDfr      <- rbind(retDfr, rDfr)
      }
    }
  }
  retDfr
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
MtrFindCmtDfr <- function(mt.list)
{
  endNum <- length(mt.list)
  retDfr <- dataFrame( colClasses=c(Token="character", Open="numeric", Close="numeric",
                                    First="numeric", Last="numeric"), nrow=0 )
  rowNum <- which(lapply(mt.list, function(x) { sum(grep("//", x)) })>0)
  for( n in seq_along(rowNum) )
  {
    openNum     <- rowNum[n]
    betweenNum  <- grep("//", mt.list[[openNum]])
    rDfr        <- data.frame("cmt", openNum, openNum, betweenNum[1], 1e6 )
    names(rDfr) <- names(retDfr)
    retDfr      <- rbind(retDfr, rDfr)
  }
  rowNum    <- which(lapply(mt.list, function(x) { sum(grep("\\/\\*", x)) })>0)
  rowcNum   <- which(lapply(mt.list, function(x) { sum(grep("\\*\\/", x)) })>0)
  for( n in seq_along(rowNum) )
  {
    openNum     <- rowNum[n]
    betweenNum  <- grep("\\/\\*", mt.list[[openNum]])
    closeNum    <- rowcNum[n]
    betweencNum <- grep("\\*\\/", mt.list[[closeNum]])
    rDfr        <- data.frame("cmt", openNum, closeNum, betweenNum[1], betweencNum[1] )
    names(rDfr) <- names(retDfr)
    retDfr      <- rbind(retDfr, rDfr)
  }
  retDfr
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrIsComment <- function(mt.list, tokenStr, rowNum, cmtDfr)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(tokenStr)
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
    openNum     <- rowNum[n]
    betweenNum  <- grep(tokenStr, mt.list[[openNum]])
    #---  Identify non-valid tokens
    #     (1) tokens may be within a comment: (a) // ; (b) /*  */
    cDfr        <- cmtDfr[cmtDfr$Open<=openNum & openNum<=cmtDfr$Close,]
    if( nrow(cDfr)>0 )
    {
      if( cmtDfr$Open==cmtDfr$Close )
        isBetween   <- betweenNum>=cDfr$First & betweenNum<=cDfr$Last 
      else
      {
        if( openNum==cmtDfr$Open )
          isBetween   <- betweenNum>=cDfr$First
        else if( openNum==cmtDfr$Close )
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