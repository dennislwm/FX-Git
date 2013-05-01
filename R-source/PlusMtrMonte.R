#|------------------------------------------------------------------------------------------|
#|                                                                           PlusMtrMonte.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  0.9.0   This library contains external R functions for an include file  "mt4Rmonte.mqh".|
#|------------------------------------------------------------------------------------------|
if( Sys.info()["sysname"] == "Linux" )
  suppressPackageStartupMessages(source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
if( Sys.info()["sysname"] == "Windows" )
  suppressPackageStartupMessages(source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE))
suppressPackageStartupMessages(source(paste0(RegRSourceDir(),"PlusMtrDevice.R"), echo=FALSE))

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   C   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrAddInRmonte <- function(mt.list)
{
  mt.list <- MtrAddInLink(mt.list,'include','<mt4Rmonte.mqh>','')
  mt.list <- MtrAddInExtern(mt.list,c('double','int','int'),
                            c('MonteBalance','MonteSim','MonteWidth'),c('1000.0','100','1'))
  
  var.list  <- MtrCVar(2,c('int','int','int','double'),
                       c('total','count=0','j=0','profit[]'))
  ins.list  <- list(cs(2,'total','=','OrdersHistoryTotal();'),
                    cs(2,'for(i=0;i<total;i++)'),
                    cs(2,'{'),
                    cs(4,'if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true)'),
                    cs(6,'if(OrderType()<=OP_SELL)','count++;'),
                    cs(2,'}'),
                    c(''),
                    cs(2,'ArrayResize(profit,count);'),
                    cs(2,'for(i=0;i<total;i++)'),
                    cs(2,'{'),
                    cs(4,'if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true)'),
                    cs(6,'if(OrderType()<=OP_SELL)'),
                    cs(6,'{'),
                    cs(8,'profit[i]=','OrderProfit();'),
                    cs(8,'j++;'),
                    cs(6,'}'),
                    cs(2,'}'),
                    cs(2,'if(total>1)'),
                    cs(2,'{'),
                    cs(4,MtrMonteCalcReturns0('profit','MonteBalance')),
                    cs(4,MtrMonteGrowReturns0('MonteSim','MonteWidth','MonteBalance')),
                    cs(4,'if(hText>0)'),
                    cs(4,'{'),
                    cs(6,MtrDeviceSinkOn0('hText')),
                    cs(6,MtrX0("str(monteTradeSummary(pftNum))")),
                    cs(6,MtrX0("summary(monte)")),
                    cs(6,MtrDeviceSinkOff0('hText')),
                    cs(4,'}'),
                    cs(4,'if(hPlot>0)'),
                    cs(4,'{'),
                    cs(6,MtrDeviceSinkOn0('hPlot')),
                    cs(6,MtrX0("plot(monte)")),
                    cs(4,'}'),
                    cs(2,'}'))
  mt.list   <- append( mt.list, var.list, after=w(mt.list,"_start")+1 )
  mt.list   <- append( mt.list, ins.list, after=w(mt.list,"_start_end")-3 )
  mt.list
}
MtrMonteWriterStr <- function(save.dir=RegHomeDir())
{
  mt.list <- MtrAddLink('include', '<mt4Rdevice.mqh>', '')
  mt.list <- append( mt.list, MtrAddRmonteCalcReturns() )
  mt.list <- append( mt.list, MtrAddRmonteGrowReturns() )
  MtrEaWriterStr("mt4Rmonte", mt.list, save.dir, ext.str=".mqh")
}

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   B   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrMonteCalcReturns0  <- function(pft,bal)    c('mt4RmonteCalcReturns(',pft,',',bal,');')
MtrMonteGrowReturns0  <- function(n,w,bal)    c('mt4RmonteGrowReturns(',n,',',w,',',bal,');')

#|------------------------------------------------------------------------------------------|
#|                        E X T E R N A L   A   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MtrAddRmonteCalcReturns <- function()
{
  cmd <- paste0("retZoo <- monteCalcReturnsZoo(pftNum,",pasteq("+bal+"),")")
  ret <- list(c('void','mt4RmonteCalcReturns(','double','pft[],','double','bal',')'),
              c('{'),
              cs(2,MtrAv0("pftNum",',pft')),
              cs(2,MtrX0(cmd)),
              c('}'))
  return( ret )
}
MtrAddRmonteGrowReturns <- function()
{
  bln <- paste0("as.integer(exists(",pasteq0("retZoo"),"))")
  cmd <- paste0("monte <- MonteGrowReturns(retZoo,",pasteq("+n+"),",",pasteq("+w+"),",",
                pasteq("+bal+"),")")
  ret <- list(c('void','mt4RmonteGrowReturns(','int','n,','int','w,','int','bal',')'),
              c('{'),
              cs(2,'if(',MtrGi(bln),'==1)'),
              cs(4,MtrX0(cmd)),
              c('}'))
  return( ret )
}
#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|