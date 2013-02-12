# Introduction

This guide describes how to download and plot collection data from the New Mexico Biodiversity Collections Consortium [NMBCC](http://nmbiodiversity.org/) using the Global Biodiversity Information Facility [GBIF](http://data.gbif.org).  You will need to install a few [`R`](http://cran.r-project.org) packages including maps, dismo, RColorBrewer, and XML.  Next, download the `nmbcc.R` file above to your working directory and `source` the file to install the additional functions.

	library(maps); library(dismo); library(RColorBrewer); library(XML)
	source("nmbcc.R", keep.source=FALSE)
       
The main function `nmbcc` downloads the GBIF records from NMBCC and outputs a new class object `gbif`. Basically, the `nmbcc` script uses a hack to paste the dataproviderkey to the species option from `gbif()` in the `dismo` package and then reformats the output.  The default is to only return the number of collections available, in this case the number of columbines in the genus *Aquilegia*. Use the download option to retrieve the data.

	nmbcc("Aquilegia")
	[1] "Searching GBIF for Aquilegia"
	[1] "359 occurrences available. Set download=TRUE to download"
	aq <- nmbcc("Aquilegia", download = TRUE)

The resulting table is a similar to `data.frame` with three specific methods: print, plot and points. The `print` method displays the first few rows of the table (last 6 columns not shown). To view the entire table, just use `data.frame(aq)`. 

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


The `plot` method displays a colored county map.  

	plot(aq)
	[1] "Warning: 18 collections not mapped"

![Aquilegia counties](/plots/aq_counties.png)


The `points` method plots coordinates on the county map. If you have `RgoogleMaps` installed, you can change the background using a few lines of code.

	points(aq)
	[1] "Warning: 233 collections not mapped"
	library(RgoogleMaps)
	gmap <- GetMap( c( 34.2, -106.05), zoom=7,  maptype="terrain", destfile="nm.png")
	PlotOnStaticMap(gmap,lon=aq$lon,lat= aq$lat,col="blue", pch=16, verbose=0)


![Aquilegia coordinates](/plots/nm2.png)


## Removing duplicates

Many GBIF occurrences are actually duplicate collections that could be removed using the `duplicated` function.  In the *Aquilegia* dataset, there are 45 duplicate collections with the same species, county, collector, and collected date.  In some cases, you may want to keep the 23 collections from different localities as well (by adding column 7 below).  However, many collections from different localities are actually from the same place, but entered using different formats in the database.


	names(aq)[ c(1,6,2,3,7)]
	[1] "species"   "county"    "collector" "collected" "locality"
	# with or without locality?
	table(duplicated(aq[, c(1,6,2,3,7)] ))
	FALSE  TRUE 
	  337    22 
	table(duplicated(aq[, c(1,6,2,3)] ))
	FALSE  TRUE 
	  314    45 
	# to check duplicates
	data.frame( subset(aq, duplicated(aq[, c(1,6,2,3)]) | duplicated(aq[, c(1,6,2,3)], fromLast=TRUE) ) )
	# to remove duplicates
	aq <- subset(aq, !duplicated(aq[, c(1,6,2,3)] ) )


## Changing the data provider key

The NMBCC data provider key is number 83 and this default option can also be changed, for example, to download collections of *Aquilegia* from the two Arizona herbaria, use the provider keys 318 and 269 (and search [GBIF](http://data.gbif.org) for additional data publisher IDs).  

	az <- nmbcc("Aquilegia", provider= c(318, 269))
	[1] "449 occurrences available. Set download=TRUE to download"

## Other plots

You can also use many of the built-in `R` functions to plot histograms, dotcharts, and scatterplots.

	hist(year(aq$collected), xlab="Year", ylab = "Collections", main="", col="green", las=1)
	dotchart(sort(table(aq$source)), xlab="Collections", pch=16, cex=1.1)
	plot(year(aq$collected), format(aq$collected, "%j"), pch=16, xlab="Year", ylab="Day collected", col=rgb(0,0,1,.5))


![Aquilegia plots](/cstubben/nmbcc/raw/master/plots/aq_plots.png)
![Aquilegia plot2](/cstubben/nmbcc/raw/master/plots/aq_plots2.png)

## Plots by species

All the functions have a species option to download or plot a specific species. 

	nmbcc("Yucca", sp = "elata")
	plot(aq, sp="chrysantha", pal="YlOrBr")


Finally, you can plot different points for each species using a loop (first check species names and fix the alternate spelling for *caerulea*).

	table(species(aq$species))
	aq$species <-gsub("coerulea", "caerulea", aq$species)
	x<-unique(species( aq$species) )
	
	par(mar=c(3,3,3,3), xpd=TRUE)
	map("county", "new mexico")
	mtext(expression(paste(italic("Aquilegia"),  " collections")), 1, line=-1, cex=1.4)
	clrs<-c("darkblue", "orange", "yellow", "orangered", "red", "darkred")
	pch=c(15,16,17,15,16,17)
	for(i in 1:6){ points(aq, x[i],  pch=pch[i], col=clrs[i], add=TRUE) }
	legend(-108.3, 37.6,legend=gsub("Aquilegia", "A.", x), pch=pch, col=clrs, bty='n', ncol=3)

![Aquilegia map](/cstubben/nmbcc/raw/master/plots/aq_sp.png)

You can also plot separate county maps using a loop.  *A. triternata* is now considered a synonym of *A. desertorum* and you could update these old names using `aq$species <-gsub("triternata", "desertorum", aq$species)`.  Since the plot function uses `grep` to match patterns, you could also combine the two species using `plot(aq, "Aquilegia [dt]", label="A. desertorum")`

	par(mar=c(1,1,1,1), mfrow=c(3,2))
        palettes <- c("Blues", "Oranges", "YlOrBr", "Reds", "OrRd", "Reds")
        for(i in 1:6){ plot(aq, x[i], palettes[i])}

![Aquilegia map2](/cstubben/nmbcc/raw/master/plots/aq_sp2.png)





