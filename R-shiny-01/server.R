#|------------------------------------------------------------------------------------------|
#|                                                                                 server.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    First, install the shiny package by entering these two commands at your R console:    |
#|                                                                                          |
#|    > options(repos=c(RStudio='http://rstudio.org/_packages', getOption('repos')))        |
#|    > install.packages('shiny')                                                           |
#|                                                                                          |
#|  Note: Installing it in RStudio will NOT allow you to run it in R terminal. This will    |
#|  become apparent when you try to run the package as a background process in R terminal.  |
#|                                                                                          |
#|    By default the function runApp() starts the application on port 8100. If you are      |
#|  using this default then you can connect to the running application by navigating your   |
#|  browser to http://localhost:8100. This function searches for BOTH files ui.R and        |
#|  server.R in the working directory (if there is no given directory).                     |
#|                                                                                          |
#|    If you don't want to block access to the R console while running your Shiny app,      |
#|  you can also run it in a separate process. You can do this by opening a bash shell or   |
#|  console window and executing the following:                                             |
#|                                                                                          |
#|    $ R -e "shiny::runApp('~/100 FXOption/103 FXOptionVerBack/080 FX Git/R-shiny-01/')"   |
#|                                                                                          |
#|  Note: To kill a process, type 'ps' to search for the pid, and then type 'kill -9 <pid>'.|
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script contains the shinyServer() function for PlusLotto.R.                |
#|------------------------------------------------------------------------------------------|
library(shiny)
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusLotto.R")

myServer <- function(input, output) {
  
  #---  timestamp last updated
  gTimeStamp <- attr(myServer, "gTimeStamp")
  if( is.null(gTimeStamp) ) {
    #---  init timestamp to yesterday at 00:00
    yNum <- as.POSIXlt(Sys.Date()-1)$year+1900
    mNum <- as.POSIXlt(Sys.Date()-1)$mon+1
    dNum <- as.POSIXlt(Sys.Date()-1)$mday
    gTimeStamp <- ISOdatetime(yNum,mNum,dNum,0,0,0)
  }
  if( lottoUpdateBln(gTimeStamp) )
  {
    tmp.wd <- getwd()
    LottoUpdate()
    attr(myServer, "gTimeStamp") <<- Sys.time()
    setwd(tmp.wd)
  }
  
  # Generate a summary of the dataset
  output$summaryTxt <- reactivePrint(function() {
    LottoArimaSummary()
  })
  
  output$resultTxt <- reactivePrint(function() {
    resNul <- LottoResult( input$lottoStr )
  })
  
  output$intervalTxt <- reactivePrint( function() {
    LottoArimaConf( input$lottoStr )
  })
  
  output$ticketTxt <- reactivePrint( function() {
    if( input$systemChr == "NA" | input$lottoStr == "4d" )
      Lotto( input$lottoStr, input$ticketNum )
    else
    {
      systemNum <- as.numeric(input$systemChr)
      if( systemNum > 7 )
        LottoSystem( systemNum, input$lottoStr, input$ticketNum )
      else
      {
        if( input$lottoStr == "ozlotto" | input$lottoStr == "toto" )
          Lotto( input$lottoStr, input$ticketNum )
        else
          LottoSystem( systemNum, input$lottoStr, input$ticketNum )
      }
    }
  })
}

# Define server logic required to summarize and view the selected dataset
shinyServer(myServer)
