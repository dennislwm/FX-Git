#|------------------------------------------------------------------------------------------|
#|                                                                                PlusJob.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The data for this R script comes from eFinancialCareers.sg. As there are NO CSV       |
#|  files, we have to scrape the data from the web page using the XML package. The data is  |
#|  saved into ONE (1) CSV file per sector, e.g. jobEfc_Trading.csv for Trading sector.     |
#|                                                                                          |
#| Assert Function                                                                          |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.3   The saved CSV files have been deprecated, and replaced by RDA files. Added a    |
#|          new function JobEfcCreateRdaNum() that will create ONE (1) RDA file per CSV     |
#|          file. The existing functions works with BOTH an RDA file and a CSV file, but a  |
#|          warning is given for the latter.                                                |
#|  1.0.2   The function jobEfcUpdateJobDfr() replaces double quote (") with single quote   |
#|          (') before inserting a new job. The test script is in "R-test-07-job".          |
#|  1.0.1   The function jobEfcUpdateNum() checks for ANY duplicate "hjob" before inserting |
#|          a new job. Note that the function jobEfcUpdateJobDfr() already checks content   |
#|          for comma (,) and replaces ALL commas with empty characters.                    |
#|  1.0.0   This library contains external R functions to update, search, filter and manage |
#|          data from eFinancialCareers.sg.                                                 |
#|------------------------------------------------------------------------------------------|
library(R.utils)
library(XML)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")

#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
JobEfcUpdateNum <- function( sectorStr, waitNum=1 )
{                                                         
  #---  Assert TWO (2) arguments:                                                   
  #       sectorStr:    MUST specify EITHER "Accounting_Finance", "Asset_Management", 
  #                     "Capital_Markets", "Commodities", "Equities", "FX_Money_Markets",
  #                     "Hedge_Funds", "Quantitative_Analytics", "Research", OR "Trading"
  #       waitNum:      integer value for seconds to wait between EACH query (default: 1) 
  
  #---  Check that arguments are valid
  typeStr <- c("Accounting_Finance", "Asset_Management", 
               "Capital_Markets",    "Commodities", 
               "Equities",           "FX_Money_Markets",
               "Hedge_Funds",        "Quantitative_Analytics", 
               "Research",           "Trading")
  if( length(which(typeStr==sectorStr)) == 0 | length(sectorStr) != 1 )
    stop("sectorStr MUST be either: Accounting_Finance, Asset_Management,
          Capital_Markets, Commodities, Equities, FX_Money_Markets,
          Hedge_Funds, Quantitative_Analytics, Research OR Trading")
  fileStr <- paste0(RegGetRNonSourceDir(), "jobEfc_", sectorStr, ".rda")
  deprecatedBln <- !file.exists(fileStr)
  if( !deprecatedBln )
  {
    if( exists("retDfr") ) rm("retDfr")
    load(fileStr)
    if( !exists("retDfr") )
      deprecatedBln <- TRUE
  }
  if( deprecatedBln )
  {
    warning("The CSV file has been deprecated. Call the function JobEfcCreateRdaNum() to create an RDA file.")
    retDfr  <- fileReadDfr( paste0("jobEfc_", sectorStr) )
    if( is.null(retDfr) )
    {
      retDfr <- dataFrame( colClasses=c( hjob="character", date="character",
                                         company="character", location="character",
                                         remuneration="character", postype="character",
                                         employtype="character", ref="character",
                                         content="character" ), 
                           nrow=0 ) 
    }
  }
  if( nrow(retDfr)>0 )
  {
    #--- Coerce character into numeric or date
    hjobStopChr <- retDfr[1, 1]
  }
  else hjobStopChr <- ""
  nawDfr <- dataFrame( colClasses=c( hjob="character", date="character",
                                     company="character", location="character",
                                     remuneration="character", postype="character",
                                     employtype="character", ref="character",
                                     content="character" ), 
                       nrow=0 ) 
  
  
  #---  Initialize job rank
  #       Job rank is a cumulative rank starting from first page
  pr <- 0
  retNum <- 0
  for( p in 1:10 )
  {
    if( p==1 )
      urlStr <- paste0("http://jobs.efinancialcareers.sg/", sectorStr, ".htm")
    else
    {
      pStr <- as.character((p-1)*30+1)
      urlStr <- paste0("http://jobs.efinancialcareers.sg/", sectorStr, "/",
                       pStr, ".htm")
    }
    raw.Htm <- tryCatch( htmlParse(urlStr),
                         error=function(e) { NULL }, finally={} )
    
    if( is.null(raw.Htm) ) break
    
    ref.Htt <- getNodeSet(raw.Htm, "//table[@class='jobAdTable'] //a/@href")
    raw.Htt <- readHTMLTable(raw.Htm, header=FALSE)

    if( length(raw.Htt) < 1 ) break
    if( length(ref.Htt) != length(raw.Htt) ) break
    rNum <- length(raw.Htt)
    
    for( r in 1:rNum )
    {
      hrefChr <- as.character(ref.Htt[[r]][1])
      jobDfr <- raw.Htt[[r]]
      
      if( is.null(jobDfr) ) break
      if( length(hrefChr)==0 ) break
      if( length(grep("Singapore", levels(jobDfr[,3])))==0 ) break
      
      hjobChr <- regmatches(hrefChr, regexpr("job-.*htm", hrefChr))
      hjobChr <- substring(hjobChr, 5, nchar(hjobChr)-4)
      
      if( length(hjobChr)==0 ) break
      if( hjobChr==hjobStopChr ) break
      if( length(grep(hjobChr, nawDfr$hjob))>0 ) break
      if( length(grep(hjobChr, retDfr$hjob))>0 ) break

      rDfr <- data.frame( hjobChr, levels(jobDfr[, 4]),
                          NA, NA, NA, NA, NA, NA, NA )
      names(rDfr) <- names( nawDfr )
      nawDfr <- rbind(nawDfr, rDfr)

      retNum <- retNum + 1
    }
    if( hjobChr==hjobStopChr ) break
    
    pr <- pr + rNum
    Sys.sleep(waitNum)
  }
  if( nrow(nawDfr) == 0 ) return(0)
  
  if( retNum > 0 )
  {
    nawDfr <- JobEfcUpdateJobDfr( nawDfr )
    if( is.null(nawDfr) ) retNum <- 0
    else
    {
      if( deprecatedBln )
      {
        retDfr <- rbind(nawDfr, retDfr)
        formDfr <- as.data.frame(lapply(retDfr, function(x) if (is(x, "Date")) format(x, "%Y/%m/%d") else x))
        fileWriteCsv( formDfr, paste0("jobEfc_", sectorStr) )
      } else {
        nawDfr$outcome <- NA
        retDfr <- rbind(nawDfr, retDfr)
        save(retDfr, file=fileStr)
      }
    }
  }
  retNum
}
JobEfcUpdateJobDfr <- function( rawDfr, waitNum=1 )
{                                                         
  #---  Assert TWO (2) arguments:                                                   
  #       rawDfr:       a data frame
  #       waitNum:      integer value for seconds to wait between EACH query (default: 1) 
  if( is.null(rawDfr) ) return( NULL )
  nameStr <- c( "hjob",         "date",
                "company",      "location",
                "remuneration", "postype",
                "employtype",   "ref",
                "content" )
  if( ncol(rawDfr) != length(nameStr) ) return( NULL )
  if( length(which(nameStr==names(rawDfr))) != length(nameStr) )
    stop( paste0("rawDfr MUST contain the headers: ", paste(nameStr, collapse=',')) )
  
  #---  Initialize job rank
  #       Job rank is a cumulative rank starting from first page
  retNum <- 0
  rowNum <- 1:nrow(rawDfr)
  for( r in rowNum )
  {
    urlStr <- paste0("http://jobs.efinancialcareers.sg/job-", rawDfr[r, 1], ".htm")
    raw.Htm <- tryCatch( htmlParse(urlStr),
                         error=function(e) { NULL }, finally={} )
    
    if( is.null(raw.Htm) ) return( NULL )
    
    main.Htt    <- getNodeSet(raw.Htm, "//div[@id='jobViewMainDetails'] //span")
    content.Htt <- getNodeSet(raw.Htm, "//div[@id='jobViewContent']")
    
    if( length(main.Htt) < 1 )    return( NULL )
    if( length(content.Htt) < 1 ) return( NULL )
    
    mainChr     <- gsub(",", "", sapply(main.Htt, xmlValue))
    contentChr  <- gsub(",", "", sapply(content.Htt, xmlValue))
    contentChr  <- gsub('"', "'", contentChr)
    
    if( length(mainChr) != 7 )    return( NULL )
    if( length(contentChr) > 1 )  return( NULL )
    
    rawDfr[r, 3]  <- mainChr[1]
    rawDfr[r, 4]  <- mainChr[2]
    rawDfr[r, 5]  <- mainChr[3]
    rawDfr[r, 6]  <- mainChr[4]
    rawDfr[r, 7]  <- mainChr[5]
    rawDfr[r, 8]  <- mainChr[7]
    rawDfr[r, 9]  <- gsub("\n", "", contentChr)
    
    if( length(apply(rawDfr[r, ], 2, grep, pattern=",")) != 0 )
      stop( paste0("rawDfr MUST NOT contain commas: ", rawDfr[r, 1]) )
    
    retNum <- retNum + 1
    Sys.sleep(waitNum)
  }
  
  return( rawDfr )
}
JobEfcCreateRdaNum <- function()
{
  typeStr <- c("Accounting_Finance", "Asset_Management", 
               "Capital_Markets",    "Commodities", 
               "Equities",           "FX_Money_Markets",
               "Hedge_Funds",        "Quantitative_Analytics", 
               "Research",           "Trading")
  retNum <- 0
  for( i in seq_along(typeStr) )
  {
    fileStr <- paste0(RegGetRNonSourceDir(), "jobEfc_", typeStr[i], ".rda")
    deprecatedBln <- !file.exists(fileStr)
    if( !deprecatedBln )
    {
      if( exists("retDfr") ) rm("retDfr")
      load(fileStr)
      if( !exists("retDfr") )
        deprecatedBln <- TRUE
    }
    if( deprecatedBln )
    {
      retDfr <- fileReadDfr( paste0("jobEfc_", typeStr[i]) )
      if( is.null(retDfr) )
      {
        retDfr <- dataFrame( colClasses=c( hjob="character", date="character",
                                           company="character", location="character",
                                           remuneration="character", postype="character",
                                           employtype="character", ref="character",
                                           content="character", outcome="numeric" ), 
                             nrow=0 ) 
      }
      outcomeBln <- length(which(names(retDfr)=="outcome"))>0
      if( !outcomeBln ) retDfr$outcome <- NA
      save( retDfr, file=fileStr )  
      retNum <- retNum + 1
    }
  }
  retNum
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|