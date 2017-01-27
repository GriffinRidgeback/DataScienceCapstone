dataFiles <- "~/DataScienceCapstone/final/en_US/"

setwd(dataFiles)

library(tm)
library(SnowballC)

# Take some timing measurements and include in milestone report
stopwatch <- proc.time()

# Load the whole shebang!
corpora <- Corpus(DirSource(dataFiles))

# How long did the load take?
proc.time() - stopwatch

# Take a look at what was loaded
inspect(corpora)

# How to look at the data
head(corpora[[1]]$content)

# Don't want to save .RHistory and .RData anywhere else
setwd("~/DataScienceCapstone/")

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
blog.sample <- sample(corpora[[1]]$content, 1000, replace = FALSE)
news.sample <- sample(corpora[[2]]$content, 1000, replace = FALSE)
twitter.sample <- sample(corpora[[3]]$content, 1000, replace = FALSE)
total.sample <- c(blog.sample, news.sample, twitter.sample)
sample.corpora <- VCorpus(VectorSource(total.sample))

# Now create a TermDocumentMatrix
tdm <- TermDocumentMatrix(sample.corpora)

# Write out to see what else was missed
writeCorpus(sample.corpora, path = "~/DataScienceCapstone/text files/")