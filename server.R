## server ##
library(shiny)
library(ggrepel) 

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$comex <- renderPlot(getImportacionesPorPais(input$pais))
    output$prod1 <- renderPlot(covindex(input$producto1, input$variable1, plt = T)$plot)
    output$map <- renderPlotly(final_map)
    output$clus <- renderPlot(cluster)
    output$index <- renderPrint(paste("Valor del índice:", as.character(round(covindex(input$producto1, input$variable1, plt = T)$index, 3))))
})

