#|------------------------------------------------------------------------------------------|
#|                                                                                     ui.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script contains the shinyUI() function for PlusLotto.R.                    |
#|------------------------------------------------------------------------------------------|
library(shiny)
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusLotto.R")

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Lotto Arima Generator"),
  
  # Sidebar with controls to select a dataset and specify the number
  # of observations to view
  sidebarPanel(
    selectInput( "lottoStr", "Choose a Lotto game:",
                 choices=c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d") ),
    
    sliderInput( "ticketNum", "Number of tickets to generate:", min=1, max=20, value=12),
    
    selectInput( "systemChr", "Choose a System:",
                 choices=c("NA", "7", "8", "9", "10", "11", "12") )
    
  ),
  
  # Show a summary of the dataset and an HTML table with the requested
  # number of observations
  mainPanel(
    tabsetPanel(
      tabPanel("Tickets", h4("Good Luck!"), verbatimTextOutput("ticketTxt") ), 
      tabPanel("Confidence", h4("Interval"), verbatimTextOutput("intervalTxt") ), 
      tabPanel("Summary", verbatimTextOutput("summaryTxt") ),
      tabPanel("Result", h4("Latest"), verbatimTextOutput("resultTxt") )
    )
  )
))
