# If the user enters a phrase with underscores
# this method does not handle them well
sanitizeInput <- function(inputString) {
  inputString <- gsub("_", " ", inputString)
  return(gsub("[[:punct:][:digit:]]+", "", tolower(inputString)))
}

# Search for searchString in searchTable
searchNGrams <- function(searchString, searchTable) {
  searchString <- paste("^", searchString, sep = "", collapse = "_")
  return(grep(searchString, searchTable$ngram, value = FALSE))
}

# Removes the first word in the given n-gram
# to allow for searching in an n-1 table
reduceNGram <- function(searchString) {
  # Find the first underscore in the searchString
  pos <- regexpr("_", searchString)
  return(substring(searchString, pos[1] + 1))
}

# Extract the prediction from a given n-gram
retrievePrediction <- function(ngram) {

  # Find the position of all the underscores
  g <- gregexpr("_", ngram, fixed=TRUE)

  # Store the array of positions in "loc"
  loc <- g[[1]]

  # The last occurrence of an underscore will
  # be at the value of the last array value + 1
  last_underscore <- loc[length(loc)] + 1

  # Return the predicted word
  return(substring(ngram, last_underscore))
}

# Determine how many predicted words are found
processResults <- function(table, results) {
  # This gives the frequency of the matched data
  counts <- table[results, 1]

  # This dataframe combines the work
  weighting <- data.frame(results, counts)

  # Now order the dataframe so the highest counts and indices are considered
  z <- order(weighting$counts, weighting$results, decreasing = TRUE)

  # Now figure out which elements to return
  if (length(z) == 1) {
    first_position <- weighting[z[1], ]$results
    first_result <- table[first_position, ]$ngram
    first_result <- retrievePrediction(first_result)
    first_result <- paste("Prediction 1 ->", first_result)

    return(c(first_result))
  }

  if (length(z) == 2) {
    first_position <- weighting[z[1], ]$results
    first_result <- table[first_position, ]$ngram
    first_result <- retrievePrediction(first_result)
    first_result <- paste("Prediction 1 ->", first_result)

    second_position <- weighting[z[2], ]$results
    second_result <- table[second_position, ]$ngram
    second_result <- retrievePrediction(second_result)
    second_result <- paste(" Prediction 2 ->", second_result)
    
    return(c(first_result, second_result))
  }

  if (length(z) >= 3) {
    first_position <- weighting[z[1], ]$results
    first_result <- table[first_position, ]$ngram
    first_result <- retrievePrediction(first_result)
    first_result <- paste("Prediction 1 ->", first_result)
    
    second_position <- weighting[z[2], ]$results
    second_result <- table[second_position, ]$ngram
    second_result <- retrievePrediction(second_result)
    second_result <- paste(" Prediction 2 ->", second_result)
    
    third_position <- weighting[z[3], ]$results
    third_result <- table[third_position, ]$ngram
    third_result <- retrievePrediction(third_result)
    third_result <- paste(" Prediction 3 ->", third_result)
    
    return(c(first_result, second_result, third_result))
  }
}