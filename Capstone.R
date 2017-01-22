dataFiles <- "~/Development/DataScienceCapstone/final/en_US/"

setwd(dataFiles)

library(tm)

# Start the clock!
ptm <- proc.time()

# Load the whole shebang!
corpora <- Corpus(DirSource(dataFiles))

# Don't want to save .RHistory and .RData anywhere else
setwd("~/Development/DataScienceCapstone/")

# Helper function
toBlank <- content_transformer(function(x, pattern) {return (gsub(pattern, "", x))})

# Cleanup document - Pass 1
corpora <- tm_map(corpora, toBlank, "[[:punct:][:digit:]]")

# Transform to lower case (need to wrap in content_transformer)
corpora <- tm_map(corpora, content_transformer(tolower))

# Remove stopwords
corpora <- tm_map(corpora, removeWords, stopwords("english"))

# Remove whitespace
corpora <- tm_map(corpora, stripWhitespace)

# But there are still leading whitespace (and maybe trailing?)
corpora <- tm_map(corpora, toBlank, "^[ \t]+|[ \t]+$")

# Remove all blank lines
corpora <- tm_map(corpora, toBlank, "^[[:blank:]*]$")

# Now all data is in lowercase but there are some non-Latin characters to remove
corpora <- tm_map(corpora, toBlank, "[^a-z ]")

# Now, clean out the filth
corpora <- tm_map(corpora, toBlank, "cunt")
corpora <- tm_map(corpora, toBlank, "pussy")
corpora <- tm_map(corpora, toBlank, "[a-z]*fuck*")
corpora <- tm_map(corpora, toBlank, "[a-z]*shit*")

# Perform crude stemming
corpora <- tm_map(corpora, stemDocument)

# Now sample from the population
percent <- 0.10
blogs.length <- length(corpora[[1]]$content)
news.length <- length(corpora[[2]]$content)
twitter.length <- length(corpora[[3]]$content)
blog.sample <- sample(corpora[[1]]$content, blogs.length * percent, replace = FALSE)
news.sample <- sample(corpora[[2]]$content, news.length * percent, replace = FALSE)
twitter.sample <- sample(corpora[[3]]$content, twitter.length * percent, replace = FALSE)
total.sample <- c(blog.sample, news.sample, twitter.sample)
sample.corpora <- VCorpus(VectorSource(total.sample))

# Now create a TermDocumentMatrix
tdm <- TermDocumentMatrix(sample.corpora)

# Write out to see what else was missed
writeCorpus(corpora, path = "~/Development/DataScienceCapstone/text files/")

# Stop the clock
proc.time() - ptm