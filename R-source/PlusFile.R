#|------------------------------------------------------------------------------------------|
#|                                                                               PlusFile.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Function                                                                          |
#|                                                                                          |
#|    (1) Read ONE (1) OR MORE CSV files into a data frame. If there are more than ONE (1)  |
#|        file, each file is suffix by "_partxxx", where xxx is 001 to 999.                 |
#|                                                                                          |
#|        fileReadDfr <- function( fileStr, partNum, workDirStr ) {                         |
#|        #---  Assert THREE (3) arguments:                                                 |
#|        #       fileStr:      name of the file (without the suffix "_partxxx" and         |
#|        #                     extension ".csv")                                           |
#|        #       partNum:      number of parts (default: 1)                                |
#|        #       workDirStr:   working directory (default: "C:/Users/denbrige/100 FxOption |
#|        #                     /103 FxOptionVerBack/080 Fx Git/R-nonsource"                |
#|        }                                                                                 |
#|                                                                                          |
#|    (2) Write a data frame into ONE (1) CSV file.                                         |
#|                                                                                          |
#|        fileWriteCsv <- function( datDfr, fileStr, workDirStr ) {                         |
#|        #---  Assert THREE (3) arguments:                                                 |
#|        #       datDfr:       data frame to be written                                    |
#|        #       fileStr:      name of the file (without the extension ".csv")             |
#|        #       workDirStr:   working directory (default: "C:/Users/denbrige/100 FxOption |
#|        #                     /103 FxOptionVerBack/080 Fx Git/R-nonsource"                |
#|        }                                                                                 |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.1   Created unit test file testPlusFile.R to test read and write functions.         |
#|  1.0.0   Contains R functions to manipulate data to and from files.                      |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                                M A I N   F U N C T I O N S                               |
#|------------------------------------------------------------------------------------------|
fileWriteCsv <- function(datDfr, fileStr, 
                          workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert THREE (3) arguments:                                                   
  #       datDfr:       data frame to be written                                               
  #       fileStr:      name of the file (without the extension ".csv")
  #       workDirStr:   working directory                                             
  
  #---  Check that arguments are valid
  #       apply() function returns a list of arrays
  #       sapply() function returns a vector of numbers
  gLst <- apply(datDfr, 2, grep, pattern=",")
  if( length(gLst)>0 )
  {
    if( sum(sapply(gLst,sum))>0 )
      stop("ONE (1) OR MORE columns in datStr contain comma as values.")
  }
  if( missing(fileStr) )
    stop("fileStr CANNOT be EMPTY")
  else if( fileStr=="" )
    stop("fileStr CANNOT be EMPTY")
  
  #---  Set working directory                                                         
  setwd(workDirStr)
  #---  Write data
  #       Remove quotes from characters
  #       Remove row names 
  write.table( datDfr, file=paste0( fileStr, ".csv" ), sep=",", quote=FALSE, row.names=FALSE )
}

fileReadDfr <- function(fileStr, partNum=1, 
                          workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource", ...)
{
  #---  Assert THREE (3) arguments:                                                   
  #       fileStr:      name of the file (without the suffix "_partxxx" and extension ".csv")
  #       partNum:      number of parts                                               
  #       workDirStr:   working directory                                             
  
  #---  Check that partNum is valid (between 1 to 999)                                 
  if( missing(fileStr) )
    stop("fileStr CANNOT be EMPTY")
  else if( fileStr=="" )
    stop("fileStr CANNOT be EMPTY")
  if( as.numeric(partNum) < 1 || as.numeric(partNum) > 999 ) 
    stop("partNum MUST be between 1 AND 999")
  
  #---  Set working directory                                                         
  setwd(workDirStr)
  #---  Read data from split parts
  #       Append suffix to the fileStr
  #       Read each part and merge them together
  
  if( as.numeric(partNum) > 1 )
  {
    if( !file.exists( paste0( fileStr, "_part001.csv" ) ) ) return( NULL )
    tryDfr <- tryCatch( retDfr <- read.csv( paste0( fileStr, "_part001.csv" ), colClasses = "character", sep=",", ... ),
                        error=function(e) { NULL }, finally={} )
    if( is.null(tryDfr) ) return( NULL )
    
    for( id in 2:partNum )
    {
      #---  rbind() function will bind two data frames with the same header together
      partStr <- paste( fileStr, "_part", sprintf("%03d", as.numeric(id)), ".csv", sep="" )
      if( !file.exists( partStr ) ) 
        return( retDfr )
      tmpDfr <- read.csv( partStr, colClasses = "character", sep=",", ... )
      retDfr <- rbind( retDfr, tmpDfr )
    }
  }
  else
  {
    if( !file.exists( paste0( fileStr, ".csv" ) ) ) return( NULL )
    tryDfr <- tryCatch( retDfr <- read.csv( paste0( fileStr, ".csv" ), colClasses = "character", sep=",", ... ),
                   error=function(e) { NULL }, finally={} )
    if( is.null(tryDfr) ) return( NULL )
  }
  
  #---  Return a data frame
  return(retDfr)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
