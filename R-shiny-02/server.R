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
#|    $ R -e "shiny::runApp('~/100 FXOption/103 FXOptionVerBack/080 FX Git/R-shiny-02/',    |
#|                          port=8103L)"                                                    |
#|                                                                                          |
#|  Note: To kill a process, type 'ps' to search for the pid, and then type 'kill -9 <pid>'.|
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.1   Fixed some minor bugs when loading the file and tweaked the graph plot.         |
#|  1.0.0   This script contains the shinyServer() function for PlusRealis.R                |
#|------------------------------------------------------------------------------------------|
library(shiny)
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusRealis.R")

myServer <- function(input, output) 
{
  #---  The interaction flow
  #       (1) UI disabled, wait for database to load
  #         (i)   Database loaded from 1 January 2012 (start seq: 371)
  #       (1) UI disabled, enabled for Region, which is dynamic
  #         (i)   Database loaded from 1 January 2012
  #       (2) Click Ok, UI enabled for Area, which is dynamic
  #         (ii)  Database subset for Area
  #       (3) Click Ok, UI enabled for Project, which is dynamic
  #         (iii) Database subset for Project
  #       (4) Click Ok, UI enabled for Floor, Psf, Price and Level
  #         (iv)  Database subset for Floor, Psf, Price and Level
  #     Note: The file seq is from 371 for 1 January 2012 onwards 
  #           (Mar to Jan not in order)
  
  #---  Output variables
  #       (0) raw.FUN() returns a data.frame
  #       (1) output$region.selectInput is a UI
  #       (2) reg.FUN() returns a data.frame
  #       (3) output$area.selectInput is a UI
  #       (4) area.FUN() returns a data.frame
  #       (5) output$project.selectInput is a UI
  #       (6) project.FUN() returns a data.frame
  #       (7) table.FUN() returns a data.frame
  #       (8) threshold.FUN() returns a boolean
  #       (9) output$floor.selectInput is a UI
  #       (10) floor.FUN() returns a data.frame  
  #       (11) output$summaryTxt is a Print
  #       (12) output$summary.plot is a Plot
  #       (13) output$tableDfr is a Print  
  raw.FUN <- reactive(function() {
    rawDfr <- RealisReadDfr("realis_residential_database_1995_jan",
                            371:402)
    rawDfr
  } )  
  
  output$region.selectInput <- reactiveUI( function() 
  {
    rawDfr <- raw.FUN()
    tryCatch( selectInput("regionChr", "Choose Region:", 
                          sort( unique(rawDfr[,18]) ) ),
              error=function(e) { NULL }, finally={} )
  } )
  
  #       (2) reg.FUN() returns a data.frame
  reg.FUN <- reactive(function() {
    rawDfr <- raw.FUN()
    if( !is.null(rawDfr) )
      rawDfr[rawDfr[,18]==input$regionChr, ]
    else
      NULL
  } )
  
  #       (3) area.selectInput is a UI
  output$area.selectInput <- reactiveUI( function()
  {
    regDfr <- reg.FUN()
    tryCatch( selectInput("areaChr", "Choose an Area:",
                          sort( unique(regDfr[,19]) ) ),
              error=function(e) { NULL }, finally={} )
  } )
  
  #       (4) area.FUN() returns a data.frame
  area.FUN <- reactive(function() {
    rawDfr <- raw.FUN()
    if( !is.null(rawDfr) )
      rawDfr[rawDfr[,18]==input$regionChr 
             & rawDfr[,19]==input$areaChr, ]
    else
      NULL
  } )
  
  #       (5) output$project.selectInput is a UI
  output$project.selectInput <- reactiveUI( function()
  {
    areaDfr <- area.FUN()
    tryCatch( selectInput("projectChr", "Choose a Project:",
                          sort( unique(areaDfr[,1]) ) ),
              error=function(e) { NULL }, finally={} )
  } )
  
  #       (6) project.FUN() returns a data.frame
  project.FUN <- reactive(function() {
    rawDfr <- raw.FUN()
    if( !is.null(rawDfr) )
      rawDfr[rawDfr[,18]==input$regionChr 
             & rawDfr[,19]==input$areaChr
             & rawDfr[,1]==input$projectChr, ]
    else
      NULL
  } )
  
  #       (7) table.FUN() returns a data.frame  
  table.FUN <- reactive(function() {
    pDfr <- project.FUN()
    if(nrow(pDfr)>0)
    {
      pDfr <- cbind( pDfr, RealisAddressSplitDfr(pDfr[, 2]) )
      
      #---  Subset of columns
      #       Project
      #       Area sqm, Price, Psf, Date
      #       Level, Unit
      tableDfr <- cbind( pDfr[,1], 
                         pDfr[,4], pDfr[,6], pDfr[,8], pDfr[,9],
                         pDfr$level, pDfr$unit )
      pDfr <- tableDfr
      colnames(pDfr) <- c("Project", 
                          "AreaSqm", "Price", "Psf", "Date", 
                          "Level", "Unit")
      pDfr
    }
    else
      NULL
  } )
  
  #       (8) threshold.FUN() returns a boolean
  threshold.FUN <- reactive(function() {
    tDfr <- table.FUN()
    thresholdNum <- 20
    if( !is.null(tDfr) )
    {
      if(nrow(tDfr)>=thresholdNum)
        TRUE
      else
        FALSE
    }
    else
      FALSE
  })
  
  #       (9) output$floor.selectInput is a UI
  output$floor.selectInput <- reactiveUI( function()
  {
    tDfr <- table.FUN()
    okBln <- threshold.FUN()
    iNum <- 5
    if(okBln)
    {
      #---  Round floor size to nearest hundred
      uppNum <- round(max(as.numeric(tDfr[,2]))+5, digits=-1)
      lowNum <- round(min(as.numeric(tDfr[,2]))-5, digits=-1)
      
      #---  Interval is range divided by number of intervals
      bNum <- (uppNum-lowNum) / iNum
      
      #---  Create the inputs
      rChr <- c()
      lNum <- 0
      uNum <- 0
      for( i in 1:iNum )
      {
        lNum <- lowNum + bNum*(i-1)
        uNum <- lowNum + bNum*i
        rChr <- c( rChr, paste0(lNum,"< Floor Size <=",uNum) )
      }
      tryCatch( selectInput("floorChr", "Choose a Floor Size:",
                            rChr ),
                error=function(e) { NULL }, finally={} )
    }
    else
      NULL
  } )  
  
  #       (10) floor.FUN() returns a data.frame  
  floor.FUN <- reactive(function() {
    tDfr <- table.FUN()
    okBln <- threshold.FUN()
    fChr <- input$floorChr
    if(okBln)
    {
      if( !is.null(fChr) )
      {
        lNum <- as.numeric(substring(fChr, 
                                     1, regexpr("<", fChr)[1]-1))
        uNum <- as.numeric(substring(fChr, 
                                     regexpr("<=", fChr)[1]+2, nchar(fChr)))
        tDfr[ as.numeric(tDfr[,2]) >= lNum 
              & as.numeric(tDfr[,2]) <= uNum, ]
        
      }
      else
        NULL
    }
    else
      NULL
  } )
  
  #       (11) output$summaryTxt is a Print
  output$summaryTxt <- reactivePrint(function() {
    tDfr <- table.FUN()
    fDfr <- floor.FUN()
    if( !is.null(fDfr) )
    {
      list( Floor_Area=summary(as.numeric(fDfr[,2])),
            Price=summary(as.numeric(fDfr[,3])),
            Psf=summary(as.numeric(fDfr[,4]))
      )
    }
    else if( !is.null(tDfr) )
    {
      list( Floor_Area=summary(as.numeric(tDfr[,2])),
            Price=summary(as.numeric(tDfr[,3])),
            Psf=summary(as.numeric(tDfr[,4]))
      )     
    }
    else
      "Choose a Region, Area and Project"
  })
  
  
  #       (12) output$summary.plot is a Plot
  output$summary.plot <- reactivePlot(function() {
    fsNum <- 1.5
    par( mfcol = c(1,3), las=2, mar=c(2.1,5.1,2.1,2.1),
         cex.lab=fsNum, cex.axis=fsNum, cex.main=fsNum, cex.sub=fsNum ) 
    tDfr <- table.FUN()
    fDfr <- floor.FUN()
    if( !is.null(fDfr) )
    {
      boxplot( as.numeric(fDfr[,2]), outchar = T,
               main = "Floor Size", col = "lightgray")
      boxplot( as.numeric(fDfr[,4]), outchar = T, 
               main = "Unit Price Psf", col = "grey")
      boxplot( as.numeric(fDfr[,3]), outchar = T, 
               main = "Purchase Price", col = "darkgray")
    }
    else if( !is.null(tDfr) )
    {
      boxplot( as.numeric(tDfr[,2]), outchar = T,  
               main = "Floor Size", col = "lightgray")
      boxplot( as.numeric(tDfr[,4]), outchar = T, 
               main = "Unit Price Psf", col = "grey")
      boxplot( as.numeric(tDfr[,3]), outchar = T, 
               main = "Purchase Price", col = "darkgray")
    }
    else
      "Choose a Region, Area and Project"
  })
  
  
  #       (13) output$tableDfr is a Print
  output$tableDfr <- reactivePrint(function() {
    tDfr <- table.FUN()
    fDfr <- floor.FUN()
    if( !is.null(fDfr) )
      fDfr
    else if( !is.null(tDfr) )
      tDfr
    else
      "Choose a Region, Area and Project"
  } )
}

# Define server logic required to summarize and view the selected dataset
shinyServer(myServer)
