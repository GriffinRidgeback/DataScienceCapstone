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
