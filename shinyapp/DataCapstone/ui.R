#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Next Word Prediction"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(

    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       textInput("text", label = h3("Text input"), value = ""),
       
       submitButton("Predict Next Word"),
       helpText("When you click the button above, you should see",
                "the output below update to reflect the value you",
                "entered at the top:"),
       verbatimTextOutput("prediction")
    )
  )
))
