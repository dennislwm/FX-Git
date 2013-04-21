#|------------------------------------------------------------------------------------------|
#|                                                                                PlusMtr.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
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
                                    First="numeric"), nrow=0 )
  rowNum <- which(lapply(mt.list, function(x) { sum(grep("//", x)) })>0)
  for( n in seq_along(rowNum) )
  {
    openNum     <- rowNum[n]
    indentNum   <- which(nchar(mt.list[[openNum]])>0)
    rDfr        <- data.frame("cmt", openNum, openNum, indentNum[1] )
    names(rDfr) <- names(retDfr)
    retDfr      <- rbind(retDfr, rDfr)
  }
  rowNum    <- which(lapply(mt.list, function(x) { sum(grep("\\/\\*", x)) })>0)
  rowcNum   <- which(lapply(mt.list, function(x) { sum(grep("\\*\\/", x)) })>0)
  for( n in seq_along(rowNum) )
  {
    openNum     <- rowNum[n]
    indentNum   <- which(nchar(mt.list[[openNum]])>0)
    closeNum    <- rowcNum[n]
    rDfr        <- data.frame("cmt", openNum, closeNum, indentNum[1] )
    names(rDfr) <- names(retDfr)
    retDfr      <- rbind(retDfr, rDfr)
  }
  retDfr
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrIsComment <- function(tokenStr, rowNum, cmtDfr)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(tokenStr)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(rowNum)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(cmtDfr)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMore(rowNum, 0)
  if( !is.null(stopStr) ) stop(stopStr)
  
  retBln  <- NULL
  for( n in seq_along(rowNum) )
  {
    openNum     <- rowNum[n]
    #---  Identify non-valid tokens
    #     (1) tokens may be within a comment: (a) // ; (b) /*  */
    cDfr        <- cmtDfr[cmtDfr$Open<=openNum & openNum<=cmtDfr$Close,]
    isOpenCmt   <- nrow(cDfr)>0
    retBln <- c(retBln, isOpenCmt)
  }
  retBln
}
#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|