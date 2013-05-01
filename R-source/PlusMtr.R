#|------------------------------------------------------------------------------------------|
#|                                                                                PlusMtr.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  0.9.3   Added function MtrAv0() and parameter Rsourcedir in function MtrAddInRsource(). |
#|  0.9.2   Added function isNewBar() and added THREE (3) MtrAddInxxx() functions. Added    |
#|          optional "extName" parameter to functions MtrAddInModel() and MtrAddInResult(). |
#|  0.9.1   Added THREE (3) functions: MtrAddInGvar(), MtrAddInRsource(), MtrAddInRlibrary. |
#|          Added code markers "gvar", "Rsource", "Rlibrary" to the above respectively.     |
#|          Parameters "nameStr" and "verStr" has been moved to function MtrAddTop().       |
#|  0.9.0   This library contains external R functions to interact with MetaTrader 4.       |
#|          Note: The previous "PlusMtr.R" has been renamed to "PlusMtrGhost.R".            |
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

MtrAddRTop <- function(nameStr, verStr, linkType, linkName, linkVal, extType, extName, extVal, 
                       Rpath='C:/Program Files/R/R-2.15.3/bin/i386/Rterm.exe')
{
  mt.list <- MtrAddTop(nameStr, verStr, linkType,linkName,linkVal,extType,extName,extVal)
  mt.list <- MtrAddInRTop(mt.list, Rpath)
  mt.list
}
MtrAddInRTop <- function(mt.list, Rpath='C:/Program Files/R/R-2.15.3/bin/i386/Rterm.exe')
{
  mt.list <- MtrAddInLink(mt.list,'include','<mt4R.mqh>','')
  mt.list <- MtrAddInExtern(mt.list,'string','Rpath',pasteq(Rpath))
  mt.list <- MtrAddInGvar(mt.list,'int','R')
  mt.list <- MtrAddInGvar(mt.list,'int','nextBarTime')
  mt.list
}
MtrAddRInit <- function(bufNum, styleChr=NULL, drawBegin=NULL,
                        Rlibrary=NULL, Rsource=NULL, Rsourcedir=RegRSourceDir())
{
  mt.list <- MtrAddInit(bufNum, styleChr, drawBegin)
  mt.list <- MtrAddInRInit(mt.list, Rlibrary, Rsource, Rsourcedir)
  mt.list
}
MtrAddRStart <- function(extName=c('GdvPeriod','GdvLookBack','GdvAlpha'))
{
  mt.list   <- MtrAddStart()
  ins.list  <- MtrCVar(2, rep('double',2), c('hist[]','ret[]'))
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_start")+2 )
  ins.list  <- list(cs(2,'if(RIsBusy(R))','return(0);'))
  ins.list  <- append( ins.list, MtrAddInResult(extName) )
  ins.list  <- append( ins.list, list(cs(2,'if(','isNewBar()',')'),
                                      cs(2,'{'),
                                      cs(2,'}')) )
  ins.list  <- append( ins.list, MtrAddInModel(extName), after=length(ins.list)-1 )
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_start_end")-2 )  
  mt.list   <- append( mt.list, MtrAddNewBar(), after=w(mt.list,"_start_end") )
  mt.list
}
MtrAddInRStart <- function(mt.list,extName=c('GdvPeriod','GdvLookBack','GdvAlpha'))
{
  ins.list  <- MtrCVar(2, rep('double',2), c('hist[]','ret[]'))
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_start")+2 )
  ins.list  <- list(cs(2,'if(RIsBusy(R))','return(0);'))
  ins.list  <- append( ins.list, MtrAddInResult(extName) )
  ins.list  <- append( ins.list, MtrAddInModel(extName) )
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_start_end")-2 )  
  mt.list
}
MtrAddInModel <- function(extName=c('GdvPeriod','GdvLookBack','GdvAlpha'))
{
  #---  Check that arguments are valid
  stopStr <- AddMoreE(length(extName),3)
  if( !is.null(stopStr) ) stop(stopStr)
  
  #---  Knowledge about assigning an MT4 array (hist) to an R vector (hNum)
  #       (1) hist[0] is the current price, and hist[99] is the 100th period price
  #       (2) hNum[1] is the current price, and hNum[100] is the 100th period price
  #       (3) library(tseries) expects a vector to be sorted in chronological order,
  #           e.g. histNum[1] has the oldest period price, and histNum[length(histNum)]
  #           has the current price.
  cmd <- paste0("model <- rollapply(histNum,",pasteq(paste0("+",extName[1],"+")),
                ",function(x) as.numeric(lm(x ~ seq_along(x))$coeff[2]))*",
                pasteq(paste0("+",extName[3],"+"))," ")
  ret <- list(cs(4,'ArrayResize(hist,',extName[2],');'),
              cs(4,'for(i=',extName[2],'-1;i>=0;i--)'),
              cs(4,'{'),
              cs(6,'hist[i]','=','Close[i];'),
              cs(4,'}'),
              cs(4,MtrAssignVector0("hNum",',hist,ArraySize(hist)')),
              cs(4,MtrExecute0("hNum <- rev(hNum)")),
              cs(4,MtrExecute0("histNum <- c(hNum)")),
              cs(4,MtrExecuteAsync0(cmd)))
  names(ret)[1] <- "model"
  names(ret)[length(ret)] <- "model_end"
  
  return( ret )
}
MtrAddInResult <- function(extName=c('GdvPeriod','GdvLookBack','GdvAlpha'))
{
  #---  Check that arguments are valid
  stopStr <- AddMoreE(length(extName),3)
  if( !is.null(stopStr) ) stop(stopStr)
  
  cmd <- paste0("as.integer(exists(",pasteq0("model"),"))")
  ret <- list(cs(2,'int','len=',MtrGetInteger0("length(histNum)")),
              cs(2,'ArrayResize(ret,',extName[2],');'),
              cs(2,'if(',MtrGetInteger(cmd),'==1)'),
              cs(2,'{'),
              cs(4,'RGetVector(R,','StringConcatenate(',pasteq("rev(model)[1:"),
                 ',',extName[2],',',pasteq("]"),'),ret,',extName[2],');'),
              cs(4,'for(i=0;i<',extName[2],';i++)'),
              cs(4,'{'),
              cs(6,'ExtMapBuffer1[i]','=','ret[i];'),
              cs(4,'}'),
              cs(2,'}'))
  names(ret)[1] <- "result"
  names(ret)[length(ret)] <- "result_end"
  
  return( ret) 
}
MtrAddRDeinit <- function()
{
  mt.list   <- MtrAddDeinit()
  mt.list   <- MtrAddInRDeinit(mt.list)
  mt.list
}
MtrAddInRDeinit <- function(mt.list)
{
  ins.list  <- list(cs(2,'RDeinit(R);'))
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_deinit_end")-2 )
  mt.list
}
MtrAddInRInit <- function(mt.list, Rlibrary=NULL, Rsource=NULL, Rsourcedir=RegRSourceDir())
{
  if( length(which(Rlibrary=='zoo'))==0 )
    Rlibrary <- c('zoo',Rlibrary)
  
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMore(length(w(mt.list,"_init")),0)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMore(length(w(mt.list,"_init_end")),0)
  if( !is.null(stopStr) ) stop(stopStr)

  end <- list(cs(2,'string','Rterm','=','StringConcatenate(Rpath,',pasteq(" --no-save"),');'),
              cs(2,'R=Rinit(Rterm,2);'),
              cs(2,'if(','R==0',')'),
              cs(4,'Print(',pasteq("Rinit failed: Ensure (a) Rterm, and (b) mt4R is installed."),');'),
              cs(2,MtrExecute0("histNum <- numeric(0)")))
  if( !is.null(Rlibrary) )
  {
    for( i in seq_along(Rlibrary) )
      end <- append(end, list(cs(2,MtrExecute0(paste0("suppressPackageStartupMessages(library(",Rlibrary[i],"))")))))
    names(end)[length(end)] <- "Rlibrary"
  }
  if( !is.null(Rsource) )
  {
    for( i in seq_along(Rsource) )
      end <- append(end, list(cs(2,MtrExecute0(paste0("suppressPackageStartupMessages(source(paste0(",
                                                 pasteq0(Rsourcedir,Rsource[i]),"), echo=FALSE))")))))
    names(end)[length(end)] <- "Rsource"
  }
  
  mt.list   <- append( mt.list, end, after=w(mt.list,"_init_end")-2 )
  mt.list
}

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   D   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrAddInRlibrary <- function(mt.list, Rlibrary)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(Rlibrary)
  if( !is.null(stopStr) ) stop(stopStr)
  
  top <- mt.list
  names(top)[w(mt.list,"Rlibrary")] <- NA
  
  end <- list()
  for( i in seq_along(Rlibrary) )
    end <- append(end, list(cs(2,MtrExecute0(paste0("suppressPackageStartupMessages(library(",Rlibrary[i],"))")))))
  names(end)[length(end)] <- "Rlibrary"
  
  mt.list   <- append( top, end, after=w(mt.list,"Rlibrary") )  
  mt.list
}
MtrAddInRsource <- function(mt.list, Rsource, Rsourcedir=RegRSourceDir())
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(Rsource)
  if( !is.null(stopStr) ) stop(stopStr)
  
  top <- mt.list
  names(top)[w(mt.list,"Rsource")] <- NA
  
  end <- list()
  for( i in seq_along(Rsource) )
    end <- append(end, list(cs(2,MtrExecute0(paste0("suppressPackageStartupMessages(source(paste0(",
                                                    pasteq0(Rsourcedir,Rsource[i]),"), echo=FALSE))")))))
  names(end)[length(end)] <- "Rsource"
  
  mt.list   <- append( top, end, after=w(mt.list,"Rsource") )  
  mt.list
}
#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   C   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
w       <- function(x, pat)   which(names(x)==pat)
w1      <- function(x, open)  which(nchar(x[[open]])>0)
pasteq  <- function(...) paste0("\"",...,"\"")
pasteq0 <- function(...) paste0("\'",...,"\'")
cs      <- function(n,...) c(rep('',n), ...)
MtrExecute0         <- function(x,...) c('RExecute(R,',pasteq(x),...,');')
MtrExecuteAsync0    <- function(x,...) c('RExecuteAsync(R,',pasteq(x),...,');')
MtrGetBool          <- function(x,...) c('RGetBool(R,',pasteq(x),...,')')
MtrGetInteger       <- function(x,...) c('RGetInteger(R,',pasteq(x),...,')')
MtrGetInteger0      <- function(x,...) c('RGetInteger(R,',pasteq(x),...,');')
MtrGetVector0       <- function(x,...) c('RGetVector(R,',pasteq(x),...,');')
MtrAssignVector0    <- function(x,...) c('RAssignVector(R,',pasteq(x),...,');')
MtrGb   <- function(x,...) c('Rgb(',pasteq(x),...,')')
MtrGi   <- function(x,...) c('Rgi(',pasteq(x),...,')')
MtrGi0  <- function(x,...) c('Rgi(',pasteq(x),...,');')
MtrAv0  <- function(x,...) c('Rv(',pasteq(x),...,');')
MtrX    <- function(x,...) c('Rx(',pasteq(x),...,')')
MtrX0   <- function(x,...) c('Rx(',pasteq(x),...,');')

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   B   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrAddInLink <- function(mt.list, linkType, linkName, linkVal)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(linkType)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(linkType),length(linkName))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(linkType),length(linkVal))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMore(length(w(mt.list,"link")),0)
  if( !is.null(stopStr) ) stop(stopStr)
  
  top <- mt.list
  names(top)[w(mt.list,"link")] <- NA
  
  end <- list()
  for( i in seq_along(linkType) )
    end <- append(end, list(c(paste0('#',linkType[i]),linkName[i],linkVal[i])))
  names(end)[length(end)] <- "link"
  
  mt.list   <- append( top, end, after=w(mt.list,"link") )  
  mt.list
}
MtrAddInExtern <- function(mt.list, extType, extName, extVal)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(extType)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(extType),length(extName))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(extType),length(extVal))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMore(length(w(mt.list,"extern")),0)
  if( !is.null(stopStr) ) stop(stopStr)
  
  top <- mt.list
  names(top)[w(mt.list,"extern")] <- NA
  
  end <- list()
  for( i in seq_along(extType) )
    end <- append(end, list(c('extern',extType[i],extName[i],'=',paste0(extVal[i],';'))))
  names(end)[length(end)] <- "extern"
  
  mt.list   <- append( top, end, after=w(mt.list,"extern") )  
  mt.list
}
MtrAddInGvar <- function(mt.list, varType, varName)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(varType)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(varType),length(varName))
  if( !is.null(stopStr) ) stop(stopStr)
  
  top <- mt.list
  names(top)[w(mt.list,"gvar")] <- NA
  
  end <- list()
  for( i in seq_along(varType) )
    end <- append(end, list(c(varType[i],varName[i],';')))
  names(end)[length(end)] <- "gvar"
  
  mt.list   <- append( top, end, after=w(mt.list,"gvar") )  
  mt.list
}
MtrCVar <- function(indent, varType, varName)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(indent)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(varType)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(varType),length(varName))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddMoreE(indent,0)
  if( !is.null(stopStr) ) stop(stopStr)
  
  ret <- list()
  for( i in seq_along(varType) )
    ret <- append(ret, list(cs(indent,varType[i],varName[i],';')))
  ret
}
MtrEaWriterStr <- function(name.str, mt.list, save.dir=RegHomeDir(), ext.str=".mq4")
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(name.str)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddExistN(substr(save.dir,1,nchar(save.dir)-1))
  if( !is.null(stopStr) ) stop(stopStr)
  
  ea.str  <- paste0(name.str, ext.str)
  
  #---  Write data
  #       Write EACH node of the list as a line
  #       Separate the elements of EACH node with a space.
  fCon    <-file(paste0(save.dir,ea.str))
  writeLines(unlist(lapply(mt.list, paste, collapse=" ")), fCon)
  close(fCon)
  return( paste0(save.dir,ea.str) )
}
MtrWriterStr <- function(mt.list)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(mt.list)
  if( !is.null(stopStr) ) stop(stopStr)
  
  #---  Write data
  #       Write EACH node of the list as a line
  #       Separate the elements of EACH node with a space.
  unlist(lapply(mt.list, paste, collapse=" "))
}

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   A   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrAddStart <- function()
{
  top <- list(c('int','start()'),
              c('{'),
              cs(2,'int','i;'),
              cs(2,'int','unused_bars;'),
              cs(2,'int','used_bars=IndicatorCounted();'),
              c(''),
              cs(2,'if','(used_bars<0)','return(-1);'),
              cs(2,'if','(used_bars>0)','used_bars--;'),
              cs(2,'unused_bars=Bars-used_bars;'),
              c(''))
  names(top)[1] <- "_start"
  
  mid <- list(cs(2,'for(i=unused_bars-1;i>=0;i--)'),
              cs(2,'{'),
              cs(2,'}'))
  
  end <- list(cs(2,'return(0);'), 
              c('}'),
              c('//:::::::::::::::::::::::::::::::::::::::::::::'))
  names(end)[2] <- "_start_end"
  
  #ret <- append(top, mid)
  ret <- append(top, end)
  return( ret )
}
MtrAddNewBar <- function()
{
  top <- list(c('int','isNewBar()'),
              c('{'),
              cs(2,'if(','nextBarTime','==','Time[0]',')'),
              cs(4,'return(false);'),
              cs(2,'else'),
              cs(4,'nextBarTime','=','Time[0];'),
              cs(2,'return(true);'),
              c('}'))
  names(top)[1]           <- "_isNewBar"
  names(top)[length(top)] <- "_isNewBar_end"
  return( top )
}
MtrAddLink <- function(linkType, linkName, linkVal)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(linkType)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(linkType),length(linkName))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(linkType),length(linkVal))
  if( !is.null(stopStr) ) stop(stopStr)
  
  top <- list()
  for( i in seq_along(linkType) )
    top <- append(top, list(c(paste0('#',linkType[i]),linkName[i],linkVal[i])))
  names(top)[length(top)] <- "link"

  return( top )
}
MtrAddTop <- function(nameStr, verStr, linkType, linkName, linkVal, extType, extName, extVal)
{
  #---  Check that arguments are valid
  stopStr <- AddAvoidN(linkType)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(linkType),length(linkName))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(linkType),length(linkVal))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddAvoidN(extType)
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(extType),length(extName))
  if( !is.null(stopStr) ) stop(stopStr)
  stopStr <- AddEqual(length(extType),length(extVal))
  if( !is.null(stopStr) ) stop(stopStr)
  
  top <- list(c('//:::::::::::::::::::::::::::::::::::::::::::::'))
  for( i in seq_along(linkType) )
    top <- append(top, list(c(paste0('#',linkType[i]),linkName[i],linkVal[i])))
  names(top)[length(top)] <- "link"
  
  mid <- list()
  for( i in seq_along(extType) )
    mid <- append(mid, list(c('extern',extType[i],extName[i],'=',paste0(extVal[i],';'))))
  names(mid)[length(mid)] <- "extern"
  
  end <- list(c('//:::::::::::::::::::::::::::::::::::::::::::::'),
              c('string','IndName=',paste0('\"',nameStr,'\";')),
              c('string','IndVer=',paste0('\"',verStr,'\";')))
  names(end)[length(end)] <- "gvar"
  
  ret <- append(top, mid)
  ret <- append(ret, end)
  return( ret )
}
MtrAddInit <- function(bufNum, styleChr=NULL, drawBegin=NULL)
{
  if( is.null(styleChr) )
    styleChr  <- rep( 'DRAW_LINE', bufNum )
  if( is.null(drawBegin) )
    drawBegin <- rep( 0, bufNum )
  
  top <- list(c('//:::::::::::::::::::::::::::::::::::::::::::::'))
  for( i in 1:bufNum )
    top <- append(top, list(c('double',paste0('ExtMapBuffer',i,'[];'))))
  
  mid <- list(c('int','init()'),
              c('{'),
              cs(2,paste0('IndicatorBuffers(',bufNum,');')),
              cs(2,'IndicatorDigits(Digits+10);'),
              cs(2,'IndicatorShortName(StringConcatenate(IndName," ",IndVer));'))
  names(mid)[1] <- "_init"
  
  for( i in 1:bufNum )
    mid <- append(mid, list(cs(2,'SetIndexStyle(',i-1,',',styleChr[i],');')))
  for( i in 1:bufNum )
    mid <- append(mid, list(cs(2,'SetIndexDrawBegin(',i-1,',',drawBegin[i],');')))
  for( i in 1:bufNum )
    mid <- append(mid, list(cs(2,'SetIndexBuffer(',i-1,',',paste0('ExtMapBuffer',i),');')))
  
  end <- list(cs(2,'return(0);'), 
              c('}'),
              c('//:::::::::::::::::::::::::::::::::::::::::::::'))
  names(end)[2] <- "_init_end"
  
  ret <- append(top, mid)
  ret <- append(ret, end)
  
  return( ret )
}
MtrAddDeinit <- function()
{
  ret <- list(c('//:::::::::::::::::::::::::::::::::::::::::::::'),
              c('int','deinit()'),
              c('{'),
              cs(2,'return(0);'), 
              c('}'),
              c('//:::::::::::::::::::::::::::::::::::::::::::::'))
  names(ret)[2] <- "_deinit"
  names(ret)[5] <- "_deinit_end"
  
  return( ret )
}
#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|