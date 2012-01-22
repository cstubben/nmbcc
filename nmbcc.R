# Download GBIF records from NMBCC (or any provider).  Output is a new class object `gbif`
# with three methods, print, plot and points below.
# This script uses a hack to paste extra url strings to the species option from gbif() in the dismo package,
# so gbif output will have some extra confusing text like 'Aquilegia **&dataproviderkey=83' 

nmbcc <- function(genus, species="*", download=FALSE,  provider=83, geo=FALSE, ...){
   # save genus-species as attribute
   name <-paste(genus, species)
   name <- trim(gsub("\\*", "", name))
   print(paste("Searching GBIF for", name))
   # multiple providers OK
   provider <- paste("dataproviderkey", provider, sep="=", collapse="&") 
   # always use wildcard
   species <- paste(species, "*&", provider, sep="")
   df <- gbif(genus, species, download=download, geo=geo, ...)
   if(download){
      df <- df[, c( 1,  15, 17,3:5, 6:8, 10:13 ) ]
      names(df)[c(3, 5, 6, 11, 13)]<-c( "collected", "state", "county", "source", "catalog")
      # combine 
      df$source <- paste(df$source, df$collection)
      # drop collection
      df <- df[, -12]
      # remove authors
      df$species <- noauthor(df$species)
      # fix NM counties 
      df$county <- gsub("\\(|\\)", "", df$county)   # remove parentheses
      df$county <- gsub("ñ", "n", df$county)        # tildes in some Dona ana
      df$locality <- gsub("\\.$", "", df$locality)
      # convert to date
      df$collected <- as.Date(df$collected)
      df$alt[df$alt == "NaN"] <- NA
      # sort
      df <- df[order( df$species,  df$state, df$county ), ]
      rownames(df) <-NULL
      class(df)<-c("gbif", "data.frame")
      attr(df, "species") <- name
      df
   }else{
      print(paste(df, "occurrences available. Set download=TRUE to download"))
   }
}


# Print method for gbif
print.gbif<-function (x, ...) 
{ 
   if(nrow(x) > 6){
      cat("  A GBIF table with", nrow(x), "rows and", ncol(x), "columns\n\n")
        h1<-head(x,6)
        x<-format( rbind(h1, tail(x,1)) )
        x[6,] <- "..."
        rownames(x)[6] <- "..."
        print(x)
   } else{ print.data.frame(x) }
}

# Plot method for NM county maps - add county="new mexico" option to plot any state

plot.gbif<-function(x, sp, pal="Greens", label= attr(x, "species"), lpos=1, lline=-1, lcex=1.4, ...)
{
   ##  county names for matching to collections
   nm <- map("county", "new mexico", plot=FALSE)
   nm$names <- gsub("new mexico," , "", nm$names)

   if(missing(sp) ){
      counties <- x$county
   }else{
        # only change label if using default
        if( label == attr(x, "species") ){ label <- sp } 
        counties <- x$county[ grep( sp, x$species) ]
        if(length(counties)==0){stop("No matches to ", sp)}
   }

  # maps package uses all lowercase
  counties <- tolower(counties)

  # add factors to get all counties from table() including zero counts
  # collections with multiple counties and other errors will also be set to NA
  counties <- factor(counties, levels=nm$names)

  #  print number of county names that do not match county on map
  n <- sum(is.na(counties))
  if(n > 0)  print(paste("Warning:", n, "collections not mapped"))

  # get totals for each county
  counties <- table(counties) 

  # set color scale from RColorBrewer with white as first color for 0 collections, 
  clrs <- c("white", brewer.pal(9, pal)[-1])

  # cut counts into 9 bins 
  n <- cut(counties, c(-1, seq(0, max(counties), length.out=9)))

  # match bins to colors
  mcol <- clrs[n] 

  # DRAW map using color scale in mcol
  map("county", "new mexico", fill=TRUE, col=mcol)
  # add title
  mtext(substitute(italic(x), list(x=label)), lpos, line= lline, cex=lcex)

  #add number of plant collections to map
  cnts <- as.character(counties)
  cnts[cnts=="0"]<-""
  map.text("county", "new mexico", labels=cnts,  add=TRUE, ...)
}


# Plot coordinates

points.gbif<-function(x, sp, add=FALSE, pch=16, col="blue", label= attr(x, "species"), lpos=1, lline=-1, lcex=1, ...)
{
   if( ! missing(sp) ){
        # only change label if using default
        if( label == attr(x, "species") ){ label <- sp } 
        x <-  subset( x,  grepl( sp, x$species) )
        if(nrow(x)==0){stop("No matches to ", sp)}
   }
   if(!add){
      map("county", "new mexico")
      mtext(substitute(italic(x), list(x=label)), lpos, line= lline, cex=lcex)
   }
   points(x$lon, x$lat, pch=pch, col=col, ...)
   n <- sum(is.na(x$lat))
   if(n>0)  print(paste("Warning:", n, "collections not mapped"))
}


# Remove authors from species
noauthor <- function(x){
   ## split name into vector of separate words
   y <- strsplit(x, " ")
   sapply(y, function(x){  
     n <- grep( "^var\\.$|^ssp\\.$|^var$|^f\\.$",x)
     # apply a function to paste together the first and second elements
     # plus elements matching var., spp., f. and the next element
     # use sort in case the name includes both var and spp
        paste( x[sort(c(1:2, n,n+1))], collapse=" ")  })
}



# Remaining 4 functions from genomes package
species <- function (x, abbrev = FALSE) 
{
   x <- as.character(x)
   y <- strsplit(x, "\\s+")
   ge <- sapply(y, "[", 1)
   sp <- sapply(y, "[", 2)
   if (abbrev) {
      n <- sp != "sp."
      ge[n] <- substr(ge[n], 1, 1)
      paste(ge, ". ", sp, sep = "")
   }else{
      paste(ge, sp)
   }
}


# parse year
year  <- function(x){ as.numeric(format.Date(x, "%Y")) }
month <- function(x){ as.numeric(format.Date(x, "%m")) }


# like
"%like%" <-function(x, pattern)
{
   pattern <- glob2rx(pattern)
   as.character(x) %in% grep(pattern, x, ignore.case=TRUE, value=TRUE)
}
