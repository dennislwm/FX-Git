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
#|  1.0.2   Modified script to work with a major revision of PlusLotto 1.0.7. Added TWO (2) |
#|          reactive functions output$ci.selectInput() is a UI, and ci.FUN() returns a      |
#|          boolean.
#|  1.0.1   Major bug fixes including interaction flow, output variables and reactiveUI.    |
#|            Incorporated Roulette (r) into both server and ui.                            | 
#|  1.0.0   This script contains the shinyServer() function for PlusLotto.R.                |
#|------------------------------------------------------------------------------------------|
library(shiny)
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusLotto.R")

myServer <- function(input, output) 
{
  #---  The interaction flow
  #       (1) UI disabled, wait for database to update
  #         (i)   Database updated
  #       (2) Click Ok, UI enabled for Lotto
  #         (ii)  Arima Summary loaded
  #       (3) Click Ok, UI enabled for Tickets, and UI enabled for System
  #           (r: UI enabled for Number)
  #         (iii) Arima Confidence loaded, Lotto Result loaded
  #       (4) Click Ok
  #         (iv)  Lotto Tickets loaded
  
  #---  Output variables
  #       (1) update.FUN() returns a number
  #       (2) output$lotto.selectInput is a UI
  #       (2)(a)  output$ci.selectInput is a UI
  #       (2)(b)  ci.FUN() returns a boolean
  #       (3) output$ticket.selectInput is a UI
  #       (4) output$system.selectInput is a UI
  #       (5) output$number.selectInput is a UI
  #       (6) output$summaryTxt is a Print
  #       (7) output$intervalTxt is a Print
  update.FUN <- reactive(function() {
    tmp.wd <- getwd()
    retNum <- LottoUpdateNum()
    setwd(tmp.wd)
    retNum
  } )  
  #       (2) output$lotto.selectInput is a UI
  output$lotto.selectInput <- reactiveUI(function() {
    if( is.numeric(update.FUN()) )
      selectInput( "lottoStr", "Choose a Lotto game:",
                   choices=c("powerball", "ozlotto", "satlotto", "wedlotto",
                             "toto", "4d", "r") )
    else
      NULL
  } )
  #       (2)(a)  output$ci.selectInput is a UI
  output$ci.selectInput <- reactiveUI(function() {
    if( is.numeric(update.FUN()) )
      selectInput( "ciStr", "Choose a Confidence percentage:",
                   choices=c("80%", "95%") )
    else
      NULL
  } )
  #       (2)(b)  ci.FUN() returns a boolean
  ci.FUN <- reactive(function() {
    if( length(input$ciStr)>0 )
    {
      if( input$ciStr == "80%" )
        TRUE
      else
        FALSE
    }
    else
      NULL
  } )
  #       (3) output$ticket.selectInput is a UI
  output$ticket.selectInput <- reactiveUI(function() {
    if( length(input$lottoStr)>0 )
    {
      if( input$lottoStr != "r" )
        selectInput( "ticketNum", "Number of tickets to generate:",
                     choices=c(12,13,14,15,16,17,18,19,20) )
      else
        selectInput( "ticketNum", "Number of tickets to generate:",
                     choices=c(1,2,3,4,5,6) )
    }
    else
      NULL
  } )
  #       (4) output$system.selectInput is a UI
  output$system.selectInput <- reactiveUI(function() {
    if( length(input$lottoStr)>0 )
    {
      if( input$lottoStr != "4d" & input$lottoStr != "r" )
        selectInput( "systemChr", "Choose a System:",
                     choices=c("NA", "7", "8", "9", "10", "11", "12") )
      else
        NULL
    }
    else
      NULL
  } )
  #       (5) output$number.selectInput is a UI
  output$number.selectInput <- reactiveUI(function() {
    if( length(input$lottoStr)>0 )
    {
      if( input$lottoStr == "r" )
        selectInput( "randChr", "Choose a r number:",
                     choices=c("Refresh", "Start Over", 
                               "0","1","2","3","4","5","6","7","8","9",
                               "10","11","12","13","14","15","16","17","18","19",
                               "20","21","22","23","24","25","26","27","28","29",
                               "30","31","32","33","34","35","36") )
      else
        NULL
    }
    else
      NULL
  } )
  #       (6) output$summaryTxt is a Print
  output$summaryTxt <- reactivePrint(function() {
    if( is.numeric(update.FUN()) )
    {
      ciBln <- TRUE
      if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
      LottoArimaSummary(c80Bln=ciBln)
    }
    else
      "Select a Lotto game."
  })
  r.FUN <- reactive(function() {
    if( length(input$lottoStr)>0 )
    {
      if( input$lottoStr == "r" )
      {
        if( length(input$randChr)>0 )
        {
          #---  r file is updated
          #       (1) user wants to start over
          randFileChr <- paste0(RegGetRNonSourceDir(),"r.csv")
          if( input$randChr == "Start Over" ) 
            NULL
          else
          {
            randDfr <- fileReadDfr( input$lottoStr )
            randDfr
          }
        }
        else NULL
      }
      else NULL
    }
    else NULL
  })
  #       (7) output$intervalTxt is a Print
  output$intervalTxt <- reactivePrint( function() {
    if( length(input$lottoStr)>0 )
    {
      if( input$lottoStr == "r" )
      {
        if( length(input$randChr)>0 )
        {
          #---  r file is updated
          #       (1) user wants to start over
          #       (2) Arima Confidence Interval with update
          #       (3) Arima Confidence Interval without update
          randFileChr <- paste0(RegGetRNonSourceDir(),"r.csv")
          if( input$randChr == "Start Over" )
          {
            #   (1) user wants to start over
            if( file.exists(randFileChr) ) file.remove(randFileChr)
            "Start Over"
          }
          else if( input$randChr == "Refresh" )
          {
            #   (4) Arima Confidence Interval without update
            randDfr <- fileReadDfr( input$lottoStr )
            if( is.null(randDfr) ) retNum <- 0
            else retNum <- nrow(randDfr)
            if( retNum>=3 )
            {
              ciBln <- TRUE
              if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
              confDfr <- LottoArimaConf( input$lottoStr, c80Bln=ciBln )
              confDfr[1,]
            }
            else
              "R contains LESS THAN THREE (3) numbers"
          }
          else
          {
            randNum <- as.numeric(input$randChr)
            retNum <- lottoRandUpdateNum(randNum)
            #   (3) Arima Confidence Interval with update
            if( retNum>=3 )
            {
              ciBln <- TRUE
              if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
              confDfr <- LottoArimaConf( input$lottoStr, c80Bln=ciBln )
              confDfr[1,]
            }
            else
              "R contains LESS THAN THREE (3) numbers"
          }
        }
        else
          "Select a R number."
      }
      else
      {
        ciBln <- TRUE
        if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
        LottoArimaConf( input$lottoStr, c80Bln=ciBln )
      }
    }
    else
      "Select a Lotto game."
  })
  output$resultTxt <- reactivePrint(function() {
    if( length(input$lottoStr)>0 )
    {
      if( input$lottoStr == "r" )
      {
        if( length(input$randChr)>0 )
        {
          if( input$randChr == "Start Over" )
            "Start Over"
          else
            LottoResult( input$lottoStr, resNum=99 )
        }
        else
          LottoResult( input$lottoStr, resNum=99 )
      }
      else
        LottoResult( input$lottoStr )
    }
    else
      "Select a Lotto game."
  })
  output$ticketTxt <- reactivePrint( function() {
    if( length(input$lottoStr)>0 )
    {
      if( length(input$ticketNum)>0 )
      {
        if( input$lottoStr == "r" )
        {
          if( length(input$randChr)>0 )
          {
            if( input$randChr == "Start Over" )
              "Start Over"
            else
            {
              rDfr <- r.FUN()
              if( !is.null(rDfr) )
              {
                if( nrow(rDfr)>=3 )
                {
                  ciBln <- TRUE
                  if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
                  Lotto( input$lottoStr, as.numeric(input$ticketNum), c80Bln=ciBln )
                }
                else
                  "R contains LESS THAN THREE (3) numbers"
              }
              else
                "R contains LESS THAN THREE (3) numbers"
            }
          }
          else  
          {
            rDfr <- r.FUN()
            if( !is.null(rDfr) )
            {
              if( nrow(rDfr)>=3 )
              {
                ciBln <- TRUE
                if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
                Lotto( input$lottoStr, as.numeric(input$ticketNum), c80Bln=ciBln )
              }
              else
                "R contains LESS THAN THREE (3) numbers"
            }
            else
              "R contains LESS THAN THREE (3) numbers"
          }
        }
        else if( input$lottoStr == "4d" )
        {
          ciBln <- TRUE
          if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
          Lotto( input$lottoStr, as.numeric(input$ticketNum), c80Bln=ciBln )
        }
        else
        {
          if( length(input$systemChr)>0 )
          {
            if( input$systemChr != "NA" )
            {
              systemNum <- as.numeric(input$systemChr)
              if( systemNum > 7 )
              {
                ciBln <- TRUE
                if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
                LottoSystem( systemNum, input$lottoStr, as.numeric(input$ticketNum), c80Bln=ciBln )
              }
              else
              {
                if( input$lottoStr == "ozlotto" | input$lottoStr == "toto" )
                {
                  ciBln <- TRUE
                  if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
                  Lotto( input$lottoStr, as.numeric(input$ticketNum), c80Bln=ciBln )
                }
                else
                {
                  ciBln <- TRUE
                  if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
                  LottoSystem( systemNum, input$lottoStr, as.numeric(input$ticketNum), c80Bln=ciBln )
                }
              }
            }
            else
            {
              ciBln <- TRUE
              if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
              Lotto( input$lottoStr, as.numeric(input$ticketNum), c80Bln=ciBln )
            }
          }
          else
          {
            ciBln <- TRUE
            if( is.logical(ci.FUN()) ) ciBln <- ci.FUN()
            Lotto( input$lottoStr, as.numeric(input$ticketNum), c80Bln=ciBln )
          }
        }
      }
      else
        "Select a Lotto game and no. of Tickets."
    }
    else
      "Select a Lotto game and no. of Tickets."
  })
}

# Define server logic required to summarize and view the selected dataset
shinyServer(myServer)
