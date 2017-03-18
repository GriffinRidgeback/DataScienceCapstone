# From the textInput
inputString <- "A_baby_cried 1 time?"

# If this returns a blank string, print message
# How? to continue?
inputString <- sanitizeInput(inputString)

# Tokenize
inputString <- unlist(strsplit(inputString, ' '))

# There might be blanks!
inputString <- inputString[inputString != ""]

# Length will be used later
l <- length(inputString)

# For 4 or more tokens, take only the last four
if (l >= 4) {
  from <- (l + 1) - 4
  to <- l
  inputString <- inputString[from:to]
}

# Final input string for processing
inputString <- paste(inputString, sep = "", collapse = "_")


# Figure out the predictions
if (l >= 4) { # Use quintgram table to find completion for quadgram
  results <- searchNGrams(inputString, quint.gram.table)
  if (length(results) != 0) {
    predictions <- processResults(quint.gram.table, results)
  }
  else { # Use quadgram table to find completion for trigram
    inputString <- reduceNGram(inputString)
    results <- searchNGrams(inputString, quad.gram.table)
    if (length(results) != 0) {
      predictions <- processResults(quad.gram.table, results)
    }
    else { # Use trigram table to find completion for bigram
      inputString <- reduceNGram(inputString)
      results <- searchNGrams(inputString, tri.gram.table)
      if (length(results) != 0) {
        predictions <- processResults(tri.gram.table, results)
      }
      else { # Use bigram table to find completion for unigram
        inputString <- reduceNGram(inputString)
        results <- searchNGrams(inputString, bi.gram.table)
        if (length(results) != 0) {
          predictions <- processResults(bi.gram.table, results)
        }
        else {
          msg <- "No prediction possible"
        }
      }
    }
  }
}