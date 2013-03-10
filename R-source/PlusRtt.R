#|------------------------------------------------------------------------------------------|
#|                                                                                PlusRtt.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The script contains generalized wrapper functions for the library RTextTools.         |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.2   Added unit test script in "R-test-06-Rtt" 1.0.0 for functions RttTrainDoDfr(),  |
#|            RttTrainCheckDfr() and RttTrainPlan.ctn(). Assertions would be included OR    |
#|            errors fixed in these functions.                                              |
#|  1.0.1   The external functions RttBoot.ctn() and RttFeed.mdl() have been replaced by    |
#|            RttTrainPlan.ctn() and RttTrainAct.mdl() respectively. The former function    |
#|            returns a list consisting of a container, which is EITHER a virgin OR NON     |
#|            virgin, depending on the data. If the data contains outcomes with NAs, then   |
#|            the container is a virgin. The latter function accepts EITHER a virgin OR NON |
#|            virgin container, and returns a list containing EITHER the result OR analytic |
#|            respectively. The internal functions RttTrainDoDfr() and RttTrainCheckDfr()   |
#|            are called by RttTrainPlan.ctn() exclusively.                                 |
#|  1.0.0   This library contains external R functions to perform large text classification.|
#|------------------------------------------------------------------------------------------|
library(RTextTools)

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
RttTrainPlan.ctn <- function(data, trainNum, testRng=NULL, seedNum=1234, minSize=10, replace=FALSE, 
                             removeNumber=TRUE, removePunctuation=FALSE, stemWords=FALSE)
{
  if( length(which(names(data)=="outcome")) < 1 )
    stop("data MUST contain the 'outcome' column")
  if( length(which(names(data)=="text")) < 1 )
    stop("data MUST contain the 'text' column")
  if( length(which(sapply(as.character(data$text), nchar) < 10)) > 0 )
    stop("data$text cannot consists of rows with small text, i.e. LESS THAN TEN (10) characters in length")
  
  planBln <- sum(is.na(data$outcome)) > 0
  if( planBln )
  {
    mixed.data  <- RttTrainCheckDfr(data, trainNum, testRng=testRng, seedNum=seedNum, minSize=minSize)
    virginBln   <- TRUE
  }
  else
  {
    mixed.data  <- RttTrainDoDfr(data, trainNum, testNum=NULL, seedNum=seedNum, minSize=minSize, replace=replace) 
    virginBln   <- FALSE
  }
  text.data     <- mixed.data$text
  outcome.data  <- mixed.data$outcome
  mat       <- create_matrix(text.data, 
                             weighting=weightTfIdf,
                             removeNumber=removeNumber, 
                             removePunctuation=removePunctuation,
                             stemWords=stemWords)
  container <- create_container(mat, 
                                t(outcome.data), 
                                trainSize=1:trainNum, 
                                testSize=(trainNum+1):nrow(mixed.data), 
                                virgin=virginBln)
  ret.list <- list( "call"      = match.call(),
                    "trainNum"  = trainNum,
                    "seedNum"   = seedNum,
                    "container" = container )
  ret.list
}

RttTrainAct.mdl <- function(container, algo="MAXENT")
{
  typeStr <- c("BAGGING","BOOSTING","GLMNET","MAXENT","NNET","RF","SLDA","SVM","TREE")
  if( length(which(typeStr==algo)) == 0 )
    stop("algo MUST be either: ", paste(typeStr, collapse=' '))
  
  model     <- train_model(container, algo)
  result    <- classify_model(container, model)
  if( container@virgin == FALSE)
  {
    analytic  <- create_analytics(container, result)
    doc       <- analytic@document_summary
    spam.doc  <- doc[doc$MANUAL_CODE==4, ]
    ham.doc   <- doc[doc$MANUAL_CODE==2, ]
    true.pos  <- nrow(spam.doc[spam.doc$CONSENSUS_CODE==4,]) / nrow(spam.doc)
    false.neg <- nrow(spam.doc[spam.doc$CONSENSUS_CODE==2,]) / nrow(spam.doc)
    true.neg  <- nrow(ham.doc[ham.doc$CONSENSUS_CODE==2,]) / nrow(ham.doc)
    false.pos <- nrow(ham.doc[ham.doc$CONSENSUS_CODE==4,]) / nrow(ham.doc)
  }
  
  ret.list <- list( "call"      = match.call(),
                    "virgin"    = container@virgin,
                    "model"     = model,
                    "result"    = result,
                    "outcome"   = as.numeric(as.character(result[,1])) )
  if( container@virgin == FALSE )
  {
    ret.list <- c(ret.list,                     
                  "analytic"  = analytic,
                  "doc"       = doc,
                  "spam.doc"  = spam.doc,
                  "ham.doc"   = ham.doc,
                  "true.pos"  = true.pos,
                  "false.neg" = false.neg,
                  "true.neg"  = true.neg,
                  "false.pos" = false.pos )
  }
  ret.list
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
RttTrainDoDfr <- function(data, trainNum, testNum=NULL, seedNum=1234, minSize=10, replace=FALSE)
{
  if( as.numeric(minSize) < 1 )
    stop("minSize MUST be greater than OR equal to ONE (1)")
  if( as.numeric(trainNum) < minSize ) 
    stop("trainNum MUST be greater than OR equal to minSize")
  if( ncol(data) < 2 )
    stop("ncol(data) MUST be greater than OR equal to TWO (2)")
  if( as.numeric(trainNum) >= nrow(data) ) 
    stop("trainNum MUST be less than nrow(data)")
  if( is.null(testNum) )
    testNum <- nrow(data) - trainNum
  if( as.numeric(testNum) < 1 )
    stop("testNum MUST be greater than OR equal to ONE (1)")
  if( as.numeric(trainNum+testNum) > nrow(data) )
    stop("(testNum+trainNUm) CANNOT be larger than nrow(data)")
  
  
  set.seed(seedNum)
  if( replace )
  {
    train.data  <- data[ sample(1:nrow(data), size=trainNum, replace=TRUE), ]
    test.data   <- data[ sample(1:nrow(data), size=testNum, replace=TRUE), ]
    mixed.data  <- rbind(train.data, test.data)
    names(mixed.data) <- names(data)
  } else
  {
    mixed.data  <- data[ sample(1:nrow(data), size=(trainNum+testNum), replace=FALSE), ]
  }
  mixed.data
}
RttTrainCheckDfr <- function(data, trainNum, testRng=NULL, seedNum=1234, minSize=10)
{
  if( as.numeric(minSize) < 1 )
    stop("minSize MUST be greater than OR equal to ONE (1)")
  if( as.numeric(trainNum) < minSize ) 
    stop("trainNum MUST be greater than OR equal to minSize")
  if( ncol(data) < 2 )
    stop("ncol(data) MUST be greater than OR equal to TWO (2)")
  if( length(which(names(data)=="outcome")) < 1 )
    stop("data MUST contain the 'outcome' column")
  if( sum(is.na(data$outcome)) < 1 )
    stop("data$outcome MUST contain at least ONE (1) incomplete row (NA)")
  if( nrow(data[complete.cases(data),]) < 1 )
    stop("data$outcome MUST contain at least ONE (1) complete case")
  if( as.numeric(trainNum) > nrow(data[complete.cases(data),]) ) 
    stop("trainNum MUST be less than OR equal to the number of complete cases in data")
  if( is.null(testRng) )
  {
    minIdx  <- min(which(is.na(data$outcome)))
    maxIdx  <- max(which(is.na(data$outcome)))
    testRng <- minIdx:maxIdx
  }
  if( min(testRng) < 0 )
    stop("testRng is out of bounds")
  if( max(testRng) > nrow(data) )
    stop("testRng is out of bounds")
  if( sum(!is.na(data$outcome[testRng])) > 0 )
    stop("testRng MUST consists of data$outcome with incomplete rows ONLY")
  if( sum(is.na(data$outcome[testRng])) < 1 )
    stop("testRng MUST consists of data$outcome with incomplete rows ONLY")
  
  set.seed(seedNum)
  train.data  <- data[ 1:trainNum, ]
  test.data   <- data[ testRng, ]
  mixed.data  <- rbind(train.data, test.data)
  names(mixed.data) <- names(data)
  mixed.data  
}

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
