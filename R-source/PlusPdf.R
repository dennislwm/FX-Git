#|------------------------------------------------------------------------------------------|
#|                                                                                PlusPdf.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The data for this R script comes from backdoor access to various research firms.      |
#|                                                                                          |
#| Assert Function                                                                          |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.1   Added functions to support Conway & White (2012), Machine Learning for Hackers: |
#|            ONE (1) external function PdfNomuraConwayUpdate() and THREE (3) internal      |
#|            functions pdfClassifyNum(), pdfConwayDfr() and pdfNomuraTrainChr().           |
#|  1.0.0   This library contains external R functions to perform PDF reports manipulation. |
#|------------------------------------------------------------------------------------------|
library(R.utils)
library(tm)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R")
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   B   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
PdfNomuraConwayUpdate <- function()
{
#---  Initialize variables
#       Download training data
#       (1) spam
#       (2) nonspam
  trnFileChr <- "pdfNomuraConway"
  ctryFileChr <- "pdfNomuraCountry"
  induFileChr <- "pdfNomuraIndustry"
  spamFileChr <- paste0( trnFileChr, "Spam" )
  nspamFileChr <- paste0( trnFileChr, "NonSpam" )
  
  spamChr <- pdfNomuraTrainChr( trnFileChr, setBln=TRUE )
  nspamChr <- pdfNomuraTrainChr( trnFileChr, setBln=FALSE )
  
  ctryDfr <- fileReadDfr(ctryFileChr)
  induDfr <- fileReadDfr(induFileChr)
  
  if( !is.null(ctryDfr) & !is.null(induDfr) )
  {
    spamDictChr <- tolower(c( na.omit(ctryDfr$nWord), na.omit(induDfr$nWord) ))
    nspamDictChr <- tolower(c( na.omit(ctryDfr$pWord), na.omit(induDfr$pWord) ))
  }

#---  Transform character vector into a data.frame
#       Save data frame as CSV files
  addStopWordsChr <- c("aad",
                       "abdulaziz", "andypoonkimengcomhk", "anthony",
                       "alex", "alexyeungkimengcomhk", "andy",
                       "able",
                       "accepts",
                       "access", "accessed",
                       "accordingly", "according",
                       "accounting", "account",
                       "accredited",
                       "accuracy", "accurate", "accurately",
                       "achieved",
                       "act", "actions",
                       "actual",
                       "addition", "additional",
                       "adjusted",
                       "advisers", "advisory",
                       "altered",
                       "alternative",
                       "amended",
                       "analyst", "analysts", "analysis",
                       "andor",
                       "anfaal", "adex", "adi",
                       "affiliates",
                       "affected",
                       "appear", "appearing",
                       "applicable", "applicability", "applicant",
                       "appropriateness",
                       "apply",
                       "arabia",
                       "arise", "arising",
                       "associates", "association")
  spamDfr <- pdfConwayDfr( spamChr, 2, spamDictChr, addStopWordsChr )
  nspamDfr <- pdfConwayDfr( nspamChr, 2, nspamDictChr, addStopWordsChr )
  
  if( !is.null(spamDfr) ) fileWriteCsv( spamDfr, spamFileChr )
  if( !is.null(nspamDfr) ) fileWriteCsv( nspamDfr, nspamFileChr )
}

#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
PdfNomuraSeqNum <- function(toNum, toChr=NULL, gapNum=5, waitNum=1, silent=FALSE)
{
  #---  Assert FOUR (4) arguments:                                                   
  #       toNum:        integer value for number of PDFs to download
  #       gapNum:       integer value for number cumulative gaps between downloads before 
  #                     stop (default: 5)
  #       waitNum:      integer value for seconds to wait between EACH query (default: 1) 
  #       silent:       boolean value for displaying console messages (default: FALSE)
  
  #---  Check that arguments are valid
  if( as.numeric(toNum) < 1 ) 
    stop("toNum MUST be greater than OR equal to ONE (1)")
  if( as.numeric(gapNum) < 1 | as.numeric(gapNum) > 20 ) 
    stop("gapNum MUST be between ONE (1) and TWENTY (20)")
  if( as.numeric(waitNum) < 1 | as.numeric(waitNum) > 20 ) 
    stop("waitNum MUST be between ONE (1) and TWENTY (20)")
  if( !is.null(toChr) )
    for( i in 1:length(toChr) )
    {
      if( !RegIsEmailBln(toChr[i]) )
        stop("To recipients MUST contain valid email formats")
    }
  
  #siteChr <- "http://www.nomuranow.com/research/globalresearchportal/getpub.aspx?pid="
  siteChr <- "http://www.kelive.com/KimEng/servlet/PDFDownloadViaEmail?source=0&rid="
  suffixChr <- "&uid=32549&ky=12557"
  retFileChr <- "pdfNomura" 
  ctryFileChr <- paste0(retFileChr, "Country")
  induFileChr <- paste0(retFileChr, "Industry")
  
  retDfr <- fileReadDfr( retFileChr )
  if( is.null(retDfr) )
    retDfr <- dataFrame( colClasses=c( pid="character" ), 
                         nrow=0 )
  
  ctryDfr <- fileReadDfr(ctryFileChr)
  induDfr <- fileReadDfr(induFileChr)
  
  if( !is.null(ctryDfr) & !is.null(induDfr) )
  {
    spamDictChr <- tolower(c( na.omit(ctryDfr$nWord), na.omit(induDfr$nWord) ))
    nspamDictChr <- tolower(c( na.omit(ctryDfr$pWord), na.omit(induDfr$pWord) ))
  }
  
  #startIdNum <- 550344
  startIdNum <- 23287
  if( nrow(retDfr)>0 )
  {
    #--- Coerce character into numeric or date
    nextIdNum <- max( suppressWarnings( as.numeric( retDfr[, 1] ) ) ) + 1
    if( !is.na(nextIdNum) )
    {
      if( nextIdNum > startIdNum ) startIdNum <- nextIdNum
    }
  }
  
  #---  Initialize page rank
  #       Page rank is the count of gaps between pids
  #       Save last pid that has a valid PDF
  #       Set warnings to generate an error
  pr <- 0
  retNum <- 0
  sentNum <- 0
  pidNum <- startIdNum
  optWarnNum <- options()$warn
  while( pr < gapNum )
  {
    urlChr <- paste0(siteChr, pidNum, suffixChr)
    tmpFileChr <- tempfile(fileext = ".pdf")
    options(warn=2)
    errNum <- tryCatch( download.file(urlChr, tmpFileChr, mode = "wb", quiet=silent),
                        error=function(e) { 9999 }, finally={} )
    options(warn=0)
    #---  Error can occur in THREE (3) ways
    #       (1) download.file() returns an error
    #       (2) download.file() returns ok, but PDF file does not exists
    #       (3) download.file() returns ok, and PDF file exists, 
    #           but it is damaged
    if( errNum == 9999 | errNum > 0 )
      pr <- pr + 1
    else if( !file.exists(tmpFileChr) )
      pr <- pr + 1
    else
    {
      #---  Downloaded file
      #       Parse text of PDF to see if it is of interest
      #       Save last pid that is a valid PDF
      #       Move PDF from temp folder to R-nonsource
      txtChr <- pdfParseChr( tmpFileChr )
      if(is.null(txtChr))
        pr <- pr + 1
      else
      {
        pidChr <- paste0(pidNum)
        rDfr <- data.frame( pidChr )
        names(rDfr) <- names( retDfr )
        retDfr <- rDfr
        
        #---  Search for specific words
        #       (1) Filter by country
        #       (2) Filter by industry
        #       (3) Filter by company
        nonspam.dir <- paste0(RegGetRDir(),"PDF-nonspam/")
        spam01.dir  <- paste0(RegGetRDir(),"PDF-spam-01/")
        spam02.dir  <- paste0(RegGetRDir(),"PDF-spam-02/")
        
        #        if( pdfSearchCountryNum(txtChr) < 0 )
        spamNum <- pdfClassifyNum(txtChr, "pdfNomuraConwaySpam", 
                               dictChr=spamDictChr)
        nspamNum <- pdfClassifyNum(txtChr, "pdfNomuraConwayNonSpam", 
                                dictChr=nspamDictChr)
        if( spamNum > nspamNum )
        {
          destFileChr <- paste0(spam01.dir, "NMA", pidChr, ".pdf")      
          file.rename( tmpFileChr, destFileChr )
        }
#        else if( pdfSearchIndustryNum(txtChr) < 0 )
#        {
#          destFileChr <- paste0(spam02.dir, "NMA", pidChr, ".pdf")      
#          file.rename( tmpFileChr, destFileChr )
#        }
        else
        {
          #---  Move file to PDF-nonspam folder
          #       Write first 20 lines of PDF as message
          #       Mail file as attachment
          #       Optionally remove file from system
          destFileChr <- paste0(nonspam.dir, "NMA", pidChr, ".pdf")      
          if( file.rename( tmpFileChr, destFileChr ) )
          {
            if( !is.null(toChr) )
            {
              msgFileChr <- sub(".pdf", ".txt", destFileChr)
              mRow <- min(20, length(txtChr))
              writeLines(txtChr[1:mRow], msgFileChr)
              
              if( pdfGmailNum(destFileChr, toChr=toChr, 
                              msgFileChr=msgFileChr) 
                  == 0 )
              {
                file.remove( destFileChr )
                file.remove( msgFileChr )
                sentNum <- sentNum + 1
              }
            }
          }
        }
        
        retNum <- retNum + 1
      }
    }
    if( retNum >= toNum ) break
    pidNum <- pidNum + 1
    Sys.sleep(waitNum)
  }
  options(warn=optWarnNum)
  
  if( retNum > 0 )
  {
    formDfr <- as.data.frame(lapply(retDfr, function(x) if (is(x, "Date")) format(x, "%Y/%m/%d") else x))
    fileWriteCsv( formDfr, retFileChr )
  }
  if( !silent ) print( paste0("Total ",sentNum," pdfs sent to email.") )
  retNum
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   B   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
pdfClassifyNum <- function( retChr, trdFileChr, priorNum=0.5, cNum=1e-6, dictChr=NULL )
{
  #---  Assert FOUR (4) arguments:
  #       retChr:       a character vector to be classified
  #       trnFileChr:   a file name for trained data
  #       priorNum:     a numeric value for prior probability of the character vector
  #                     to be classified wrt trnFileChr (default: 0.5) 
  #       cNum:         a numeric value for default probability of a non-trained
  #                     word (default: 1e-6)
  
  #---  Check that arguments are valid
  trdDfr <- fileReadDfr( trdFileChr )
  if( is.null(trdDfr) )
    stop("trdFileChr MUST be a valid file name containing trained data")
  if( as.numeric(priorNum) < 0 | as.numeric(priorNum) > 1 ) 
    stop("priorNum MUST be between ZERO (0) and ONE (1)")
  if( as.numeric(cNum) < 0 | as.numeric(cNum) > 1 ) 
    stop("cNum MUST be between ZERO (0) and ONE (1)")

  retDfr <- pdfConwayDfr( retChr, 2, dictChr )
  
  #---  Find intersections of words
  matchChr <- intersect( retDfr$term, trdDfr$term )
  if( length(matchChr) < 1 )
    retNum <- priorNum * cNum ^ ( length(retDfr$freq) )
  else
  {
    matchNum <- trdDfr$occr[match(matchChr, trdDfr$term)]
    retNum <- priorNum * prod(as.numeric(matchNum)) * 
      cNum ^ ( length(retDfr$freq) - length(matchChr) )
  }
  retNum
}

pdfConwayDfr <- function( retChr, lFreqNum=2, dictChr=NULL, ... )
{
  #---  Assert ONE (1) arguments:                                                   
  #       retChr:       a character vector of training data
  #       lFreqNum:     a number for minDocFreq parameter (default: 2)
  #       ...           additional stopwords
  
  #---  Check that arguments are valid
  if( !is.null(retChr) )
    for( i in 1:length(retChr) )
    {
      if( !is.character(retChr[i]) )
        stop("retChr MUST contain valid text characters")
    }
  else
    stop("retChr MUST contain valid text characters")
  if( !missing(...) )
  {
    addChr <- c(...)
    for( i in 1:length(addChr) )
    {
      if( !is.character(addChr[i]) )
        stop("... MUST contain valid text characters")
    }
  }
  
  #---  Conway's get.tdm() function to transform a character vector
  #       into a TermDocumentMatrix
  #       (1) Make each letter lowercase
  #       (2) Remove punctuation
  #       (3) Remove numbers
  #       (4) Remove generic and custom stopwords
  ret.corpus <- Corpus(VectorSource(retChr))
  ret.corpus <- tm_map(ret.corpus, tolower)
  ret.corpus <- tm_map(ret.corpus, removePunctuation)
  ret.corpus <- tm_map(ret.corpus, removeNumbers)
  if( !missing(...) )
    my_stopwords <- c( stopwords('english'), ... )
  else
    my_stopwords <- c( stopwords('english') )
  ret.corpus <- tm_map(ret.corpus, removeWords, my_stopwords)
  
  if( is.null(dictChr) )
    control.list <- list( minDocFreq=lFreqNum )
  else
    control.list <- list( minDocFreq=lFreqNum, dictionary=dictChr )
  retTdm <- TermDocumentMatrix(ret.corpus, control.list)
  
#---  Conway's method to transform a TermDocumentMatrix into a data.frame
#       Count of words
#       Compute occurrences
#       Compute density
#       Order by highest occurrences
  retMtx <- as.matrix(retTdm)
  retNum <- rowSums(retMtx)
  retDfr <- data.frame( cbind(names(retNum),
                              as.numeric(retNum)),
                        stringsAsFactors=FALSE )
  names(retDfr) <- c("term", "freq")
  retDfr$freq <- as.numeric(retDfr$freq)
  
  occNum <- sapply(1:nrow(retMtx), function(i) {
    length(which(retMtx[i,] > 0))/ncol(retMtx)
  })
  denNum <- retDfr$freq / sum(retDfr$freq)
  
  retDfr <- transform(retDfr, dens=denNum, occr=occNum)
  retDfr <- retDfr[retDfr$freq>=lFreqNum, ]
  retDfr[with(retDfr, order(-occr)), ]
}

pdfNomuraTrainChr <- function(trnFileChr, setBln, waitNum=1, silent=FALSE)
{
  #---  Assert FOUR (4) arguments:
  #       trnFileChr:   string for training data file
  #       setBln:       boolean value to indicate training set to be used (spam: TRUE)
  #       waitNum:      integer value for seconds to wait between EACH query (default: 1) 
  #       silent:       boolean value for displaying console messages (default: FALSE)
  
  #---  Check that arguments are valid
  trnDfr <- fileReadDfr( trnFileChr )
  if( is.null(trnDfr) )
    stop("trnFileChr MUST be a valid file name containing data with AT LEAST TWO (2) columns (id,spam)")
  if( !is.logical(setBln) )
    stop("setBln MUST be TRUE OR FALSE (spam: T; nonspam: F)")
  if( as.numeric(waitNum) < 1 | as.numeric(waitNum) > 20 ) 
    stop("waitNum MUST be between ONE (1) and TWENTY (20)")
  
  #---  Initialize variables
  trnDfr <- trnDfr[trnDfr$spam==setBln,]
  trnChr <- NULL
  
  siteChr <- "http://www.kelive.com/KimEng/servlet/PDFDownloadViaEmail?source=0&rid="
  suffixChr <- "&uid=32549&ky=12557"
  
  #---  Initialize page rank
  #       Page rank is the count of gaps between pids
  #       Save last pid that has a valid PDF
  #       Set warnings to generate an error
  pr <- 0
  retNum <- 0
  optWarnNum <- options()$warn
  for( i in 1:nrow(trnDfr) )
  {
    pidNum <- trnDfr[i, 1]
    
    urlChr <- paste0(siteChr, pidNum, suffixChr)
    tmpFileChr <- tempfile(fileext = ".pdf")
    options(warn=2)
    errNum <- tryCatch( download.file(urlChr, tmpFileChr, mode = "wb", quiet=silent),
                        error=function(e) { 9999 }, finally={} )
    options(warn=0)
    #---  Error can occur in THREE (3) ways
    #       (1) download.file() returns an error
    #       (2) download.file() returns ok, but PDF file does not exists
    #       (3) download.file() returns ok, and PDF file exists, 
    #           but it is damaged
    if( errNum == 9999 | errNum > 0 )
      pr <- pr + 1
    else if( !file.exists(tmpFileChr) )
      pr <- pr + 1
    else
    {
      #---  Downloaded file
      #       Parse text of PDF to see if it is of interest
      #       Save last pid that is a valid PDF
      #       Move PDF from temp folder to R-nonsource
      
      txtChr <- pdfParseChr( tmpFileChr )
      if(is.null(txtChr))
        pr <- pr + 1
      else
      {
        trnChr <- c( trnChr, paste(txtChr, collapse="") )
        retNum <- retNum + 1
      }
      file.remove( tmpFileChr )
    }
    
    Sys.sleep(waitNum)
  }
  options(warn=optWarnNum)
  
  trnChr
}

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
pdfGmailNum <- function( tmpFileChr,  toChr, ccChr=NULL, 
                         subjChr="Maybank KE Report", msgFileChr=NULL, 
                         exeChr="/usr/bin/mailx" )
{
  #---  Assert SIX (6) arguments:                                                   
  #       tmpFileChr:   a character vector for file attachments
  #       toChr:        a character vector for To recipients
  #       ccChr         a character vector for Cc recipients (default: NULL)
  #       subjChr:      a string for subject header (default: "Maybank KE Report")
  #       msgFileChr:   a string for message file (default: NULL)
  #       exeChr        a string for executable file
  #       retNum        a numeric error code (success: 0)
  
  #---  Check that arguments are valid
  if( !file.exists(tmpFileChr) )
    stop("File attachment tmpFileChr MUST exists.")
  if( !is.null(msgFileChr) )
  {
    if( !file.exists(msgFileChr) )
      stop("Message file msgFileChr MUST exists.")
  }
  for( i in 1:length(toChr) )
  {
    if( !RegIsEmailBln(toChr[i]) )
      stop("To recipients MUST contain valid email formats")
  }
  if( !is.null(ccChr) )
    for( i in 1:length(ccChr) )
    {
      if( !RegIsEmailBln(ccChr[i]) )
        stop("Cc recipients MUST contain valid email formats")
    }
  
  #---  Initialize variables
  if( length(Sys.which("mailx"))==0 )
    exChr <- exeChr
  else
    exChr <- Sys.which("mailx")
  if( length(toChr)==1 )
    tChr <- toChr
  else
  {
    tChr <- ""
    for( i in 1:length(toChr) )
      tChr <- paste(tChr,toChr[i],sep=",")
  }
  if( length(ccChr)==1 )
    cChr <- ccChr
  else
  {
    cChr <- ""
    for( i in 1:length(ccChr) )
      cChr <- paste(cChr,ccChr[i],sep=",")
  }
  
  
  dq <- "\""
  cmdChr <- paste0(dq,exChr,dq," -c ",cChr," -a ",dq,tmpFileChr,dq," -A gmail ",
                   "-s ",dq,subjChr,dq," ",tChr) 
  if( !is.null(msgFileChr) )
    cmdChr <- paste0(cmdChr, " < ",dq,msgFileChr,dq)
  errNum <- RegSystemNum(cmdChr)
  
  errNum
}

pdfParseChr <- function( tmpFileChr, exeChr="/usr/bin/pdftotext" )
{
  if( length(Sys.which("pdftotext"))==0 )
    exChr <- exeChr
  else
    exChr <- Sys.which("pdftotext")
  
  cmdChr <- paste0("\"", exChr, "\" \"", tmpFileChr, "\"")
  errNum <- RegSystemNum(cmdChr)
  
  if(errNum > 0) return(NULL)
  
  # get txt-file name and open it
  txtFileChr <- sub(".pdf", ".txt", tmpFileChr)
  fileDfr <- file.info(tmpFileChr)
  readLines(txtFileChr, warn=FALSE); 
}

pdfSearchCountryNum <- function( txtChr, retFileChr="pdfNomuraCountry" )
{
  if( nchar(retFileChr) != 0 )
    retDfr <- fileReadDfr( retFileChr )
  else
    retDfr <- NULL
  if( is.null(retDfr) )
  {
    pCountryChr <- c("Asean",
                     "Asia",
                     "Singapore", "SGD",
                     "Indonesia", "INR",
                     "Malaysia", "MYR",
                     "Hong Kong", "HKD",
                     #"China",
                     "Australia", "AUD",
                     "Canada", "CAD",
                     "Global")
    nCountryChr <- c("LatAm", "Emerging",
                     "Argentina", "ARS", "Boden", "Bonar",
                     "Brazil", "Brazilian", "BCB", "Selic",
                     "Japan", "JPY",
                     "Korea", "KRW",
                     "Taiwan", "TWD",
                     "Europe", "Eurozone", "European", "Euro Area",
                     "USA", 
                     "Mexico",
                     "Chile")                   
  }
  else
  {
    #---  Split data frame into character vectors
    #       Remove NAs from vectors
    #     Note: When editing file manually, use "NA" for NA
    pCountryChr <- retDfr[, 1]
    nCountryChr <- retDfr[, 2]
    pCountryChr <- pCountryChr[!is.na(pCountryChr)]
    nCountryChr <- pCountryChr[!is.na(nCountryChr)]
  }
  return( RegSearchNum(txtChr, pCountryChr, nCountryChr) )
}

pdfSearchIndustryNum <- function( txtChr, retFileChr="pdfNomuraIndustry" )
{
  if( nchar(retFileChr) != 0 )
    retDfr <- fileReadDfr( retFileChr )
  else
    retDfr <- NULL
  if( is.null(retDfr) )
  {
    pIndustryChr <- c("Commodity", "Commodities",
                      "Dividend",
                      "Forex",
                      "Currency", "Currencies",
                      "Equity", "Equities",
                      "Economics", "policy",
                      "FOMC", "Federal Reserve", "Chairman", "Bernanke"
    )
    nIndustryChr <- c("Health", "Health care", "Laboratories", "Biologi",
                      "patent",
                      "Fixed Income", "butterfly", "swap", "bond",
                      "coupon", "stacks",
                      "inflation", "forward real",
                      "mortgage", "loan"
    )
  }
  else
  {
    #---  Split data frame into character vectors
    #       Remove NAs from vectors
    #     Note: When editing file manually, use "NA" for NA
    pIndustryChr <- retDfr[, 1]
    nIndustryChr <- retDfr[, 2]
    pIndustryChr <- pIndustryChr[!is.na(pIndustryChr)]
    nIndustryChr <- nIndustryChr[!is.na(nIndustryChr)]
  }
  return( RegSearchNum(txtChr, pIndustryChr, nIndustryChr) )
}

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
