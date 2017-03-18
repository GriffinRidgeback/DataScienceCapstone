dataFiles <- "~/DataScienceCapstone/final/en_US/"

setwd(dataFiles)

library(tm)
library(wordcloud)
library(RWeka)
library(quanteda)

####################
# Helper functions #
####################
#
# Take a sample of size 'x' from a given vector
#
take.sample <- function(vector, sample.size) {
  set.seed(42)
  sample(vector, sample.size, replace = FALSE)
}

#
# Convert the specified pattern to blank, given a vector
#
toBlank <- content_transformer(function(x, pattern) {return (gsub(pattern, "", x))})

# Take some timing measurements and include in milestone report
#stopwatch <- proc.time()

# Load the whole shebang!
corpora <- Corpus(DirSource(dataFiles))

# How long did the load take?
#proc.time() - stopwatch

# Take a look at what was loaded
#inspect(corpora)

# How to look at the data
#head(corpora[[1]]$content)
#corpora[1]$content
#meta(corpora[[3]])

# Don't want to save .RHistory and .RData anywhere else
setwd("~/DataScienceCapstone/")

# Remove punctuation and digits
#corpora.sample <- tm_map(corpora.sample, toBlank, "[[:punct:][:digit:]]")
corpora <- tm_map(corpora, toBlank, "[[:punct:][:digit:]]")

# Transform to lower case (need to wrap in content_transformer)
#corpora.sample <- tm_map(corpora.sample, content_transformer(tolower))
corpora <- tm_map(corpora, content_transformer(tolower))

# Remove stopwords
#corpora.sample <- tm_map(corpora.sample, removeWords, stopwords("english"))
# DON'T DO THIS!!!!
#corpora <- tm_map(corpora, removeWords, stopwords("english"))

# Remove whitespace
#corpora.sample <- tm_map(corpora.sample, stripWhitespace)
corpora <- tm_map(corpora, stripWhitespace)

# But there is still leading whitespace (and maybe trailing?)
#corpora.sample <- tm_map(corpora.sample, toBlank, "^[ \t]+|[ \t]+$")
corpora <- tm_map(corpora, toBlank, "^[ \t]+|[ \t]+$")

# Remove all blank lines
#corpora.sample <- tm_map(corpora.sample, toBlank, "^[[:blank:]*]$")
corpora <- tm_map(corpora, toBlank, "^[[:blank:]*]$")

# Now all data is in lowercase but there are some non-Latin characters to remove
#corpora.sample <- tm_map(corpora.sample, toBlank, "[^a-z ]")
corpora <- tm_map(corpora, toBlank, "[^a-z ]")

# Now, clean out the filth
# corpora <- tm_map(corpora, toBlank, "cunt")
# corpora <- tm_map(corpora, toBlank, "pussy")
# corpora <- tm_map(corpora, toBlank, "[a-z]*fuck*")
# corpora <- tm_map(corpora, toBlank, "[a-z]*shit*")
# corpora <- tm_map(corpora, toBlank, "[a-z]*bitch*")

# Make a backup so that we have a reference dictionary for completions
#corpora.backup <- corpora

# Take some timing measurements and include in milestone report
#stopwatch <- proc.time()

# Perform some crude stemming
#corpora <- tm_map(corpora, stemDocument)

# "Normalize" the stemmed documents by performing stem completion
#corpora <- tm_map(corpora, stemCompletion, dictionary=corpora.backup)

# How long did the construction take?
#proc.time() - stopwatch

# writeCorpus(corpora, path = "~/DataScienceCapstone/text")

# Sample from the population
sample.size <- 15000
total.sample <- c(take.sample(corpora[[1]]$content, sample.size),
                  take.sample(corpora[[2]]$content, sample.size),
                  take.sample(corpora[[3]]$content, sample.size))

# Construct a VCorpus from the sampling
corpora.sample <- VCorpus(VectorSource(total.sample))

# construct a document-feature matrix for n-gram creation
# corpora.dfm <- dfm(corpus(corpora))

# Function to get a comprehensive list of profanity words

# Returns a vector of profanity words
getProfanityWords <- function(corpus) {
  profanityFileName <- "profanity.txt"
  if (!file.exists(profanityFileName)) {
    profanity.url <- "https://raw.githubusercontent.ccorporaom/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en"
    download.file(profanity.url, destfile = profanityFileName, method = "curl")
  }
  
  if (sum(ls() == "profanity") < 1) {
    profanity <- read.csv(profanityFileName, header = FALSE, stringsAsFactors = FALSE)
    profanity <- profanity$V1
    profanity <- profanity[1:length(profanity)-1]
  }
  
  profanity
}

# Function to break the corpus into sentences before creating n-grams
makeSentences <- function(input) {
  output <- tokenize(input, what = "sentence", removeNumbers = TRUE,
                     removePunct = TRUE, removeSeparators = TRUE,
                     removeTwitter = TRUE, removeHyphens = TRUE)
  output <- removeFeatures(output, getProfanityWords())
  unlist(lapply(output, function(a) toLower(a)))
#  unlist(lapply(output, function(a) paste('#s#', toLower(a), '#e#')))
}

# A function for creating n-grams
makeTokens <- function(input, n = 1L) {
  tokenize(input, what = "word", removeNumbers = TRUE,
           removePunct = TRUE, removeSeparators = TRUE,
           removeTwitter = FALSE, removeHyphens = TRUE,
           ngrams = n, simplify = TRUE)
}

freq.df <- function(frame) {
  ranking <- sort(colSums(frame), decreasing = TRUE)
  return(data.frame(word = names(ranking), 
                    count = ranking,
                    row.names = NULL))
}

#sentences <- makeSentences(total.sample)
sentences <- makeSentences(corpus(corpora.sample))
ngram1 <- makeTokens(sentences, 1)
ngram2 <- makeTokens(sentences, 2)
ngram3 <- makeTokens(sentences, 3)
ngram4 <- makeTokens(sentences, 4)

dfm1 <- dfm(ngram1, tolower = FALSE)
dfm2 <- dfm(ngram2, tolower = FALSE)
dfm3 <- dfm(ngram3, tolower = FALSE)
dfm4 <- dfm(ngram4, tolower = FALSE)

unigram.frequency <- freq.df(dfm1)
bigram.frequency <- freq.df(dfm2)
trigram.frequency <- freq.df(dfm3)
quadgram.frequency <- freq.df(dfm4)

# Load the library
library(dplyr)

# Read in the data
bi.grams <- read.csv(file = "./ngrams/bigram.txt", sep = "\t", col.names = c("count", "word1", "word2"))
tri.grams <- read.csv(file = "./ngrams/trigram.txt", sep = "\t", col.names = c("count", "word1", "word2", "word3"))
quad.grams <- read.csv(file = "./ngrams/quadgram.txt", sep = "\t", col.names = c("count", "word1", "word2", "word3", "word4"))
quint.grams <- read.csv(file = "./ngrams/quintgram.txt", sep = "\t", col.names = c("count", "word1", "word2", "word3", "word4", "word5"))
#bi.grams[which(bi.grams$count == max(bi.grams$count)), ]

# Create an ngram from the data
bi.gram.table <- bi.grams %>% mutate(ngram = paste(word1, word2, sep = "_")) %>% select(count, ngram)
tri.gram.table <- tri.grams %>% mutate(ngram = paste(word1, word2, word3, sep = "_")) %>% select(count, ngram)
quad.gram.table <- quad.grams %>% mutate(ngram = paste(word1, word2, word3, word4, sep = "_")) %>% select(count, ngram)
quint.gram.table <- quint.grams %>% mutate(ngram = paste(word1, word2, word3, word4, word5, sep = "_")) %>% select(count, ngram)

# Save the data
saveRDS(bi.gram.table, file = "./data/bi.gram.table.rds")
saveRDS(tri.gram.table, file = "./data/tri.gram.table.rds")
saveRDS(quad.gram.table, file = "./data/quad.gram.table.rds")
saveRDS(quint.gram.table, file = "./data/quint.gram.table.rds")

# Restore the data (shiny app will need this)
newtable <- readRDS("./data/bi.gram.table.rds")

# This gives the indices of the matched data
results <- grep("^to_have_a_baby", quint.gram.table$ngram, value = FALSE)
paste("^", inputString, sep = "", collapse = "_")

# This gives the frequency of the matched data
counts <- quint.gram.table[results, 1]

# This dataframe combines the work
weighting <- data.frame(results, counts)

# Now order the dataframe so the highest counts and indices are considered
z <- order(weighting$counts, weighting$results, decreasing = TRUE)

# Get the first index
first_position <- weighting[z[1], ]$results

quint.gram.table[first_position, ]
quint.gram.table[first_position, ]$ngram

