suppressPackageStartupMessages(require(RTextTools))
suppressPackageStartupMessages(require(tm))
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
spam.dir <- paste0(RegGetRNonSourceDir(), "spamassassin/")
get.msg <- function(path.dir)
{
  con <- file(path.dir, open="rt", encoding="latin1")
  text <- readLines(con)
  msg <- text[seq(which(text=="")[1]+1,length(text),1)]
  close(con)
  return(paste(msg, collapse="\n"))
}
get.msg.try <- function(path.dir)
{
  con <- file(path.dir, open="rt", encoding="latin1")
  text <- readLines(con)
  options(warn=-1)
  msg <- tryCatch( text[seq(which(text=="")[1]+1,length(text),1)],
                   error=function(e) { 9999 }, finally={} )
  close(con)
  if( substr(msg, 1, 5)=="Error" ) 
  {
    return("Error")
  }
  else 
  {
    return(paste(msg, collapse="\n"))
  }
}
get.all <- function(path.dir)
{
  all.file <- dir(path.dir)
  all.file <- all.file[which(all.file!="cmds")]
  msg.all <- sapply(all.file, function(p) get.msg(paste0(path.dir,p)))
}
get.all.try <- function(path.dir)
{
  all.file <- dir(path.dir)
  all.file <- all.file[which(all.file!="cmds")]
  msg.all <- sapply(all.file, function(p) get.msg.try(paste0(path.dir,p)))
}
easy_ham.all    <- get.all(paste0(spam.dir, "easy_ham/"))
easy_ham_2.all  <- get.all(paste0(spam.dir, "easy_ham_2/"))
hard_ham.all    <- get.all(paste0(spam.dir, "hard_ham/"))
hard_ham_2.all  <- get.all(paste0(spam.dir, "hard_ham_2/"))
spam.all        <- get.all.try(paste0(spam.dir, "spam/"))
spam_2.all      <- get.all(paste0(spam.dir, "spam_2/"))

easy_ham.dfr    <- as.data.frame(easy_ham.all)
easy_ham_2.dfr  <- as.data.frame(easy_ham_2.all)
hard_ham.dfr    <- as.data.frame(hard_ham.all)
hard_ham_2.dfr  <- as.data.frame(hard_ham_2.all)
spam.dfr        <- as.data.frame(spam.all)
spam_2.dfr      <- as.data.frame(spam_2.all)
rownames(easy_ham.dfr)    <- NULL
rownames(easy_ham_2.dfr)  <- NULL
rownames(hard_ham.dfr)    <- NULL
rownames(hard_ham_2.dfr)  <- NULL
rownames(spam.dfr)        <- NULL
rownames(spam_2.dfr)      <- NULL
easy_ham.dfr$outcome    <- 2
easy_ham_2.dfr$outcome  <- 2
hard_ham.dfr$outcome    <- 2
hard_ham_2.dfr$outcome  <- 2
spam.dfr$outcome        <- 4
spam_2.dfr$outcome      <- 4
names(easy_ham.dfr)   <- c("text", "outcome")
names(easy_ham_2.dfr) <- c("text", "outcome")
names(hard_ham.dfr)   <- c("text", "outcome")
names(hard_ham_2.dfr) <- c("text", "outcome")
names(spam.dfr)       <- c("text", "outcome")
names(spam_2.dfr)     <- c("text", "outcome")
train.data  <- rbind(easy_ham.dfr, hard_ham.dfr, spam.dfr)
train.num   <- nrow(train.data)
train.data  <- rbind(train.data, easy_ham_2.dfr, hard_ham_2.dfr, spam_2.dfr)
names(train.data) <- c("text", "outcome")
spam.str <- paste0(RegGetRNonSourceDir(),"Jurka_03_spam.rda")
if( !file.exists(spam.str) )
{
  save(train.data, train.num, file=spam.str)
}

set.seed(2012)
train_out.data <- train.data$outcome
train_txt.data <- train.data$text

matrix <- create_matrix(train_txt.data, language="english", minWordLength=3, removeNumbers=TRUE, stemWords=FALSE, removePunctuation=TRUE, weighting=weightTfIdf)
container <- create_container(matrix,t(train_out.data), trainSize=1:train.num, testSize=(train.num+1):nrow(train.data), virgin=FALSE)
maxent.model    <- train_model(container, "MAXENT")
svm.model       <- train_model(container, "SVM")

svm.result    <- classify_model(container, svm.model)
svm.analytic  <- create_analytics(container, svm.result)
svm.doc       <- svm.analytic@document_summary
svm_spam.doc  <- svm.doc[svm.doc$MANUAL_CODE==4, ]
svm_ham.doc   <- svm.doc[svm.doc$MANUAL_CODE==2, ]
svm.true.pos  <- nrow(svm_spam.doc[svm_spam.doc$CONSENSUS_CODE==4,]) / nrow(svm_spam.doc)
svm.false.neg <- nrow(svm_spam.doc[svm_spam.doc$CONSENSUS_CODE==2,]) / nrow(svm_spam.doc)
svm.true.neg  <- nrow(svm_ham.doc[svm_ham.doc$CONSENSUS_CODE==2,]) / nrow(svm_ham.doc)
svm.false.pos <- nrow(svm_ham.doc[svm_ham.doc$CONSENSUS_CODE==4,]) / nrow(svm_ham.doc)
maxent.result   <- classify_model(container, maxent.model)
maxent.analytic <- create_analytics(container, maxent.result)
maxent.doc      <- maxent.analytic@document_summary
maxent_spam.doc <- maxent.doc[maxent.doc$MANUAL_CODE==4, ]
maxent_ham.doc  <- maxent.doc[maxent.doc$MANUAL_CODE==2, ]
maxent.true.pos <- nrow(maxent_spam.doc[maxent_spam.doc$CONSENSUS_CODE==4,]) / nrow(maxent_spam.doc)
maxent.false.neg<- nrow(maxent_spam.doc[maxent_spam.doc$CONSENSUS_CODE==2,]) / nrow(maxent_spam.doc)
maxent.true.neg <- nrow(maxent_ham.doc[maxent_ham.doc$CONSENSUS_CODE==2,]) / nrow(maxent_ham.doc)
maxent.false.pos<- nrow(maxent_ham.doc[maxent_ham.doc$CONSENSUS_CODE==4,]) / nrow(maxent_ham.doc)
