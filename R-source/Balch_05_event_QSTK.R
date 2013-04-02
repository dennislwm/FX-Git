#|------------------------------------------------------------------------------------------|
#|                                                                    Balch_05_event_QSTK.R |
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
#|    In this Homework THREE (3) you will create a basic market simulator that accepts      |
#|  trading orders and keeps track of a portfolio's value and saves it to a file. You will  |
#|  also create another program that assesses the performance of that portfolio.            |
#|                                                                                          |
#|    A.  Create a market simulation tool, marketsim.py that takes a command line like this |
#|                                                                                          |
#|    B.  Create a portfolio analysis tool, analyze.py, that takes a command line like this | 
#|                                                                                          |
#| Example                                                                                  |
#|    A.  > valueXts  <- PyMarketSimXts(1000000, "Balch_04_backtest_orders")                |
#|                                                                                          |
#|  0.9.0   Coursera's "Computational Investing" course (Tucker Balch) Quiz 6 Week 6.       |
#|          Todo: Function eventProfiler() and Homework 4.                                  |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)
library(quantmod)
library(PerformanceAnalytics)
library(R.utils)

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
tutorial <- function()
{
  startChr  <- "2008-01-01"
  finishChr <- "2009-12-31"
#---  (2) Use a smaller subset of symbols to validate function fill.na()
  #symChr    <- c('A', 'AA', 'AAPL', 'ABC', 'ABT', 'ACE', 'ACN', 'ADBE', 'ADI', 'ADM', 'ADP', 'ADSK', 'AEE', 'AEP', 'AES', 'AET', 'AFL', 'AGN', 'AIG', 'AIV', 'AIZ', 'AKAM', 'ALL', 'ALTR', 'ALXN', 'AMAT', 'AMD', 'AMGN', 'AMP', 'AMT', 'AMZN', 'AN', 'ANF', 'ANR', 'AON', 'APA', 'APC', 'APD', 'APH', 'APOL', 'ARG', 'ATI', 'AVB', 'AVP', 'AVY', 'AXP', 'AZO', 'BA', 'BAC', 'BAX', 'BBBY', 'BBT', 'BBY', 'BCR', 'BDX', 'BEAM', 'BEN', 'BF.B', 'BHI', 'BIG', 'BIIB', 'BK', 'BLK', 'BLL', 'BMC', 'BMS', 'BMY', 'BRCM', 'BRK.B', 'BSX', 'BTU', 'BWA', 'BXP', 'C', 'CA', 'CAG', 'CAH', 'CAM', 'CAT', 'CB', 'CBE', 'CBG', 'CBS', 'CCE', 'CCI', 'CCL', 'CELG', 'CERN', 'CF', 'CFN', 'CHK', 'CHRW', 'CI', 'CINF', 'CL', 'CLF', 'CLX', 'CMA', 'CMCSA', 'CME', 'CMG', 'CMI', 'CMS', 'CNP', 'CNX', 'COF', 'COG', 'COH', 'COL', 'COP', 'COST', 'COV', 'CPB', 'CRM', 'CSC', 'CSCO', 'CSX', 'CTAS', 'CTL', 'CTSH', 'CTXS', 'CVC', 'CVH', 'CVS', 'CVX', 'D', 'DD', 'DE', 'DELL', 'DF', 'DFS', 'DGX', 'DHI', 'DHR', 'DIS', 'DISCA', 'DLTR', 'DNB', 'DNR', 'DO', 'DOV', 'DOW', 'DPS', 'DRI', 'DTE', 'DTV', 'DUK', 'DV', 'DVA', 'DVN', 'EA', 'EBAY', 'ECL', 'ED', 'EFX', 'EIX', 'EL', 'EMC', 'EMN', 'EMR', 'EOG', 'EQR', 'EQT', 'ESRX', 'ESV', 'ETFC', 'ETN', 'ETR', 'EW', 'EXC', 'EXPD', 'EXPE', 'F', 'FAST', 'FCX', 'FDO', 'FDX', 'FE', 'FFIV', 'FHN', 'FII', 'FIS', 'FISV', 'FITB', 'FLIR', 'FLR', 'FLS', 'FMC', 'FOSL', 'FRX', 'FSLR', 'FTI', 'FTR', 'GAS', 'GCI', 'GD', 'GE', 'GILD', 'GIS', 'GLW', 'GME', 'GNW', 'GOOG', 'GPC', 'GPS', 'GS', 'GT', 'GWW', 'HAL', 'HAR', 'HAS', 'HBAN', 'HCBK', 'HCN', 'HCP', 'HD', 'HES', 'HIG', 'HNZ', 'HOG', 'HON', 'HOT', 'HP', 'HPQ', 'HRB', 'HRL', 'HRS', 'HSP', 'HST', 'HSY', 'HUM', 'IBM', 'ICE', 'IFF', 'IGT', 'INTC', 'INTU', 'IP', 'IPG', 'IR', 'IRM', 'ISRG', 'ITW', 'IVZ', 'JBL', 'JCI', 'JCP', 'JDSU', 'JEC', 'JNJ', 'JNPR', 'JOY', 'JPM', 'JWN', 'K', 'KEY', 'KFT', 'KIM', 'KLAC', 'KMB', 'KMI', 'KMX', 'KO', 'KR', 'KSS', 'L', 'LEG', 'LEN', 'LH', 'LIFE', 'LLL', 'LLTC', 'LLY', 'LM', 'LMT', 'LNC', 'LO', 'LOW', 'LRCX', 'LSI', 'LTD', 'LUK', 'LUV', 'LXK', 'LYB', 'M', 'MA', 'MAR', 'MAS', 'MAT', 'MCD', 'MCHP', 'MCK', 'MCO', 'MDT', 'MET', 'MHP', 'MJN', 'MKC', 'MMC', 'MMM', 'MNST', 'MO', 'MOLX', 'MON', 'MOS', 'MPC', 'MRK', 'MRO', 'MS', 'MSFT', 'MSI', 'MTB', 'MU', 'MUR', 'MWV', 'MYL', 'NBL', 'NBR', 'NDAQ', 'NE', 'NEE', 'NEM', 'NFLX', 'NFX', 'NI', 'NKE', 'NOC', 'NOV', 'NRG', 'NSC', 'NTAP', 'NTRS', 'NU', 'NUE', 'NVDA', 'NWL', 'NWSA', 'NYX', 'OI', 'OKE', 'OMC', 'ORCL', 'ORLY', 'OXY', 'PAYX', 'PBCT', 'PBI', 'PCAR', 'PCG', 'PCL', 'PCLN', 'PCP', 'PCS', 'PDCO', 'PEG', 'PEP', 'PFE', 'PFG', 'PG', 'PGR', 'PH', 'PHM', 'PKI', 'PLD', 'PLL', 'PM', 'PNC', 'PNW', 'POM', 'PPG', 'PPL', 'PRGO', 'PRU', 'PSA', 'PSX', 'PWR', 'PX', 'PXD', 'QCOM', 'QEP', 'R', 'RAI', 'RDC', 'RF', 'RHI', 'RHT', 'RL', 'ROK', 'ROP', 'ROST', 'RRC', 'RRD', 'RSG', 'RTN', 'S', 'SAI', 'SBUX', 'SCG', 'SCHW', 'SE', 'SEE', 'SHLD', 'SHW', 'SIAL', 'SJM', 'SLB', 'SLM', 'SNA', 'SNDK', 'SNI', 'SO', 'SPG', 'SPLS', 'SRCL', 'SRE', 'STI', 'STJ', 'STT', 'STX', 'STZ', 'SUN', 'SWK', 'SWN', 'SWY', 'SYK', 'SYMC', 'SYY', 'T', 'TAP', 'TDC', 'TE', 'TEG', 'TEL', 'TER', 'TGT', 'THC', 'TIE', 'TIF', 'TJX', 'TMK', 'TMO', 'TRIP', 'TROW', 'TRV', 'TSN', 'TSO', 'TSS', 'TWC', 'TWX', 'TXN', 'TXT', 'TYC', 'UNH', 'UNM', 'UNP', 'UPS', 'URBN', 'USB', 'UTX', 'V', 'VAR', 'VFC', 'VIAB', 'VLO', 'VMC', 'VNO', 'VRSN', 'VTR', 'VZ', 'WAG', 'WAT', 'WDC', 'WEC', 'WFC', 'WFM', 'WHR', 'WIN', 'WLP', 'WM', 'WMB', 'WMT', 'WPI', 'WPO', 'WPX', 'WU', 'WY', 'WYN', 'WYNN', 'X', 'XEL', 'XL', 'XLNX', 'XOM', 'XRAY', 'XRX', 'XYL', 'YHOO', 'YUM', 'ZION', 'ZMH', 'SPY')
  symChr    <- c('A', 'SNI', 'SPY')
  
  priceXts  <- QstkReadXts(symChr, startChr, finishChr)
  priceXts  <- fill.na(priceXts, method='ffill')
  priceXts  <- fill.na(priceXts, method='bfill')
  
  actualXts <- QstkReadXts(symChr, startChr, finishChr, priceChr='Close')
  actualXts <- fill.na(actualXts, method='ffill')
  actualXts <- fill.na(actualXts, method='bfill')
  
  eventXts  <- findEvents(symChr, actualXts) 
}

findEvents <- function(symChr, priceXts, mktChr="SPY")
{
  eventXts <- priceXts
  for( iCol in 1:ncol(eventXts) )
    eventXts[, iCol] <- FALSE
  eventXts
  
  for( iSym in 1:ncol(priceXts) )
  {
    for( jRow in 2:nrow(priceXts) )
    {
      today.sym <- as.numeric(priceXts[jRow, iSym])
      ysday.sym <- as.numeric(priceXts[jRow-1, iSym])
      today.mkt <- as.numeric(priceXts[jRow, mktChr])
      ysday.mkt <- as.numeric(priceXts[jRow-1, mktChr])
      daily.sym <- (today.sym/ysday.sym) - 1
      daily.mkt <- (today.mkt/ysday.mkt) - 1
      
      if( daily.sym <= -0.03 & daily.mkt >= 0.02 )
        eventXts[jRow, iSym] <- TRUE
    }
  }
  # eventXts[, -which(names(eventXts)==mktChr)]
  eventXts
}

eventProfiler <- function(event, data, lookBack=20, lookForward=20, fileStr="study", 
                          marketNeutralBln=TRUE, errorBarBln=TRUE, marketSymChr="SPY")
{
  #---  df_close = d_data['close'].copy()
  #       (1) df_close is a data frame with rows as "adjusted" close, and cols as "symbols",
  #           e.g. df_close.columns: "[... YHOO, YUM, ZION, ZMH, SPY]"
  #       (2) df_close.values: "[... 12.73, 59.42, 107.5]"
  
  #---  df_rets = df_close.copy()
  #     tsu.returnize0(df_rets.values)
  #       (1) df_rets.values (before): "[... 12.73, 59.42, 107.5]"
  #       (2) df_rets.values (after):  "[... 0.00394322, -0.00701872, -0.00037195]"
  
  #---  if b_market_neutral == TRUE:
  #       df_rets = df_rets - df_rets['SPY']
  #         (1) df_rets.values (before): "[... 0.00394322, -0.00701872, -0.00037195]"
  #         (2) df_rets.values (after):  "[... 0.00431517, -0.00664676,  0]"
  #       del df_rets['SPY']
  #         (3) df_rets.columns (before): "[... YHOO, YUM, ZION, ZMH, SPY]"
  #         (4) df_rets.columns (after):  "[... YHOO, YUM, ZION, ZMH]"
  #       del df_events['SPY']
  #         (5) df_events.columns (before): "[... YHOO, YUM, ZION, ZMH, SPY]"
  #         (6) df_events.columns (after):  "[... YHOO, YUM, ZION, ZMH]"
  #         (7) df_events.values:           "[... nan,  nan,  nan]"
  
  #---  df_close = df_close.reindex(columns=df_events.columns)
  #       (1) this equivalent code is > del df_close['SPY']

  #---  df_events.values[0:lookBack, :] = np.NaN
  #     df_events.values[-lookForward:, :] = np.NaN
  #       (1) df_events.values[0:20, :] = "[... nan,  nan,  nan]"
  #       (2) df_events.values[-20:, :] = "[... nan,  nan,  nan]"
  
  #---  i_no_events = int(np.nansum(df_events.values))
  #     na_event_rets = "False"
  #       (1) Return the sum of array elements over a given axis treating 
  #           Not a Numbers (NaNs) as ZERO (0)
  #       (2) i_no_events = 451
  #       (3) type(na_event_rets) = 'str'
  
  #---  for i, s_sym in enumerate(df_events.columns):
  #             (1) iCol in 0:500, sym in 'A':'ZMH'
  #       for j, dt_date in enumerate(df_events.index):
  #             (2) jRow in 0:503, dt_date in '2008-01-02 16:00:00':'2009-12-30 16:00:00'
  #         if df_events[s_sym][dt_date] == 1:
  #         na_ret = df_rets[s_sym][j - i_lookback:j + 1 + i_lookforward]
  #             (3) na_ret = "[... 0.014150, -0.020885, -0.068655] Name: ZION"
  #             (4) na_ret.shape = (41,)
  #         if type(na_event_rets) == type(""):
  #             (5) type("") = 'str'
  #             (6) type(na_event_rets) = 'numpy.ndarray'
  #           na_event_rets = na_ret
  #         else:
  #           na_event_rets = np.vstack((na_event_rets, na_ret))
  #             (7) Take a sequence of arrays and stack them vertically to make a single array
  #             (8) na_event_rets.shape = (451, 41)
  
  #---  na_event_rets = np.cumprod(na_event_rets + 1, axis=1)
  #       (1) 
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
fill.na <- function(priceXts, method="ffill")
{
  if( method=="ffill" )
  {
    fil.num <- as.numeric(priceXts[1, ])
    row.seq <- 2:nrow(priceXts)
  } else if( method =="bfill" ) 
  {
    fil.num <- as.numeric(priceXts[nrow(priceXts), ])
    row.seq <- (nrow(priceXts)-1):1
  } else
    stop("method MUST be EITHER 'ffill' OR 'bfill'")
  
  for( iRow in row.seq )
  {
    naBln <- sum(is.na(priceXts[iRow,])) > 0
    if( naBln )
    {
      for( jCol in 1:ncol(priceXts) )
      {
        val   <- as.numeric(priceXts[iRow, jCol])
        fil   <- fil.num[jCol]
        if( is.na(val) & !is.na(fil) )
          priceXts[iRow, jCol] <- fil
      }
    }
    fil.num <- as.numeric(priceXts[iRow,])
  }
  priceXts
}

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