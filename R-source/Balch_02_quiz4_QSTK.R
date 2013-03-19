#|------------------------------------------------------------------------------------------|
#|                                                                    Balch_02_quiz4_QSTK.R |
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
#|    The purpose of this homework is to introduce you to: (a) event studies based on       |
#|  historical information; (b) reading in and processing different types of historical     |
#|  data; and (c) assessing the results of an event study. Review and understand QSTK       |
#|  Tutorial NINE (9).                                                                      |
#|                                                                                          |
#|    A.  Create an event study profile of a specific "known" event on S&P 500 index and    |
#|      compare its impact on TWO (2) groups of stocks. The event is defined as when the    |
#|      "actual" close of the stock price drops BELOW FIVE ($5) dollars, more specifically, |
#|      when: (a) price[t-1] >= 5; and (b) price[t] < 5, an event has occurred on date t.   |
#|      Note that just because the price is below FIVE (5) it is NOT an event for every day |
#|      that it is below FIVE (5), only on the FIRST day it drops below FIVE (5).           |
#|        Evaluate this event for the time period January 1, 2008 to December 31, 2009.     |
#|      Compare the results using TWO (2) lists of S&P 500 stocks: (a) the stocks that were |
#|      in S&P 500 in 2008 (sp5002008.txt); and (b) the stocks that were in S&P 500 in 2012 |
#|      (sp5002012.txt). These equity lists are in the directory QSData/Yahoo/Lists. You    |
#|      can read them in using the QSTK call:                                               |
#|                                                                                          |
#|        > dataobj = da.DataAccess('Yahoo')                                                |
#|        > symbols = dataobj.get_symbols_from_list("sp5002008")                            |
#|        > symbols.append('SPY')                                                           |
#|                                                                                          |
#|        If the performance of the event seems to depend on which list of equities you     |
#|      use, please consider why that is. We will talk about it in class videos.            |
#|                                                                                          |
#|        Important: It is always important to remove "NAN" from price data, specially for  |
#|      the S&P 500 from 2008. Use the code below after reading the data to get the correct |
#|      results.                                                                            |
#|                                                                                          |
#|        > for s_key in ls_keys:                                                           |
#|        >     d_data[s_key] = d_data[s_key].fillna(method = 'ffill')                      |
#|        >     d_data[s_key] = d_data[s_key].fillna(method = 'bfill')                      |
#|        >     d_data[s_key] = d_data[s_key].fillna(1.0)                                   |
#|                                                                                          |
#|    B.  Make sure the output of your program matches the example outputs below:           |
#|      (a) For the FIVE ($5) dollar event with S&P500 in 2012, we find ONE HUNDRED AND     |
#|          SEVENTY SIX (176) events, where date range is Jan 1, 2008 to Dec 31, 2009.      |
#|      (b) For the FIVE ($5) dollar event with S&P500 in 2008, we find THREE HUNDRED AND   |
#|          TWENTY SIX (326) events, where date range is Jan 1, 2008 to Dec 31, 2009.       |
#|                                                                                          |
#|    C.  For your evaluation on this project, you will take a "quiz" where we will ask you |
#|      to run an event profile using parameters similar to Part A above, but using         |
#|      different time periods OR thresholds. You will enter numerical answers to the       |
#|      questions. You will also be asked ONE (1) or more questions about the difference    |
#|      between the event study results for the TWO (2) different data sets. Have BOTH      |
#|      charts ready and be prepared to answer questions about them.                        |
#|                                                                                          |
#| History                                                                                  |
#|  0.9.0   Coursera's "Computational Investing" course (Tucker Balch) Quiz 4 Week 4.       |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)

#---  Prerequisite. We have to perform these TWO (2) steps prior to running this script.
#     (1) Download the data using the python script "Balch_01_tutorial01_QSTK.py" and save
#         it as a CSV file "Balch_02_tutorial01". Note: The python script saves the adjusted
#         closing price ONLY.
#     (2) Copy the CSV file into the folder "R-nonsource".
