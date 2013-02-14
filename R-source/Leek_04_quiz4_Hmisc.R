#|------------------------------------------------------------------------------------------|
#|                                                                    Leek_04_quiz4_Hmisc.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Motivational Buckets                                                                     |
#|    The questions in Quiz 4 is based on the lectures for Week 4, which is primarily       |
#|  focused on multivariate linear regression.                                              |
#|                                                                                          |
#| Background                                                                               |
#|    The data for this quiz comes from the book 'Investigating Statistical Concepts,       |
#|  Applications, and Methods' by Beth L Chance and Allan J Rossman (2013). The data can    |
#|  be downloaded from TWO (2) web sites:                                                   |
#|    1) Coursera:  https://spark-public.s3.amazonaws.com/dataanalysis/movies.txt           |
#|    2) RossmanChance.com: http://www.rossmanchance.com/iscam2/data/movies03RT.txt         |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   Coursera Data Analysis (Jeffrey Leek) Quiz 4 Week 4:                            |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)

#---  Question 1 & 2
#       1) Download movies file from "https://spark-public.s3.amazonaws.com/dataanalysis/movies.txt"
#       2) Read data
#       3) Coerce data
#       4) Fit a linear regression model where the Rotten Tomatoes score is the outcome and the box office gross
#           is the only covariate. 
#       5) What is the regression coefficient for the slope and it's interpretation? 
#       6) What is the 90% confidence interval for the intercept term and 
#           what can you deduce from the 90% confidence interval? 
download.file("https://spark-public.s3.amazonaws.com/dataanalysis/movies.txt", 
              destfile=paste0(RegGetRNonSourceDir(), "leek_03_movie.csv"))
movieDfr <- read.csv("leek_03_movie.csv", colClasses = "character", sep="\t" )
#       3) Coerce data
#         2] score
#         5] box.office
movieDfr[, 2] <- suppressWarnings( as.numeric( movieDfr[, 2] ) )
movieDfr[, 5] <- suppressWarnings( as.numeric( movieDfr[, 5] ) )
movie.lm <- lm(movieDfr$score ~ movieDfr$box.office)
#       5) What is the regression coefficient for the slope and it's interpretation? 
summary(movie.lm)
#       6) What is the 90% confidence interval for the intercept term and 
#           what can you deduce from the 90% confidence interval? 
confint(movie.lm, level=0.90)

#---  Question 3 - 6 (Using the same movie data as above)
#       1) Coerce data
#         6] running.time
#       2) Fit a linear regression model where the Rotten Tomatoes score is the outcome and box office gross 
#           and running time are the covariates. 
#       3) What is the value for the regression coefficient for running time? How is it interpreted?
#       4) Is running time a confounder for the relationship between Rotten Tomatoes score and box office gross? 
#           Why or why not?
#       5) Make a plot of the movie running times versus movie score. Do you see any outliers? 
#       6) If you do, remove those data points and refit the same regression (Rotten Tomatoes score is the outcome 
#           and box office gross and running time are the covariates). What do you observe?
#       7) What is the P-value for running time and how is it interpreted?
movieDfr[, 6] <- suppressWarnings( as.numeric( movieDfr[, 6] ) )
movie2.lm <- lm(movieDfr$score ~ movieDfr$box.office + movieDfr$running.time)
summary(movie2.lm)
#       4) Is running time a confounder for the relationship between Rotten Tomatoes score and box office gross? 
pairs(data.frame(movieDfr[,2],movieDfr[,5:6]))
cor(data.frame(movieDfr[,2],movieDfr[,5:6]))
#       5) Make a plot of the movie running times versus movie score. Do you see any outliers? 
plot(movieDfr$running.time, movieDfr$score, pch=19)
#       6) If you do, remove those data points and refit the same regression (Rotten Tomatoes score is the outcome 
#           and box office gross and running time are the covariates). What do you observe?
movie3Dfr <- movieDfr[movieDfr$running.time<200,]
movie3.lm <- lm(movie3Dfr$score ~ movie3Dfr$box.office + movie3Dfr$running.time)
summary(movie3.lm)
#       7) What is the P-value for running time and how is it interpreted?
summary(movie2.lm)

#---  Question 7 & 8 (Using the same movie data as above)
#       1) Fit a linear model where Rotten Tomatoes score is the outcome and the covariates are 
#           movie rating, running time, and an interaction between running time and rating. 
#       2) What is the coefficient for the interaction between running time and the indicator/dummy variable for 
#           PG rating? 
#       3) What is the estimated average change in score for a PG movie for a one minute increase in running time? 
movie4.lm <- lm(movieDfr$score ~ movieDfr$running.time + as.factor(movieDfr$rating) +
  movieDfr$running.time * as.factor(movieDfr$rating))
summary(movie4.lm)

#---  Question 9
#       1) Load data
#       2) Fit a linear model where the outcome is the number of breaks and the covariate is tension. 
#       3) What is a 95% confidence interval for the average difference in number of breaks between medium 
#           and high tension? 
data(warpbreaks)
warp.lm <- lm(warpbreaks$breaks ~ relevel(warpbreaks$tension, ref="H"))
summary(warp.lm)
confint(warp.lm, levels=0.95)