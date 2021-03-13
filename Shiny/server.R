
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$plot1 <- renderPlot(getImportacionesPorPais(input$pais))

})

