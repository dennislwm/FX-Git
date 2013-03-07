#|------------------------------------------------------------------------------------------|
#|                                                            Leek_06_quiz6_ElemStatLearn.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Motivational Buckets                                                                     |
#|    The questions in Quiz 6 is based on the lectures for Week 6, which is primarily       |
#|  focused on prediction models using regression and trees.                                |
#|                                                                                          |
#| Background                                                                               |
#|    The data for this quiz comes from the book "The Elements of Statistical Learning" by  |
#|  Hastie, Tibshirani & Friedman (2009). The data can be downloaded from:                  |
#|    URL:  http://www-stat.stanford.edu/~tibs/ElemStatLearn/                               |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Data Analysis (Jeffrey Leek) Quiz 6 Week 6:                            |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)

#---  Question 3
#       1) Load the South Africa Heart Disease Data and create training and test sets.
#       2) Then fit a logistic regression model with Coronary Heart Disease (chd) as the 
#         outcome and age at onset, current alcohol consumption, obesity levels, cumulative 
#         tobacco, type-A behavior, and low density lipoprotein cholesterol as predictors. 
#       3) Calculate the misclassification rate for your model using the custom function 
#         missClass() and a prediction on the "response" scale.
library(ElemStatLearn)
data(SAheart)
set.seed(8484)
train = sample(1:dim(SAheart)[1],size=dim(SAheart)[1]/2,replace=F)
trainSA = SAheart[train,]
testSA = SAheart[-train,]
#       2) Then fit a logistic regression model with Coronary Heart Disease (chd) as the 
#         outcome and age at onset, current alcohol consumption, obesity levels, cumulative 
#         tobacco, type-A behavior, and low density lipoprotein cholesterol as predictors. 
heart.glm <- glm(chd ~ age + alcohol + obesity + tobacco + typea + ldl,
                 family="binomial", data=trainSA)
#       3) Calculate the misclassification rate for your model using the custom function 
#         missClass() and a prediction on the "response" scale.
missClass = function(values, prediction) 
{
  sum(((prediction > 0.5)*1) != values) / length(values)
}
missClass( trainSA$chd, predict(heart.glm, type="response"))
missClass( testSA$chd, predict(heart.glm, type="response", newdata=testSA))

#---  Question 4 & 5
#       1) Load the olive oil data from the package "pgmm". The data contains information on
#           572 different Italian olive oils from multiple regions in Italy. 
#       2) Fit a classification tree where Area is the outcome variable.
#       3) Predict outcome Area for a new value
library(pgmm)
data(olive)
olive = olive[,-1]
#       2) Fit a classification tree where Area is the outcome variable.
library(tree)
olive.tree <- tree(Area ~ ., data=olive)
newData <- as.data.frame(t(colMeans(olive)))
predict(olive.tree, newdata=newData)
#       3) Predict outcome Area for a new value
newData <- data.frame(Palmitic = 1200, Palmitoleic = 120, Stearic=200,Oleic=7000,Linoleic = 900, Linolenic = 32, Arachidic=60,Eicosenoic=6)
predict(olive.tree, newdata=newData)
