#|------------------------------------------------------------------------------------------|
#|                                                                            PlusAddThat.R |
#|                                                             Copyright © 2012, Dennis Lee |
#|                                                                                          |
#| Assert History                                                                           |
#|  0.9.1   Added functions to validate parameters that are TWO(2)-dimensions, e.g. check   |
#|          for number of rows/cols, names. The function AddTypeM() has been superceded by  |
#|          AddNamexxx() functions.                                                         |
#|  0.9.0   This library contains external R functions to validate parameters of functions. |
#|          The naming convention is that a function with suffix "N", e.g. AddExistN(),     |
#|          is categorized as a multi-validation function, as opposed to a single           |
#|          -validation function, e.g. AddExists(). Todo: Functions to validate parameters  |
#|          that are TWO(2)-dimensions, e.g. a data frame (dfr, zoo, xts) and a matrix.     |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                            M U L T I P L E   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
AddExistN <- function(a)
{
  nameStr <- deparse(substitute(a))
  stopStr <- AddAvoid(a, nameStr)
  if( !is.null(stopStr) ) 
    return( stopStr )
  stopStr <- AddAvoidI(a, nameStr)
  if( !is.null(stopStr) ) 
    return( stopStr )
  stopStr <- AddAvoidA(a, nameStr)
  if( !is.null(stopStr) ) 
    return( stopStr )
  stopStr <- AddExists(a, nameStr)
  if( !is.null(stopStr) ) 
    return( stopStr )
  return( NULL )  
}
AddAvoidN <- function(a)
{
  nameStr <- deparse(substitute(a))
  stopStr <- AddAvoid(a, nameStr)
  if( !is.null(stopStr) ) 
    return( stopStr )
  stopStr <- AddAvoidI(a, nameStr)
  if( !is.null(stopStr) ) 
    return( stopStr )
  stopStr <- AddAvoidA(a, nameStr)
  if( !is.null(stopStr) ) 
    return( stopStr )
  return( NULL )  
}
#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
AddNameMatchE <- function(a, typeChr)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0(nameStr, " MUST be exactly ALL of: ", paste0(typeChr, collapse=", "))
  isOfBln <- sapply(typeChr, function(x) {any(x==a)})
  stopBln <- suppressWarnings(sum(isOfBln) != length(typeChr) 
                              | length(isOfBln) != length(typeChr)
                              | length(isOfBln) != length(a))
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddNameMatch <- function(a, typeChr)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0(nameStr, " MUST be at least ALL of: ", paste0(typeChr, collapse=", "))
  isOfBln <- sapply(typeChr, function(x) {any(x==a)})
  stopBln <- suppressWarnings(sum(isOfBln) != length(typeChr)
                               | length(isOfBln) != length(typeChr))
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddNameExists <- function(a, typeChr)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0(nameStr, " MUST be ONE (1) of: ", paste0(typeChr, collapse=", "))
  isOfBln <- sapply(typeChr, function(x) {any(x==a)})
  stopBln <- suppressWarnings(sum(isOfBln) != 1
                              | length(isOfBln) < 1 
                              | length(a) != 1 )
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddNameBetween <- function(a, typeChr)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0(nameStr, " MUST be ONE (1) OR MORE of: ", paste0(typeChr, collapse=", "))
  isOfBln <- sapply(typeChr, function(x) {any(x==a)})
  stopBln <- suppressWarnings(sum(isOfBln) < 1
                              | length(isOfBln) < 1 
                              | length(isOfBln) > length(typeChr)
                              | length(isOfBln) != length(a))
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddColEqual <- function(a, m)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0("Number of cols for ", nameStr, " MUST be equal to ", m)
  stopBln <- ncol(a) != m
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddColMore <- function(a, m)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0("Number of cols for ", nameStr, " MUST be greater than ", m)
  stopBln <- ncol(a) <= m
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddColMoreE <- function(a, m)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0("Number of cols for ", nameStr, " MUST be greater than OR equal to ", m)
  stopBln <- ncol(a) < m
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddRowMore <- function(a, m)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0("Number of rows for ", nameStr, " MUST be greater than ", m)
  stopBln <- nrow(a) <= m
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddRowMoreE <- function(a, m)
{
  nameStr <- deparse(substitute(a))
  stopStr <- paste0("Number of rows for ", nameStr, " MUST be greater than OR equal to ", m)
  stopBln <- nrow(a) < m
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddEqual <- function(n, m)
{
  nameStr <- deparse(substitute(n))
  stopStr <- paste0(nameStr, " MUST be equal to ", m)
  stopBln <- length(which( n != m ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddNotEqual <- function(n, m)
{
  nameStr <- deparse(substitute(n))
  stopStr <- paste0(nameStr, " MUST NOT be equal to ", m)
  stopBln <- length(which( n == m ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddLess <- function(n, uppNum)
{
  nameStr <- deparse(substitute(n))
  stopStr <- paste0(nameStr, " MUST be less than ", uppNum)
  stopBln <- length(which( n >= uppNum ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddLessE <- function(n, uppNum)
{
  nameStr <- deparse(substitute(n))
  stopStr <- paste0(nameStr, " MUST be less than OR equal to ", uppNum)
  stopBln <- length(which( n > uppNum ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddMore <- function(n, lowNum)
{
  nameStr <- deparse(substitute(n))
  stopStr <- paste0(nameStr, " MUST be greater than ", lowNum)
  stopBln <- length(which( n <= lowNum ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddMoreE <- function(n, lowNum)
{
  nameStr <- deparse(substitute(n))
  stopStr <- paste0(nameStr, " MUST be greater than OR equal to ", lowNum)
  stopBln <- length(which( n < lowNum ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddBetween <- function(n, lowNum, uppNum)
{
  nameStr <- deparse(substitute(n))
  stopStr <- paste0(nameStr, " MUST be between ", lowNum, " AND ", uppNum)
  stopBln <- length(which( n < lowNum | n > uppNum ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddAvoid <- function(a, nameStr=NULL)
{
  if( is.null(nameStr) ) 
    nameStr <- deparse(substitute(a))
  stopStr <- paste0(nameStr, " CANNOT be NULL")
  stopBln <- length(which( is.null(a) ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddAvoidI <- function(a, nameStr=NULL)
{
  if( is.null(nameStr) ) 
    nameStr <- deparse(substitute(a))
  stopStr <- paste0(nameStr, " CANNOT be ONE (1) of: character(0), numeric(0), 
                    logical(0), integer(0), data.frame(NULL)")
  stopBln <- length(which( identical(a, character(0))
                           | identical(a, numeric(0))
                           | identical(a, logical(0))
                           | identical(a, integer(0))
                           | identical(a, data.frame())))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddAvoidA <- function(a, nameStr=NULL)
{
  if( is.null(nameStr) ) 
    nameStr <- deparse(substitute(a))
  stopStr <- paste0(nameStr, " CANNOT be NA")
  stopBln <- length(which( is.na(a) ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
AddExists <- function(a, nameStr=NULL)
{
  if( is.null(nameStr) ) 
    nameStr <- deparse(substitute(a))
  stopStr <- paste0(nameStr, " MUST exists")
  stopBln <- length(which( !file.exists(a) ))>0
  if( stopBln )
    return( stopStr )
  return( NULL )
}
#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|