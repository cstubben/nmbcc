# Introduction

This guide describes how to download and plot collection data from the New Mexico Biodiversity Collections Consortium [NMBCC](http://nmbiodiversity.org/) using the Global Biodiversity Information Facility [GBIF](http://data.gbif.org).  You will need to install a few [`R`](http://cran.r-project.org) packages including maps, dismo, RColorBrewer, and XML.  Next, download the `nmbcc.R` file above to your working directory and `source` the file to install the additional functions.

	library(maps); library(dismo); library(RColorBrewer); library(XML)
	source("nmbcc.R")
       
The main function `nmbcc` downloads the GBIF records from NMBCC and outputs a new class object `gbif`. Basically, the `nmbcc` script uses a hack to paste the dataproviderkey to the species option from `gbif()` in the `dismo` package and then reformats the output.  The default is to only return the number of collections available, in this case the number of columbines in the genus Aquilegia. Use the download option to retrieve the data.

	nmbcc("Aquilegia")
	[1] "Searching GBIF for Aquilegia"
	[1] "359 occurrences available. Set download=TRUE to download"
	aq <- nmbcc("Aquilegia", download = TRUE)

The resulting table is a similar to `data.frame` with a three specific methods: print, plot and points. The `print` method displays the first few rows of the table (last 6 columns not shown). To view the entire table, just use `data.frame(aq)`. 

	aq
	  A GBIF table with 359 rows and 12 columns

	                 species                  collector  collected country      state            county
	1     Aquilegia caerulea    H. Higgins and Campbell 1979-07-18      US New Mexico            Colfax
	2     Aquilegia caerulea T.S. Foxx and G.D. Tierney 1979-07-23      US New Mexico        Los Alamos
	3     Aquilegia caerulea               A.J. Dickson 1905-06-22      US New Mexico McKinley/San Juan
	4     Aquilegia caerulea              P.C. Standley 1908-07-01      US New Mexico              Mora
	5     Aquilegia caerulea           Allred, Kelly W. 1997-07-30      US New Mexico              Mora
	...                  ...                        ...        ...     ...        ...               ...
	359 Aquilegia triternata                E.J. Bedker 1962-08-05      US New Mexico          Torrance


The `plot` method displays a county map. 

	plot(aq)
	[1] "Warning: 18 collections not mapped"

![Aquilegia plots](/cstubben/nmbcc/raw/master/plots/aq_plots.png)


The `points` method plots coordinates.

	> points(aq)
	[1] "Warning: 233 collections not mapped"

![Aquilegia coordinates](/cstubben/nmbcc/raw/master/plots/aq_coords.png)


You can also use many of the built-in `R` functions to plot histograms, dotcharts, and scatterplots.

	hist(year(aq$collected), xlab="Year", ylab = "Collections", main="", col="green", las=1)
        dotchart(sort(table(aq$source)), xlab="Collections", pch=16, cex=1.1)
	plot(year(aq$collected), format(aq$collected, "%j"), pch=16, xlab="Year", ylab="Day collected", col=rgb(0,0,1,.5) , cex=.8)


![Aquilegia NM county map](/cstubben/nmbcc/raw/master/plots/aq_counties.png)

All the functions have a species option to download or plot a specific species and we are currently working on completing a `nmbcc` package with full details and help pages. 

yucca <- nmbcc("Yucca", sp = "elata" , TRUE)
plot(aq, sp="chrysantha", pal="YlOrBr")


Finally, using a loop, you can plot different points for each species or separate county maps.

![Aquilegia map](/cstubben/nmbcc/raw/master/plots/aq_sp.png)

![Aquilegia map2](/cstubben/nmbcc/raw/master/plots/aq_sp2.png)





