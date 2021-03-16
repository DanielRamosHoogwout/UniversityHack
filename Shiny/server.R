
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$comex <- renderPlot(getImportacionesPorPais(input$pais))
    output$prod1 <- renderPlot(covindex(input$producto1, input$variable1, plt = T)$plot)

})

