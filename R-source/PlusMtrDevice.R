#|------------------------------------------------------------------------------------------|
#|                                                                          PlusMtrDevice.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  0.9.0   This library contains external R functions for an include file "mt4Rdevice.mqh".|
#|------------------------------------------------------------------------------------------|
if( Sys.info()["sysname"] == "Linux" )
  suppressPackageStartupMessages(source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
if( Sys.info()["sysname"] == "Windows" )
  suppressPackageStartupMessages(source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
suppressPackageStartupMessages(source(paste0(RegRSourceDir(),"PlusMtr.R"), echo=FALSE))

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   C   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrDeviceWriterStr <- function(name.str, save.dir=RegHomeDir())
{
  mt.list <- MtrAddLink('include', '<mt4R.mqh>', '')
  mt.list <- append( mt.list, MtrCVar(0,'int','RhUsedbySink') )
  mt.list <- append( mt.list, MtrAddRdeviceExpr() )
  mt.list <- append( mt.list, MtrAddRdeviceText() )
  mt.list <- append( mt.list, MtrAddRdeviceSinkOff() )
  mt.list <- append( mt.list, MtrAddRdeviceSinkOn() )
  mt.list <- append( mt.list, MtrAddRdeviceNew() )
  mt.list <- append( mt.list, MtrAddRdeviceOff() )
  mt.list <- append( mt.list, MtrAddRdeviceSet() )
  mt.list <- append( mt.list, MtrAddRdeviceIsCur() )
  mt.list <- append( mt.list, MtrAddRdeviceIsNull() )
  mt.list <- append( mt.list, MtrAddRdeviceTotal() )
  MtrEaWriterStr(name.str, mt.list, save.dir, ext.str=".mqh")
}

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   B   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrDeviceSinkOff    <- function(x)  c('mt4RdeviceSinkOff(',x,')')
MtrDeviceSinkOn     <- function(x)  c('mt4RdeviceSinkOn(',x,')')
MtrDeviceNew        <- function()   c('mt4RdeviceNew()')
MtrDeviceOff        <- function(x)  c('mt4RdeviceOff(',x,')')
MtrDeviceSet        <- function(x)  c('mt4RdeviceSet(',x,')')
MtrDeviceSet0       <- function(x)  c('mt4RdeviceSet(',x,');')
MtrDeviceIsCur      <- function(x)  c('mt4RdeviceIsCur(',x,')')
MtrDeviceIsNull     <- function(x)  c('mt4RdeviceIsNull(',x,')')
MtrDeviceTotal      <- function()   c('mt4RdeviceTotal()')
MtrDeviceTotal0     <- function()   c('mt4RdeviceTotal();')

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   A   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrAddRdeviceExpr <- function()
{
  cmd <- paste0("textplot(capture.output(",pasteq("+retStr+"),"),halign='left',valign='top',cex=",pasteq("+cex+"),")")
  ret <- list(c('void','mt4RdeviceExpr(','int','devInt,','string','exprStr,',
                'double','cex=0.9,','bool','quoteBln=TRUE',')'),
              c('{'),
              cs(2,'string','retStr=exprStr;'),
              cs(2,'if(',MtrDeviceIsNull("devInt"),')','return(0);'),
              cs(2,'int','hInt=',MtrDeviceSet0("devInt")),
              cs(2,'if(','quoteBln',')'),
              cs(2,'{'),
              cs(4,'string','Tlq=','StringSubstr(exprStr,1,1);'),
              cs(4,'if(','StringFind(','Tlq,',pasteq('\\\"'),')==0',
                 '||','StringFind(','Tlq,',pasteq("'"),')==0',')'),
              cs(6,'retStr=','Rqd(',pasteq("Error: exprStr MUST be enclosed in quotes."),');'),
              cs(2,'}'),
              cs(2,MtrX0(cmd)),
              cs(2,'if(','hInt!=devInt',')',MtrDeviceSet0("hInt")),
              c('}'))
  return( ret )
}
MtrAddRdeviceText <- function()
{
  cmd <- paste0("textplot(",pasteq("+retStr+"),",halign='left',valign='top',cex=",pasteq("+cex+"),")")
  ret <- list(c('void','mt4RdeviceText(','int','devInt,','string','textStr,',
                'double','cex=0.9,','bool','quoteBln=TRUE',')'),
              c('{'),
              cs(2,'string','retStr=textStr;'),
              cs(2,'if(',MtrDeviceIsNull("devInt"),')','return(0);'),
              cs(2,'int','hInt=',MtrDeviceSet0("devInt")),
              cs(2,'if(','quoteBln',')'),
              cs(2,'{'),
              cs(4,'string','Tlq=','StringSubstr(textStr,1,1);'),
              cs(4,'if(','StringFind(','Tlq,',pasteq('\\\"'),')==0',
                 '||','StringFind(','Tlq,',pasteq("'"),')==0',')'),
              cs(6,'retStr=','Rqd(',pasteq("Error: textStr MUST be enclosed in quotes."),');'),
              cs(2,'}'),
              cs(2,MtrX0(cmd)),
              cs(2,'if(','hInt!=devInt',')',MtrDeviceSet0("hInt")),
              c('}'))
  return( ret )
}
MtrAddRdeviceSinkOff <- function()
{
  cmd <- paste0("sinkplot(c('plot'),halign='left',valign='top',cex=",pasteq("+cex+"),")")
  ret <- list(c('void','mt4RdeviceSinkOff(','int','devInt,','double','cex=0.9',')'),
              c('{'),
              cs(2,'if(',MtrDeviceIsNull("devInt"),')','return(0);'),
              cs(2,MtrX0(cmd)),
              cs(2,'if(','RhUsedbySink!=devInt',')',MtrDeviceSet0("RhUsedbySink")),
              c('}'))
  return( ret )
}
MtrAddRdeviceSinkOn <- function()
{
  ret <- list(c('void','mt4RdeviceSinkOn(','int','devInt',')'),
              c('{'),
              cs(2,'if(',MtrDeviceIsNull("devInt"),')','return(0);'),
              cs(2,'RhUsedbySink=',MtrDeviceSet0("devInt")),
              cs(2,MtrX0(paste0("sinkplot(c(",pasteq0("start"),"))"))),
              c('}'))
  return( ret )
}
MtrAddRdeviceNew <- function()
{
  ret <- list(c('int','mt4RdeviceNew()'),
              c('{'),
              cs(2,'int','bgn=',MtrDeviceTotal0()),
              cs(2,MtrX0("dev.new('windows')")),
              cs(2,'int','end=',MtrDeviceTotal0()),
              cs(2,'if(','end==bgn',')'),
              cs(4,'return(0);'),
              cs(2,'else'),
              cs(4,'return(',MtrGi("as.numeric(dev.cur())"),');'),
              c('}'))
  return( ret )
}
MtrAddRdeviceOff <- function()
{
  cmd <- paste0("dev.off(",pasteq("+devInt+"),")")
  ret <- list(c('bool','mt4RdeviceOff(','int','devInt',')'),
              c('{'),
              cs(2,'if(',MtrDeviceIsNull("devInt"),')','return(false);'),
              cs(2,MtrX0(cmd)),
              cs(2,'return(true);'),
              c('}'))
  return( ret )
}
MtrAddRdeviceSet <- function()
{
  cmd <- paste0("dev.set(",pasteq("+devInt+"),")")
  ret <- list(c('bool','mt4RdeviceSet(','int','devInt',')'),
              c('{'),
              cs(2,'if(',MtrDeviceIsNull("devInt"),')','return(0);'),
              cs(2,'if(',MtrDeviceIsCur("devInt"),')','return(devInt);'),
              cs(2,'int','retInt=',MtrGi0("as.numeric(dev.cur())")),
              cs(2,MtrX0(cmd)),
              cs(2,'return(retInt);'),
              c('}'))
  return( ret )
}
MtrAddRdeviceIsCur <- function()
{
  ret <- list(c('bool','mt4RdeviceIsCur(','int','devInt',')'),
              c('{'),
              cs(2,'return(',MtrGb("as.numeric(dev.cur())==","+devInt"),');'),
              c('}'))
  return( ret )
}
MtrAddRdeviceIsNull <- function()
{
  cmd <- paste0("length(which(as.numeric(dev.list())==",pasteq("+devInt+"),")) == 0")
  ret <- list(c('bool','mt4RdeviceIsNull(','int','devInt',')'),
              c('{'),
              cs(2,'return(',MtrGb(cmd),');'),
              c('}'))
  return( ret )
  
}
MtrAddRdeviceTotal  <- function()
{
  ret <- list(c('int','mt4RdeviceTotal()'),
              c('{'),
              cs(2,'return(',MtrGi("length(as.numeric(dev.list()))"),');'),
              c('}'))
  
  return( ret )
}
#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|