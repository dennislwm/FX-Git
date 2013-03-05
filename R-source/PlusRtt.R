#|------------------------------------------------------------------------------------------|
#|                                                                                PlusRtt.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The script contains generalized wrapper functions for the library RTextTools.         |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This library contains external R functions to perform large text classification.|
#|------------------------------------------------------------------------------------------|
library(RTextTools)

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
RttBoot.ctn <- function(data, trainNum, testNum=NULL, seedNum=1234, 
                        minSize=10, replace=FALSE, virgin=FALSE, 
                        removeNumber=TRUE, removePunctuation=FALSE, stemWords=FALSE)
{
  if( as.numeric(minSize) < 0 )
    stop("minSize MUST be greater than OR equal to ONE (1)")
  if( as.numeric(trainNum) < minSize ) 
    stop("trainNum MUST be greater than OR equal to minSize")
  if( is.null(testNum) )
    testNum <- nrow(data) - trainNum
  if( as.numeric(testNum) < minSize )
    stop("testNum MUST be greater than OR equal to minSize")
  
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
  text.data     <- mixed.data$text
  outcome.data  <- mixed.data$outcome
  matrix    <- create_matrix(text.data, 
                             weighting=weightTfIdf,
                             removeNumber=removeNumber, 
                             removePunctuation=removePunctuation,
                             stemWords=stemWords)
  container <- create_container(matrix, 
                                t(outcome.data), 
                                trainSize=1:trainNum, 
                                testSize=(trainNum+1):nrow(data), 
                                virgin=virgin)
  container
}

RttFeed.mdl <- function(container, algo="MAXENT")
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
                    "result"    = result )
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
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
