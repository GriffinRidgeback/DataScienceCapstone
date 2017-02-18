dataFiles <- "~/DataScienceCapstone/final/en_US/"

setwd(dataFiles)

library(tm)
library(wordcloud)
library(RWeka)
library(SnowballC)

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
stopwatch <- proc.time()

# Load the whole shebang!
corpora <- Corpus(DirSource(dataFiles))

# How long did the load take?
proc.time() - stopwatch

# Take a look at what was loaded
inspect(corpora)

# How to look at the data
head(corpora[[1]]$content)
corpora[1]$content
meta(corpora[[3]])

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
corpora <- tm_map(corpora, removeWords, stopwords("english"))

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
corpora <- tm_map(corpora, toBlank, "cunt")
corpora <- tm_map(corpora, toBlank, "pussy")
corpora <- tm_map(corpora, toBlank, "[a-z]*fuck*")
corpora <- tm_map(corpora, toBlank, "[a-z]*shit*")
corpora <- tm_map(corpora, toBlank, "[a-z]*bitch*")

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

# Sample from the population
sample.size <- 5000
total.sample <- c(take.sample(corpora[[1]]$content, sample.size),
                  take.sample(corpora[[2]]$content, sample.size),
                  take.sample(corpora[[3]]$content, sample.size))

# Construct a VCorpus from the sampling
corpora.sample <- VCorpus(VectorSource(total.sample))

# Take some timing measurements and include in milestone report
stopwatch <- proc.time()

# Construct a DTM from the sample
dtm <- DocumentTermMatrix(corpora.sample)

# How long did the construction take?
proc.time() - stopwatch

# To see what is in the matrix (#docs = #rows, #terms = #cols)
dtm

# To see a subset
inspect(dtm[500:600, 3740:3743])

# Which terms appear more than N times?
N <- 250
findFreqTerms(dtm, lowfreq = N)

# To find associations (i.e., terms which correlate) 
# with at least Z correlation for a given term.
# How does a given word relate to other terms in 
# the corpus using a correlation limit Z.
# A value of Z = 1 means the term ALWAYS occurs
# with the resulting vector and decreases closer to zero.
# Use this to find which words are most strongly
# correlated to the most frequently-occurring words.
# It is NOT an indicator of nearness as the DTM
# is just a "bag of words".
term <- "well"
Z <- 0.2
findAssocs(dtm, term, Z)

# This function removes those terms that have a 99.999% chance of being sparse
#non.sparse <- inspect(removeSparseTerms(dtm, 0.99999))
non.sparse <- removeSparseTerms(dtm, 0.99999)
non.sparse
inspect(non.sparse)

# Use a Dictionary to filter the DTM
# BUT is useful ONLY if removeSparseTerms does something uesful
#inspect(DocumentTermMatrix(corpora.sample, list(dictionary = c("laid", "kids", "less"))))

# This also does nothing
#removeSparseTerms(DocumentTermMatrix(corpora.sample, list(dictionary = c("laid", "kids", "less"))), 0.9999)

# Calculate the frequency of each word
freq <- colSums(as.matrix(non.sparse))

# To verify counts
sum(non.sparse[, 1]) == freq[1]
sum(non.sparse[, 3]) == freq[3]

# Create sort order (descending)
freq.order <- order(freq, decreasing = TRUE)

# List most/least frequent terms
# Or least/most unique terms
freq[head(freq.order)]
freq[tail(freq.order)]

# Measures of central tendency
mean(freq)
sd(freq)
median(freq)

# How many unique values are there?
length(freq[freq == 1])

# Plots of central tendency
plot(1:length(freq[freq > 400]), 
     freq[freq > 400], 
     type = "l",
     col = "blue",
     xlab = "Frequency > 400", 
     ylab = "Density")
# You can also look at his page to see what he did with ggplot

# wordcloud - set same seed for consistency
set.seed(42)
wordcloud(names(freq), freq, min.freq = 150, colors = brewer.pal(6, "Dark2"))

# Function to get a comprehensive list of profanity words

# Returns a vector of profanity words
getProfanityWords <- function(corpus) {
  profanityFileName <- "profanity.txt"
  if (!file.exists(profanityFileName)) {
    profanity.url <- "https://raw.githubusercontent.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en"
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

sentences <- makeSentences(total.sample)
