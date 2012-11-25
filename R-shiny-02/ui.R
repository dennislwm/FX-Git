#|------------------------------------------------------------------------------------------|
#|                                                                                     ui.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script contains the shinyUI() function for PlusRealis.R                    |
#|------------------------------------------------------------------------------------------|
library(shiny)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusRealis.R")

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("URA Realis Database"),

#---  Input variables
#       (1) regionChr is a string
#       (2) areaChr is a string
#       (3) projectChr is a string
  sidebarPanel(
    uiOutput("region.selectInput"),

    conditionalPanel(
      condition = "!is.null(output.area.selectInput)",
      uiOutput("area.selectInput") 
      ),
    
    conditionalPanel(
      condition = "!is.null(output.project.selectInput)",
      uiOutput("project.selectInput"),
      uiOutput("floor.selectInput")
    ),
    
    submitButton("Ok")
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Statistics", h4("Summary"), verbatimTextOutput("summaryTxt") ), 
      tabPanel("Graph", h4("Plot"), plotOutput("summary.plot") ), 
      tabPanel("Caveats", h4("Latest"), verbatimTextOutput("tableDfr") )
    )
  )
))
