# Introduction

This guide describes how to download and plot collection data in [`R`](http://cran.r-project.org) from the New Mexico Biodiversity Collections Consortium [NMBCC](http://nmbiodiversity.org/) using the Global Biodiversity Information Facility [GBIF](http://data.gbif.org).  You will need to install a few R packages including `maps`, `dismo`, `RColorBrewer` and optionally `RgoogleMaps` for the last example.

The `gbif` function in the `dismo` package is used to download the collection data using the `nmbcc` 



is a bare-bones introduction to [ggplot2](http://had.co.nz/ggplot2/), a visualization package in R. It assumes no knowledge of R. 

There is also a literate programming version of this tutorial in [`ggplot2-tutorial.R`](https://github.com/echen/ggplot2-tutorial/blob/master/ggplot2-tutorial.R).

# Preview

Let's start with a preview of what ggplot2 can do.

Given Fisher's [iris](http://en.wikipedia.org/wiki/Iris_flower_data_set) data set and one simple command...

    qplot(Sepal.Length, Petal.Length, data = iris, color = Species)
    
...we can produce this plot of sepal length vs. petal length, colored by species.

[![Sepal vs. Petal, Colored by Species](http://dl.dropbox.com/u/10506/blog/r/ggplot2/sepal-vs-petal-specied.png)](http://dl.dropbox.com/u/10506/blog/r/ggplot2/sepal-vs-petal-specied.png)

# Installation

You can download R [here](http://cran.opensourceresources.org/). After installation, you can launch R in interactive mode by either typing `R` on the command line or opening the standard GUI (which should have been included in the download).

# R Basics

## Vectors

Vectors are a core data structure in R, and are created with `c()`. Elements in a vector must be of the same type.

	numbers = c(23, 13, 5, 7, 31)
	names = c("edwin", "alice", "bob")
		
Elements are indexed starting at 1, and are accessed with `[]` notation.

	numbers[1] # 23
	names[1] # edwin

## Data frames

[Data frames](http://www.r-tutor.com/r-introduction/data-frame) are like matrices, but with named columns of different types (similar to [database tables](http://code.google.com/p/sqldf/)).

    books = data.frame(
        title = c("harry potter", "war and peace", "lord of the rings"), # column named "title"
        author = c("rowling", "tolstoy", "tolkien"),
        num_pages = c("350", "875", "500")
    )
	
You can access columns of a data frame with `$`.

	books$title # c("harry potter", "war and peace", "lord of the rings")
	books$author[1] # "rowling"
	
You can also create new columns with `$`.

	books$num_bought_today = c(10, 5, 8)
	books$num_bought_yesterday = c(18, 13, 20)
	
	books$total_num_bought = books$num_bought_today + books$num_bought_yesterday
	
## read.table

Suppose you want to import a TSV file into R as a data frame.

### tsv file without header

For example, consider the [`data/students.tsv`](https://github.com/echen/r-tutorial/blob/master/data/students.tsv) file (with columns describing each student's age, test score, and name).

    13   100 alice
    14   95  bob
    13   82  eve
    
We can import this file into R using [`read.table()`](http://stat.ethz.ch/R-manual/R-devel/library/utils/html/read.table.html).

    students = read.table("data/students.tsv", 
        header = F, # file does not contain a header (`F` is short for `FALSE`),
                    # so we must manually specify column names                    
        sep = "\t", # file is tab-delimited        
        col.names = c("age", "score", "name") # column names
    )

We can now access the different columns in the data frame with `students$age`, `students$score`, and `students$name`.

### csv file with header
