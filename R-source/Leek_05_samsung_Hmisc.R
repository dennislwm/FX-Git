#|------------------------------------------------------------------------------------------|
#|                                                                  Leek_05_samsung_Hmisc.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Motivational Buckets                                                                     |
#|  (1) Understand the function svd() in the context of Samsung data.                       |
#|                                                                                          |
#| Assert History                                                                           |
#|  0.9.0 Source code from Leek (2013) Lecture 4-1 Clustering Example                       |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)

#---  Download data
#       (1) Check locally if file has been downloaded
#       (2) Download from Dropbox if file does not exists
#       (3) Load file
fileStr <- paste0(RegGetRNonSourceDir(), "Leek_05_samsung.rda")
if( !file.exists(fileStr) )
  download.file("https://dl.dropbox.com/u/7710864/courseraPublic/samsungData.rda",
                destfile=fileStr)
load(fileStr)
names(samsungData)[1:12]

#---  Plot Average Acceleration
#       (1) Coerce character vector into numeric
#       (2) Plot column 1 by subject 1, and colored by activity
#       (3) Plot column 2 by subject 1, and colored by activity
#       (4) Plot column 3 by subject 1, and colored by activity
par(mfrow=c(1,3))
activityNum <- as.numeric(as.factor(samsungData$activity))[samsungData$subject==1]
plot(samsungData[samsungData$subject==1, 1], pch=19,
     ylab=names(samsungData)[1], col=activityNum)
plot(samsungData[samsungData$subject==1, 2], pch=19,
     ylab=names(samsungData)[2], col=activityNum)
plot(samsungData[samsungData$subject==1, 3], pch=19,
     ylab=names(samsungData)[3], col=activityNum)
legend(0, -0.4, legend=unique(samsungData$activity), pch=19,
       col=unique(activityNum))

#---  HCluster Average Acceleration
#       (1) Source function myplclust() from Dropbox
#       (2) Create distance matrix by subject 1
#       (3) Plot Hcluster
par(mfrow=c(1,1))
source("http://dl.dropbox.com/u/7710864/courseraPublic/myplclust.R")
sub1.dist <- dist(samsungData[samsungData$subject==1, 1:3])
sub1.hcl <- hclust(sub1.dist)
myplclust(sub1.hcl, lab.col=activityNum)

#---  Plot Maximum Acceleration
#       (1) Plot column 10 by subject 1, and colored by activity
#       (2) Plot column 11 by subject 1, and colored by activity
#       (3) Plot column 12 by subject 1, and colored by activity
par(mfrow=c(1,3))
plot(samsungData[samsungData$subject==1, 10], pch=19,
     ylab=names(samsungData)[10], col=activityNum)
plot(samsungData[samsungData$subject==1, 11], pch=19,
     ylab=names(samsungData)[11], col=activityNum)
plot(samsungData[samsungData$subject==1, 12], pch=19,
     ylab=names(samsungData)[12], col=activityNum)

#---  HCluster Maximum Acceleration
#       (1) Create distance matrix by subject 1
#       (2) Plot Hcluster
par(mfrow=c(1,1))
sub2.dist <- dist(samsungData[samsungData$subject==1, 10:12])
sub2.hcl <- hclust(sub2.dist)
myplclust(sub2.hcl, lab.col=activityNum)

#---  Singular Value Decomposition (SVD)
#       (1) Create svd by subject 1 for ALL columns EXCEPT subject, activity
#       (2) Plot first TWO (2) columns of u (left singular vector)
#       (3) Plot first TWO (2) columns of v (right singular vector)
#       (4) Find maximum column contributor from v
sub1.svd <- svd(scale(samsungData[samsungData$subject==1, -c(562, 563)]))
par(mfrow=(c(1,2)))
plot(sub1.svd$u[, 1], pch=19, col=activityNum)
plot(sub1.svd$u[, 2], pch=19, col=activityNum)
plot(sub1.svd$v[, 1], pch=19, col=activityNum)
plot(sub1.svd$v[, 2], pch=19, col=activityNum)
sub1MaxWt.col <- which.max(sub1.svd$v[, 2])

#---  HCluster Maximum Acceleration PLUS Contributor
#       (1) Name the contributor
#       (2) Create distance matrix by subject 1
#       (3) Plot Hcluster
names(samsungData)[sub1MaxWt.col]
par(mfrow=c(1,1))
sub3.dist <- dist(samsungData[samsungData$subject==1, 
                              c(10:12, sub1MaxWt.col)])
sub3.hcl <- hclust(sub3.dist)
myplclust(sub3.hcl, lab.col=activityNum)

#---  K-means Cluster
#       (1) Create K-Cluster by subject 1 for ALL columns EXCEPT subject, activity
#           with 6 beginning centroids
#       (2) Create K-Cluster by subject 1 for ALL columns EXCEPT subject, activity
#           with 6 beginning centroids, and averaged over 100 nstarts
#       (3) Plot clusters
sub1.kcl <- kmeans(samsungData[samsungData$subject==1, -c(562,563)],
                   centers=6)
table(sub1.kcl$cluster, samsungData$activity[samsungData$subject==1])
sub2.kcl <- kmeans(samsungData[samsungData$subject==1, -c(562,563)],
                   centers=6, nstart=100)
table(sub2.kcl$cluster, samsungData$activity[samsungData$subject==1])
par(mfrow=c(2,3))
plot(sub2.kcl$center[1, 1:10], pch=19, ylab="Cluster Center", xlab="1")
plot(sub2.kcl$center[2, 1:10], pch=19, ylab="Cluster Center", xlab="2")
plot(sub2.kcl$center[3, 1:10], pch=19, ylab="Cluster Center", xlab="3")
plot(sub2.kcl$center[4, 1:10], pch=19, ylab="Cluster Center", xlab="4")
plot(sub2.kcl$center[5, 1:10], pch=19, ylab="Cluster Center", xlab="5")
plot(sub2.kcl$center[6, 1:10], pch=19, ylab="Cluster Center", xlab="6")
