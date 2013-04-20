#|------------------------------------------------------------------------------------------|
#|                                                                    Balch_06_bband_QSTK.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Background                                                                               |
#|    The data for this R script comes from QTSK. We use the adjusted close prices. As the  |
#|  R script may NOT be able to access the data, we should use Python to download the data  |
#|  and export it to a CSV file.                                                            |
#|                                                                                          |
#| Motivation                                                                               |
#|  (1) Coursera's "Computational Investing" (CI) course taught students to use a Python    |
#|      framework for ALL their homeworks. However, it appears that these homeworks could   |
#|      be performed using R, which is NOT supported by the lecturer Tucker Balch.          |
#|  (2) The package "PlusBullet" can be used to perform portfolio analysis, and ANY ideas   |
#|      taken from the course can be used to extend the functionality of this package.      |
#|                                                                                          |
#| Homework                                                                                 |
#|    In this homework you will investigate technical indicators. We will start with        |
#|  Bollinger Bands but we hope you will implement others as well.                          |
#|                                                                                          |
#|    A.  Implement Bollinger bands as an indicator using TWENTY(20)-day look back. Create  |
#|      code that generates a chart showing the rolling mean, the stock price, and upper    |
#|      and lower bands. The upper band should represent the mean plus ONE (1) standard     |
#|      deviation and here the lower band is the mean minus ONE (1) standard deviation.     |
#|      Traditionally the upper and lower Bollinger bands are TWO (2) standard deviations   |
#|      but for this assignment we would use a tighter band of ONE (1) OR a single standard |
#|      deviation.                                                                          |
#|                                                                                          |
#|    B.  Have your code output the indicator value in a range of -ONE(1) to ONE(1). Yes,   |
#|      those values can be exceeded, but the intent is that +ONE(1) represents the         |
#|      situation where the price is at +ONE(1) standard deviations ABOVE the mean. To      |
#|      convert the present value of Bollinger bands into -ONE(1) to ONE(1):                |
#|                                                                                          |
#|        > Bollinger_val = (price - rolling_mean) / (rolling_std)                          |
#|                                                                                          |
#|      Then create a plot for the timeframe between Jan 1, 2010 to Dec 31,2010 for Google. |
#|                                                                                          |
#|        Symbol: GOOG                                                                      |
#|        Startdate: 1 Jan 2010                                                             |
#|        Enddate: 31 Dec 2010                                                              |
#|        20 period lookback                                                                |
#|                                                                                          |
#|      Output for 4 equities, using pandas to calculate bollinger band values.             |
#|                                                                                          |
#|                             AAPL      GOOG       IBM      MSFT                           |
#|        2010-12-23 16:00:00  1.185009  1.298178  1.177220  1.237684                       |
#|        2010-12-27 16:00:00  1.371298  1.073603  0.590403  0.932911                       |
#|        2010-12-28 16:00:00  1.436278  0.745548  0.863406  0.812844                       |
#|        2010-12-29 16:00:00  1.464894  0.874885  2.096242  0.752602                       |
#|        2010-12-30 16:00:00  0.793493  0.634661  1.959324  0.498395                       |
#|                                                                                          |
#| Example                                                                                  |
#|    A.  > bbroll.list <- tutorialXts("GOOG")                                              |
#|        > plot(bbroll.list)                                                               |
#|                                                                                          |
#| History                                                                                  |
#|  0.9.0   Coursera's "Computational Investing" course (Tucker Balch) Quiz 7 Week 7.       |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)
library(quantmod)
library(PerformanceAnalytics)
library(R.utils)

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
tutorialXts <- function(symChr, startChr="2010-01-01", finishChr="2010-12-30", width=20)
{
  priceXts  <- QstkReadXts(symChr, startChr, finishChr)
  retXts    <- rollapply(priceXts, width, FUN=function(x) { (x[length(x)]-mean(x))/sd(x) } )
  ret.list  <- list("symChr"   = symChr,
                    "startChr" = startChr,
                    "finishChr"= finishChr,
                    "width"    = width,
                    "priceXts" = priceXts,
                    "bandXts"  = retXts)
  
  class(ret.list)   <- "BBRoll"
  ret.list
}

plot.BBRoll <- function(x)
{
  chartSeries(x$bandXts)
}
#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
QstkReadXts <- function(symChr, startDate, finishDate, priceChr="Adjusted", qstkDir="C:/Python27/Lib/site-packages/QSTK/QSData/Yahoo/")
{
  plt.first.date <- as.Date(startDate, format="%Y-%m-%d")
  plt.last.date <- as.Date(finishDate, format="%Y-%m-%d")
  cv.date.range <- paste(plt.first.date, "::", plt.last.date, sep="")
  
  # Specify character vector for stock names.
  cv.names <- symChr
  
  # Assign source and date format details for all symbols in cv.names.
  for(i in index(cv.names))
  {
    eval(parse(text=paste("setSymbolLookup(",
                          cv.names[i],
                          "=list(src='csv',format='%Y-%m-%d'))")
    )
    )
  }
  # Load symbols.
  for(symbol in cv.names)
  {
    getSymbols(symbol, dir=qstkDir)
  }
  
  cv.names <- sort(cv.names)
  # Merge the adjusted close prices for all the symbols in the portfolio. This loop accomodates any
  # number of symbols and any symbol names. The loop creates a string for the merge command with all
  # its arguments filled in. This string is then passed to the "eval(parse())" combination for
  # execution.
  for(i in index(cv.names))
  {
    if(i == 1){st.merge <- paste(cv.names[i], "[,", "'", cv.names[i], ".", priceChr, "']", sep="")} else
    {st.merge <- paste(st.merge, paste(cv.names[i], "[,", "'", cv.names[i], ".", priceChr, "']", sep=""),
                       sep=",")}
    
  }
  xts.port <- eval(parse(text=paste("merge(", st.merge, ")", sep="")))
  # Truncate the data to the specified range.
  xts.port <- xts.port[cv.date.range,]
  names(xts.port) <- cv.names
  xts.port
}
#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|