#|------------------------------------------------------------------------------------------|
#|                                                                                     ui.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.2   Modified script to work with a major revision of PlusLotto 1.0.7. Added ONE (1) |
#|            reactive UI ci.SelectInput.                                                   |
#|  1.0.1   Major bug fixes including interaction flow, output variables and reactiveUI.    |
#|            Incorporated Roulette (r) into both server and ui.                            | 
#|  1.0.0   This script contains the shinyUI() function for PlusLotto.R.                    |
#|------------------------------------------------------------------------------------------|
library(shiny)
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusLotto.R")

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Lotto Arima Generator"),
  
  # Sidebar with controls to select a dataset and specify the number
  # of observations to view
  sidebarPanel(
    conditionalPanel(
      condition = "!is.null(output.lotto.selectInput)",
      uiOutput("lotto.selectInput"),
      uiOutput("ci.selectInput")
    ),
    conditionalPanel(
      condition = "!is.null(output.ticket.selectInput)",
      uiOutput("ticket.selectInput"),
      uiOutput("system.selectInput"),
      uiOutput("number.selectInput")
    ),
    
    submitButton("Ok")
  ),
  
  # Show a summary of the dataset and an HTML table with the requested
  # number of observations
  mainPanel(
    tabsetPanel(
      tabPanel("Tickets", h4("Good Luck!"), verbatimTextOutput("ticketTxt") ), 
      tabPanel("Confidence", h4("Interval"), verbatimTextOutput("intervalTxt") ), 
      tabPanel("Summary", h4("Power"), verbatimTextOutput("summaryTxt") ),
      tabPanel("Result", h4("Latest"), verbatimTextOutput("resultTxt") )
    )
  )
))
