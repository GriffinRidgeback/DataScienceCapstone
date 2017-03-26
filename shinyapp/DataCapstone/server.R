#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)

bi.gram.table <- readRDS("./data/bi.gram.table.rds")
tri.gram.table <- readRDS("./data/tri.gram.table.rds")
quad.gram.table <- readRDS("./data/quad.gram.table.rds")
quint.gram.table <- readRDS("./data/quint.gram.table.rds")

source("predictionAlgorithm.R")

shinyServer(function(input, output) {

  # userInput <- reactive({
  userInput <- renderText({
    
    inputString <- sanitizeInput(input$text)
    
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
    if (l >= 4) {
      # Use quintgram table to find completion for quadgram
      print("PROCESSING QUINTGRAMS")
      results <- searchNGrams(inputString, quint.gram.table)
      if (length(results) != 0) {
        predictions <- processResults(quint.gram.table, results)
        print(paste("Predictions from quintgram table", predictions))
        return(predictions)
      }
      else {
        # Use quadgram table to find completion for trigram
        print("PROCESSING QUADGRAMS")
        inputString <- reduceNGram(inputString)
        results <- searchNGrams(inputString, quad.gram.table)
        if (length(results) != 0) {
          predictions <- processResults(quad.gram.table, results)
          print(paste("Predictions from quadgram table", predictions))
          return(predictions)
        }
        else {
          # Use trigram table to find completion for bigram
          print("PROCESSING TRIGRAMS")
          inputString <- reduceNGram(inputString)
          results <- searchNGrams(inputString, tri.gram.table)
          if (length(results) != 0) {
            predictions <- processResults(tri.gram.table, results)
            print(paste("Predictions from trigram table", predictions))
            return(predictions)
          }
          else {
            # Use bigram table to find completion for unigram
            print("PROCESSING BIGRAMS")
            inputString <- reduceNGram(inputString)
            results <- searchNGrams(inputString, bi.gram.table)
            if (length(results) != 0) {
              predictions <- processResults(bi.gram.table, results)
              print(paste("Predictions from bigram table", predictions))
              return(predictions)
            }
            else {
              predictions <- "No prediction possible"
              return(predictions)
            }
          }
        }
      }
    }

    if (l == 3) {
      # Use quadgram table to find completion for trigram
      print("PROCESSING QUADGRAMS")
      results <- searchNGrams(inputString, quad.gram.table)
      if (length(results) != 0) {
        predictions <- processResults(quad.gram.table, results)
        print(paste("Predictions from quadgram table", predictions))
        return(predictions)
      }
      else {
        # Use trigram table to find completion for bigram
        print("PROCESSING TRIGRAMS")
        inputString <- reduceNGram(inputString)
        results <- searchNGrams(inputString, tri.gram.table)
        if (length(results) != 0) {
          predictions <- processResults(tri.gram.table, results)
          print(paste("Predictions from trigram table", predictions))
          return(predictions)
        }
        else {
          # Use bigram table to find completion for unigram
          print("PROCESSING BIGRAMS")
          inputString <- reduceNGram(inputString)
          results <- searchNGrams(inputString, bi.gram.table)
          if (length(results) != 0) {
            predictions <- processResults(bi.gram.table, results)
            print(paste("Predictions from bigram table", predictions))
            return(predictions)
          }
          else {
            predictions <- "No prediction possible"
            return(predictions)
          }
        }
      }
    }

    if (l == 2) {
      # Use trigram table to find completion for bigram
      print("PROCESSING TRIGRAMS")
      results <- searchNGrams(inputString, tri.gram.table)
      if (length(results) != 0) {
       predictions <- processResults(tri.gram.table, results)
       print(paste("Predictions from trigram table", predictions))
       return(predictions)
      }
      else {
        # Use bigram table to find completion for unigram
        print("PROCESSING BIGRAMS")
        inputString <- reduceNGram(inputString)
        results <- searchNGrams(inputString, bi.gram.table)
        if (length(results) != 0) {
          predictions <- processResults(bi.gram.table, results)
          print(paste("Predictions from bigram table", predictions))
          return(predictions)
        }
        else {
          predictions <- "No prediction possible"
          return(predictions)
        }
      }
    }
    
    if (l == 1) {
      # Use bigram table to find completion for unigram
      results <- searchNGrams(inputString, bi.gram.table)
      if (length(results) != 0) {
        predictions <- processResults(bi.gram.table, results)
        return(predictions)
      }
      else {
        predictions <- "No prediction possible"
        return(predictions)
      }
    }
    
  })

  output$prediction <- userInput
  
})