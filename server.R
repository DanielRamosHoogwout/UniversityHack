## server ##
library(shiny)
library(ggrepel) 
library(rgdal)
library(plotly)
library(tidyverse)
library(forecast)
library(Cairo)
options(shiny.usecairo=T)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$prod1 <- renderPlot(covindex(input$producto1, input$variable1, plt = T)$plot)
    output$comex_eur <- renderPlot(getImportacionesPorPais_euros(input$pais))
    output$comex_kg <- renderPlot(getImportacionesPorPais_kg(input$pais))
    output$map <- renderPlotly(final_map)
    #output$clus <- renderPlot(cluster)
    output$index <- renderPrint(paste("Valor del índice:", as.character(round(covindex(input$producto1, input$variable1, plt = T)$index, 3))))
})

