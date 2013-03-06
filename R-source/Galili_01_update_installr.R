#|------------------------------------------------------------------------------------------|
#|                                                              Galili_01_update_installr.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Background                                                                               |
#|    The script and "installr" package was written by Tal Galili and can be viewed at URL: |
#|  www.r-statistics.com/2013/03/updating-r-from-r-on-windows-using-the-installr-package/   |
#|                                                                                          |
#|    Upgrading R on Windows is not easy. While the R FAQ offer guidelines, some users may  |
#|  prefer to simply run a command in order to upgrade their R to the latest version.       |
#|                                                                                          |
#|    The "installr" package offers a set of R functions for the installation and updating  |
#|  of software (currently, only on Windows OS), with a special focus on R project (NOT R   |
#|  studio).                                                                                |
#|                                                                                          |
#| Function                                                                                 |
#|    Running the function updateR() with defaults will perform the following steps:        |
#|  (1) Check what is the latest R version. If the current installed R version is           |
#|      up-to-date, the function ends (and returns FALSE).                                  |
#|  (2) If a newer version of R is available, you will be asked if to review the NEWS of    |
#|      the latest R version - in order to decide if to install the newest R or not.        |
#|  (3) If you wish it - the function will download and install the latest R version. (you  |
#|      will need to press the "next" buttons on your own)                                  |
#|  (4) Once the installation is done, you should press "any-key", and the function will    |
#|      proceed with COPYING all of your packages from your old (well, current) R           |
#|      installation, into your newer R installation.                                       |
#|  (5) You can then erase all of the packages in your old R installation.                  |
#|  (6) After your packages are moved (and the old ones possibly erased), you will get the  |
#|      option to update all of your packages in the new version of R.                      |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   A script to automatically update R project (NOT R studio) to the latest version.|
#|------------------------------------------------------------------------------------------|
#---  installing/loading the package:
#   If the package has NOT reached your CRAN mirror yet, you can EITHER try again OR switch
#   to a different mirror.
if( !require(installr) )
{ 
  install.packages("installr")
  require(installr)
} 

#---  install, move, update.package, quit R.
#   (4) If you know you wish to upgrade R, and you want the packages moved (not copied).
updateR(F, T, T, F, T, F, T) 

