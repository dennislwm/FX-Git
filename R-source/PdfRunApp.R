#|------------------------------------------------------------------------------------------|
#|                                                                              PdfRunApp.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    This script is called from a Unix shell as a background process. For example:         |
#|  $ R -e "source('/home/rstudio/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source      |
#|                  /PdfRunApp.R')" &                                                       |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.0   This script contains ONLY ONE (1) function PdfRunApp() and it requires the      |
#|            library "PlusPdf" 1.1.2.                                                      |
#|------------------------------------------------------------------------------------------|
source("~/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusPdf.R")

PdfRunApp <- function(silent=FALSE)
{
  while( TRUE )
  {
    toChr   <- c("dennislwm@yahoo.com.au")
    fileStr <- paste0( RegGetRNonSourceDir(), "Job_02_pdf.rda" )
    predStr <- paste0( RegGetRNonSourceDir(), "Job_02_mdl.rda" )
    retNum <- PdfNomuraSeqNum(5, toChr=toChr, waitNum=20, silent=silent, 
                              fileStr=fileStr, predStr=predStr)
    while( retNum >= 5 )
    {
      retNum <- PdfNomuraSeqNum(5, toChr=toChr, waitNum=20, silent=silent,
                                fileStr=fileStr, predStr=predStr)
    }
    if(!silent)
    {
      print(Sys.time())
      print("Sleeping for 4 hours...")
    }
    hourNum <- 60*60
    Sys.sleep(4*hourNum)
  }
}

PdfRunApp()