#|------------------------------------------------------------------------------------------|
#|                                                             Leek_07_quiz7_randomForest.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Motivational Buckets                                                                     |
#|    The questions in Quiz 7 is based on the lectures for Week 7, which is primarily       |
#|  focused on smoothing, bootstrapping, ensembling and random forests.                     |
#|                                                                                          |
#| Background                                                                               |
#|    The libraries and functions used in this quiz are as follows:                         |
#|    (1) splines:      ns()                                                                |
#|    (2) medley:       rmse()                                                              |
#|    (3) simpleboot:   one.boot()                                                          |
#|    (4) tree:         tree()                                                              |
#|    (5) randomForest: randomForest()                                                      |
#|        e1071:        svm()                                                               |
#|                                                                                          |
#|    The package "medley" can be installed using the following R commands:                 |
#|  > library(devtools)                                                                     |
#|  > install_github("medley", "mewo2")                                                     |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Data Analysis (Jeffrey Leek) Quiz 7 Week 7:                            |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)

#---  Question 2 - Splines
#       1) Define a data set
#       2) Fit linear models with the yValues as outcome and a natural cubic spline model 
#           for the xValues as the covariates, i.e. use function ns() in library(splines).
#       3) Fit the model with degrees of freedom equal to each integer between 1 and 10.
#       4) For EACH model, calculate the root mean squared error (RMSE) between the fitted 
#           values and the observed yValues, use function rmse() from library(medley).
#       5)  At what number of degrees of freedom is there the most dramatic drop in the RMSE?
library(splines)
set.seed(53535)
xValues = seq(0,2*pi,length=100)
yValues = rnorm(100) + sin(xValues)
rmse.lm <- c()
for(n in 1:10)
{
  x.ns    <- ns(xValues, df=n)
  y.lm    <- lm(yValues ~ x.ns)
  rmse.lm <- c(rmse.lm, rmse(yValues, y.lm$fitted))
}
#       5)  At what number of degrees of freedom is there the most dramatic drop in the RMSE?
plot(rmse.lm)

#---  Question 3 - Bootstrap
#       1) Calculate the 75th percentile of the Wind variable.
#       2) Set the seed to 883833 and use the one.boot() function with 1,000 replications
#         a) Create a function q75.FUN(dat, idx) that returns the 75th percentile of a vector.
#         b) Alternatively, we could pass the parameter "probs" to function one.boot().
#       3) Calculate the bootstrap standard error of the 75th percentile of the Wind variable.
library(simpleboot) 
data(airquality)
attach(airquality)
quantile(airquality$Wind, probs=0.75)
set.seed(883833)
q75.FUN <- function(dat, idx) 
{ 
  quantile(dat[idx], probs=0.75) 
}
q75.boot  <- one.boot(airquality$Wind, FUN=q75.FUN, 1000)
q75.se    <- apply(q75.boot$t, 2, sd)

#---  Question 4 - Bootstrap trees (manually coded random forest of a FEW trees)
#       1) Load the data
#       2) Set the seed to 7363 and calculate THREE (3) trees using the tree() function on 
#           bootstrapped samples (samples with replacement). EACH tree should treat the 
#           "DriveTrain" variable as the outcome and "Price" and "Type" as covariates.
#       3) Predict the value of the new data frame with EACH tree.
#       4) Report the majority vote winner along with the percentage of votes among the 
#           THREE (3) trees for that value. 
data(Cars93,package="MASS")
set.seed(7363)
idx1.num  <- sample(1:nrow(Cars93), size=nrow(Cars93), replace=TRUE)
idx2.num  <- sample(1:nrow(Cars93), size=nrow(Cars93), replace=TRUE)
idx3.num  <- sample(1:nrow(Cars93), size=nrow(Cars93), replace=TRUE)
car1.tree <- tree(DriveTrain ~ Price + Type, data=Cars93[ idx1.num, ])
car2.tree <- tree(DriveTrain ~ Price + Type, data=Cars93[ idx2.num, ])
car3.tree <- tree(DriveTrain ~ Price + Type, data=Cars93[ idx3.num, ])
newdata <- data.frame(Type = "Large",Price = 20)
pred1 <- predict(car1.tree, newdata, type="class")
pred2 <- predict(car2.tree, newdata, type="class")
pred3 <- predict(car3.tree, newdata, type="class")

#---  Question 5 - 
#       1) Load the vowel.train and vowel.test data sets.
#       2) Set the variable "y" to be a factor variable in BOTH the training and test set. 
#       3) Set the seed to 33833.
#       4) Fit a random forest model relating the factor variable y to the remaining variables.
#       5) Fit a svm model using the svm() function in the library(e1071).
#       5) What are the error rates for the two approaches on the test data set?
#       6) What is the error rate when the two methods agree on a prediction? 
library(ElemStatLearn)
library(randomForest)
library(e1071)
data(vowel.train)
data(vowel.test) 
vowel.train$y <- as.factor(vowel.train$y)
vowel.test$y <- as.factor(vowel.test$y)
set.seed(33833)
vowel.rf  <- randomForest(y ~ ., data=vowel.train)
vowel.svm <- svm(y ~ ., data=vowel.train)
pred.rf   <- predict(vowel.rf, vowel.test[,-1])
pred.svm  <- predict(vowel.svm, vowel.test[,-1])
#       5) What are the error rates for the two approaches on the test data set?
err.rf    <- sum(pred.rf != vowel.test$y)/length(pred.rf)
err.svm   <- sum(pred.svm != vowel.test$y)/length(pred.svm)
table(vowel.test$y, pred.rf)
table(vowel.test$y, pred.svm)
#       6) What is the error rate when the two methods agree on a prediction? 
agree.idx <- which(pred.rf == pred.svm)
err.both  <- sum(pred.rf[agree.idx] != vowel.test$y[agree.idx])/length(agree.idx)
