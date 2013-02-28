#---  This script was obtained from R-Sig-Finance
#   Author:     Yang Lu
#   Package:    pa
#   URL:        cran.at.r-project.org/web/packages/pa/index.html
#   Vignette:   cran.at.r-project.org/web/packages/pa/vignettes/pa.pdf
library(pa)
data(jan)

#---  TWO (2) methods included in the "pa" package:
#       1) Brinson method
#       2) Regression-based analysis
#       3) Plot TWO(2)-panels
br.single <- brinson(x=jan,
                     date.var="date",
                     cat.var="sector",
                     bench.weight="benchmark",
                     portfolio.weight="portfolio",
                     ret.var="return")
summary(br.single)
#       2) Regression-based analysis
rb.single <- regress(jan,
                     date.var="date",
                     reg.var=c("sector","growth","size"),
                     benchmark.weight="benchmark",
                     portfolio.weight="portfolio",
                     ret.var="return")
exposure(rb.single, 
         var="growth")
#       3) Plot TWO(2)-panels
par(mfrow=c(1,2))
plot(br.single,
     var="sector",
     type="return")
plot(rb.single)
