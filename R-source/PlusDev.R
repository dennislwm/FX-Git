#|------------------------------------------------------------------------------------------|
#|                                                                                PlusDev.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert History                                                                           |
#|  0.9.1   Fixed a parsing bug (typo) in function DevConsoleNewInt().                      |
#|  0.9.0   This library contains external R functions to perform device manipulation.      |
#|------------------------------------------------------------------------------------------|
library(gplots)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R")

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
DevConsoleExprPlot <- function(devNum, expr, cex=0.9, ...)
{
  #---  Check that arguments are valid
  #       Use devSetNum() to switch device with retNum
  #       if retNum==devNum, then NO need to switch back
  if( devIsNull(devNum) ) return(NULL) 
  hNum <- devSetNum(devNum)
    
  textplot(capture.output(expr),
           halign="left", valign="top",
           cex=cex,
           ...)
  if( hNum!=devNum ) devSetNum(hNum)
}
DevConsoleTextPlot <- function(devNum, textStr, cex=0.9, ...)
{
  #---  Check that arguments are valid
  #       Use devSetNum() to switch device with retNum
  #       if retNum==devNum, then NO need to switch back
  if( devIsNull(devNum) ) return(NULL) 
  hNum <- devSetNum(devNum)
  
  textplot(textStr,
           halign="left", valign="top",
           cex=cex,
           ...)
  if( hNum!=devNum ) devSetNum(hNum)
}
DevConsoleSinkOff <- function(devNum, cex=0.9, ...)
{
  #---  Check that arguments are valid
  #       Use devSetNum() to switch device with retNum
  #       if retNum==devNum, then NO need to switch back
  if( devIsNull(devNum) ) return(NULL) 
  hNum <- devSetNum(devNum)
  
  sinkplot(c("plot"),
           halign="left", valign="top",
           cex=cex,
           ...)
  if( hNum!=devNum ) devSetNum(hNum)
}
DevConsoleSinkOn <- function(devNum)
{
  #---  Check that arguments are valid
  #       Use devSetNum() to switch device with retNum
  #       if retNum==devNum, then NO need to switch back
  if( devIsNull(devNum) ) return(NULL) 
  hNum <- devSetNum(devNum)
  
  sinkplot(c("start"))
  if( hNum!=devNum ) devSetNum(hNum)
}
DevConsoleNewInt <- function()
{
  #---  Initialize a new device and return its device number
  #       Check for success by counting before and after
  #       Start capture of output
  bgnNum <- devLengthNum()
  dev.new('windows')
  endNum <- devLengthNum()
  
  if( endNum==bgnNum )
    return(0)
  else
    return(dev.cur())
}
DevConsoleOffBln <- function(devNum)
{
  if( devIsNull(devNum) ) return(FALSE) 
  dev.off(devNum)
  return(TRUE)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
devSetNum <- function(devNum)
{
  if( devIsNull(devNum) ) return(NULL)
  
  if( devIsCur(devNum) ) return(devNum)
  
  retNum <- as.numeric(dev.cur())
  dev.set(devNum)
  retNum
}
devIsCur <- function(devNum)
{
  return( as.numeric(dev.cur())==devNum )
}
devIsNull <- function(devNum)
{
  return( length(which(devIndexNum()==devNum)) == 0 )
}
devIndexNum <- function()
{
  as.numeric(dev.list())
}
devLengthNum <- function()
{
  length(as.numeric(dev.list()))
}
