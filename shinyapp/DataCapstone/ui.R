library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  # Application title
  titlePanel("Next Word Prediction Application"),
  
  # Show a plot of the generated distribution
  mainPanel(tabsetPanel(
    type = "tabs",
    
    tabPanel("Help & Examples",
             
             includeHTML("examples.html")),
    
    tabPanel(
      "Try it!",
      
      helpText(
        br(),
        "Enter a phrase of any length, consisting of any characters,",
        br(),
        " and in lower/mixed/upper case in the box below.",
        br(),
        br(),
        "Then click the button to see the top 1, 2, or 3 predictions!"
      ),
      
      textInput(
        "text",
        label = h3("Input your phrase here"),
        value = ""
      ),
      
      submitButton("Predict Next Word"),
      
      br(),
      
      verbatimTextOutput("prediction")
      
    )
    
  ))
))