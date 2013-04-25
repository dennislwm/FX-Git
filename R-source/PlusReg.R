#|------------------------------------------------------------------------------------------|
#|                                                                                PlusReg.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Function                                                                          |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.4   Added function RegLocalProgramDir().                                            |
#|  1.0.3   Renamed several functions from RegGetxxxDir() to RegxxxDir() to simplify names. |
#|          Changed name of function RegGetRDir() to RegGitDir().                           |
#|          Added functions RegBitDir(), RegProgramDir() and RegIsWindows64Bln().           |
#|          Note: Due to name changes, this version is NOT backward compatible.             |
#|  1.0.2   Added function RegIsDateBln() to check for variables of type Date.              |
#|  1.0.1   Fixed RegIsEmailBln() to check for repeating ".xxx" pattern.                    |
#|  1.0.0   This library contains external R functions to perform text manipulation.        |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   B   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
RegSystemNum <- function(cmdChr)
{
  if( RegIsLinuxBln() )
    errNum <- tryCatch( system(cmdChr, intern=FALSE, wait=TRUE),
                        error=function(e) { 9999 }, finally={} )
  if( RegIsWindowsBln() )
    errNum <- tryCatch( system(cmdChr, show.output.on.console=FALSE,
                               intern=FALSE, wait=TRUE),
                        error=function(e) { 9999 }, finally={} )
  errNum
}
RegEaDir <- function()
{
  retDir <- NULL
  pathDir <- RegGitDir()
  if( !is.null(pathDir) )
    retDir <- paste0(pathDir,"experts/")
  retDir
}
RegJavaDir <- function()
{
  retDir <- NULL
  pathDir <- RegGitDir()
  if( !is.null(pathDir) )
    retDir <- paste0(pathDir,"java/")
  retDir
}
RegRSourceDir <- function()
{
  retDir <- NULL
  pathDir <- RegGitDir()
  if( !is.null(pathDir) )
    retDir <- paste0(pathDir,"R-source/")
  retDir
}
RegRNonSourceDir <- function()
{
  retDir <- NULL
  pathDir <- RegGitDir()
  if( !is.null(pathDir) )
    retDir <- paste0(pathDir,"R-nonsource/")
  retDir
}
RegBitDir <- function()
{
  retDir <- NULL
  homeDir <- RegHomeDir()
  if( !is.null(homeDir) )
    retDir <- paste0(homeDir,"100 FxOption/103 FxOptionVerBack/081 Fx Bit/")
  retDir
}
RegGitDir <- function()
{
  retDir <- NULL
  homeDir <- RegHomeDir()
  if( !is.null(homeDir) )
    retDir <- paste0(homeDir,"100 FxOption/103 FxOptionVerBack/080 Fx Git/")
  retDir
}
RegHomeDir <- function()
{
  retDir <- NULL
  if( RegIsLinuxBln() )
    retDir <- paste0("/home/",Sys.info()["user"],"/")
  if( RegIsWindowsBln() )
    retDir <- paste0("C:/Users/",Sys.info()["user"],"/")
  retDir
}
RegProgramDir <- function()
{
  retDir <- NULL
  if( RegIsWindows64Bln() )
    retDir <- "C:/Program Files (x86)/"
  else if( RegIsWindowsBln() )
    retDir <- "C:/Program Files/"
  retDir
}
RegLocalProgramDir <- function()
{
  retDir <- NULL
  if( RegIsWindows64Bln() )
    retDir <- paste0(RegHomeDir(),"AppData/Local/VirtualStore/Program Files (x86)/")
  else if( RegIsWindowsBln() )
    retDir <- paste0(RegHomeDir(),"AppData/Local/VirtualStore/Program Files/")
  retDir
}
RegIsWindowsBln <- function()
{
  retBln <- (Sys.info()["sysname"] == "Windows")
  names(retBln) <- NULL
  retBln
}
RegIsWindows64Bln <- function()
{
  retBln <- (length(grep("x64", Sys.info()["release"])) > 0) & RegIsWindowsBln()
  names(retBln) <- NULL
  retBln
}
RegIsLinuxBln <- function()
{
  retBln <- (Sys.info()["sysname"] == "Linux")
  names(retBln) <- NULL
  retBln
}

#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
RegSearchNum <- function(txtChr, pAndChr="", nAndChr="")
{
  #---  Assert THREE (3) arguments:
  #       txtChr:       a character vector to be searched
  #       pAndChr:      a character vector containing positive words (default: "")
  #       nAndChr:      a character vector containing negative words (default: "")
  #       retNum:       a weighted integer, if >0 positive words outweigh negative
  #                     if <0 negative words outweigh positive, if =0 neutral
  
  pNum <- 0
  nNum <- 0
  if( length(pAndChr)>0 )
  {
    for( i in 1:length(pAndChr) )
      pNum <- pNum + length( grep(tolower(txtChr), 
                                  pattern=tolower(pAndChr[i])) )
  }
  if( length(nAndChr)>0 )
  {
    for( i in 1:length(nAndChr) )
      nNum <- nNum + length( grep(tolower(txtChr), 
                                  pattern=tolower(nAndChr[i])) )
  }
  return(pNum - nNum)
}
RegIsEmailBln <- function( emailChr )
{
  #---  Assert ONE (1) argument:
  #       emailChr:   a character vector of email address
  #       retBln:     a boolean vector to indicate email is a valid format
  
  #---  Email pattern
  #       Does not restrict abc@yahoo.com.au.au.au, which is incorrect
  patStr <- "^([a-zA-Z0-9]+[a-zA-Z0-9._%-]*@(?:[a-zA-Z0-9-])+(\\.+[a-zA-Z]{2,4}){1,2})$"
  grepl(patStr, emailChr)
}
RegIsTypeBln <- function(aChr, typeChr)
{
  return( length(which(typeChr==aChr)) != 0 )
}
RegIsEmptyBln <- function(x)
{
  return( length(x)==0 )
}
RegIsDateBln <- function(aDte)
{
  return( is(aDte, "Date") )
}