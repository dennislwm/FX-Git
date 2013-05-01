#|------------------------------------------------------------------------------------------|
#|                                                                          PlusMtrDevice.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  0.9.3   The R function capture.output(x) does NOT expect a string, therefore we do NOT  |
#|          enclose the parameter in quotes for function MtrDeviceEval0(). For example,     |
#|          capture.output(getwd()) is the correct syntax when used in MtrDeviceEval0().    |
#|          When we plot a graph, we do NOT use the function MtrDeviceEval0(), but instead, |
#|          first we call the function MtrDeviceSinkOn() and followed by MtrRx("plot(x)").  |
#|          Note that we do NOT need the function MtrDeviceSinkOff() when plotting a graph. |
#|  0.9.2   Added THREE (3) MtrAddInRdevicexxx() functions.                                 |
#|  0.9.1   Added THREE (3) high-level functions: MtrAddRdeviceTop(), MtrAddRdeviceInit(),  |
#|          MtrAddRdeviceDeinit(). These functions call MtrAddRTop(), MtrAddRInit() and     |
#|          MtrAddRDeinit() respectively. However, there are NO changes to MtrAddRStart(),  |
#|          hence there is NO associated function MtrAddRdeviceStart().                     |
#|          Removed parameter "name.str" from MtrDeviceWriterStr(), as its mandatory name   |
#|          is "mt4Rdevice". Todo: (a) test function "mt4RdeviceEval()" in MetaTrader.      |
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
MtrAddRdeviceTop <- function(nameStr, verStr, linkType, linkName, linkVal, extType, extName, extVal, 
                       Rpath='C:/Program Files/R/R-2.15.3/bin/i386/Rterm.exe')
{
  mt.list <- MtrAddTop(nameStr, verStr, linkType,linkName,linkVal,extType,extName,extVal)
  mt.list <- MtrAddInRdeviceTop(mt.list, Rpath)
  mt.list
}
MtrAddInRdeviceTop <- function(mt.list, Rpath='C:/Program Files/R/R-2.15.3/bin/i386/Rterm.exe')
{
  mt.list <- MtrAddInRTop(mt.list, Rpath)
  mt.list <- MtrAddInLink(mt.list,'include','<mt4Rdevice.mqh>','')
  mt.list <- MtrAddInExtern(mt.list,rep('bool',2),c('Rtext','Rplot'),rep('false',2))
  mt.list <- MtrAddInGvar(mt.list,rep('int',2),c('hText','hPlot'))
  mt.list  
}
MtrAddRdeviceInit <- function(bufNum, styleChr=NULL, drawBegin=NULL,
                              Rlibrary=NULL, Rsource=NULL, Rsourcedir=RegRSourceDir())
{
  mt.list   <- MtrAddInit(bufNum, styleChr, drawBegin)
  mt.list   <- MtrAddInRdeviceInit(mt.list, Rlibrary, Rsource, Rsourcedir)
  mt.list
}
MtrAddInRdeviceInit <- function(mt.list, Rlibrary=NULL, Rsource=NULL, Rsourcedir=RegRSourceDir())
{
  if( length(which(Rlibrary=='gplots'))==0 )
    Rlibrary <- c('gplots',Rlibrary)
  
  mt.list <- MtrAddInRInit(mt.list, Rlibrary, Rsource, Rsourcedir)
  ins.list  <- list(cs(2,MtrExecute0("options(device='windows')")),
                    cs(2,'hR=R;'),
                    cs(2,'if(','Rtext',')'),
                    cs(2,'{'),
                    cs(4,'hText=',MtrDeviceNew0()),
                    cs(4,'if(','hText==0',')'),
                    cs(4,'{'),
                    cs(6,'Print(',pasteq("hText failed: Ensure (a) gplots is installed (b) options() is set."),');'),
                    cs(6,'Rtext=false;'),
                    cs(4,'}','else'),
                    cs(6,MtrDeviceText0('hText','Initialized Rtext ...')),
                    cs(2,'}'),
                    cs(2,'if(','Rplot',')'),
                    cs(2,'{'),
                    cs(4,'hPlot=',MtrDeviceNew0()),
                    cs(4,'if(','hPlot==0',')'),
                    cs(4,'{'),
                    cs(6,'Print(',pasteq("hPlot failed: Ensure (a) gplots is installed (b) options() is set."),');'),
                    cs(6,'Rplot=false;'),
                    cs(4,'}','else'),
                    cs(6,MtrDeviceText0('hPlot','Initialized Rplot ...')),
                    cs(2,'}'))
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_init_end")-2 )
  mt.list
}
MtrAddRdeviceDeinit <- function()
{
  mt.list   <- MtrAddRDeinit()
  mt.list   <- MtrAddInRdeviceDeinit(mt.list)
  mt.list
}
MtrAddInRdeviceDeinit <- function(mt.list)
{
  mt.list   <- MtrAddInRDeinit(mt.list)
  ins.list  <- list(cs(2,'if(','hText>0',')',MtrDeviceOff0("hText")),
                    cs(2,'if(','hPlot>0',')',MtrDeviceOff0("hPlot")))
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_deinit_end")-3 )
  mt.list
}
MtrDeviceWriterStr <- function(save.dir=RegHomeDir())
{
  mt.list <- MtrAddLink('include', '<mt4R.mqh>', '')
  mt.list <- append( mt.list, MtrCVar(0,'int','RhUsedbySink') )
  mt.list <- append( mt.list, MtrAddRdeviceEval() )
  mt.list <- append( mt.list, MtrAddRdeviceText() )
  mt.list <- append( mt.list, MtrAddRdeviceSinkOff() )
  mt.list <- append( mt.list, MtrAddRdeviceSinkOn() )
  mt.list <- append( mt.list, MtrAddRdeviceNew() )
  mt.list <- append( mt.list, MtrAddRdeviceOff() )
  mt.list <- append( mt.list, MtrAddRdeviceSet() )
  mt.list <- append( mt.list, MtrAddRdeviceIsCur() )
  mt.list <- append( mt.list, MtrAddRdeviceIsNull() )
  mt.list <- append( mt.list, MtrAddRdeviceTotal() )
  MtrEaWriterStr("mt4Rdevice", mt.list, save.dir, ext.str=".mqh")
}

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   B   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrDeviceEval0      <- function(h,x)  c('mt4RdeviceEval(',h,',',pasteq(x),',0.8);')
MtrDeviceText0      <- function(h,x)  c('mt4RdeviceText(',h,',Rqs(',pasteq(x),'),0.8);')
MtrDeviceSinkOff    <- function(h)    c('mt4RdeviceSinkOff(',h,')')
MtrDeviceSinkOff0   <- function(h)    c('mt4RdeviceSinkOff(',h,');')
MtrDeviceSinkOn     <- function(h)    c('mt4RdeviceSinkOn(',h,')')
MtrDeviceSinkOn0    <- function(h)    c('mt4RdeviceSinkOn(',h,');')
MtrDeviceNew0       <- function()     c('mt4RdeviceNew();')
MtrDeviceOff0       <- function(h)    c('mt4RdeviceOff(',h,');')
MtrDeviceSet        <- function(h)    c('mt4RdeviceSet(',h,')')
MtrDeviceSet0       <- function(h)    c('mt4RdeviceSet(',h,');')
MtrDeviceIsCur      <- function(h)    c('mt4RdeviceIsCur(',h,')')
MtrDeviceIsNull     <- function(h)    c('mt4RdeviceIsNull(',h,')')
MtrDeviceTotal      <- function()     c('mt4RdeviceTotal()')
MtrDeviceTotal0     <- function()     c('mt4RdeviceTotal();')

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   A   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrAddRdeviceEval <- function()
{
  cmd <- paste0("textplot(capture.output(",pasteq("+retStr+"),"),halign='left',valign='top',cex=",pasteq("+cex+"),")")
  ret <- list(c('void','mt4RdeviceEval(','int','devInt,','string','exprStr,',
                'double','cex=0.9,','bool','quoteBln=FALSE',')'),
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