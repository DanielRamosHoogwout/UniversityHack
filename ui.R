## ui ##
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(ggrepel) 
library(rgdal)
library(plotly)
library(tidyverse)
library(forecast)



# Each sidebar Item have to match with the corresponding tab Item with the tabName

# SideBar
    # To manage diferent internal tabs and external content with links.
SideBar = dashboardSidebar(
    sidebarMenu(
        menuItem("Introducción", tabName = "intro", icon = icon("th")),
        menuItem("Datos", tabName = "data", icon = icon("hdd")),
        menuItem("Análisis", icon = icon("dashboard"), startExpanded = F,
                 menuSubItem("Productos", tabName = "productos"),
                 menuSubItem("Comercio Exterior", tabName = "com_ex"),
                 menuSubItem("Mapa CCAA", tabName = "tab_map")
        ),
        menuItem("Github", icon = icon("fire"),
                 href = "https://github.com/DanielRamosHoogwout/UniversityHack")
        
    )
)

# Body
## Body content
Body =  dashboardBody(
    tabItems(
        tabItem(tabName = "data",
                h2("DATOS"),
                fluidRow(box(width = 12, solidHeader = TRUE, status = "success",
                             div(style = "text-align:justify",includeMarkdown("Docs/MD/data.md"))
                )
                )
        ),
        tabItem(tabName = "intro",
                h2("INTRODUCCIÓN"),
                fluidRow(box(width = 12, solidHeader = TRUE, status = "success",
                             div(style = "text-align:justify",includeMarkdown("Docs/MD/intro.md"))
                    )
                )
        ),
        tabItem(tabName = "productos", h1("Efecto del COVID-19 sobre productos agroalimentarios"),
                fluidRow(box(width = 12, solidHeader = T, status = "success",
                             div(style = "text-align:justify",includeMarkdown("Docs/MD/productos0.md"))
                )
                ),
                fluidRow(
                    box(width = 4, status = "success",
                        solidHeader = T,
                        selectInput("producto1", "Selecciona una producto:",
                                    choices = unique(data1$Producto)),
                        selectInput("variable1", "Selecciona una métrica:",
                                    choices = c("Volumen", "Consumo", "Precio")),
                        withSpinner(verbatimTextOutput("index"))
                       ),
                    box(width = 8,
                        solidHeader = T,
                        withSpinner(plotOutput("prod1"))
                        )

                    ),
                fluidRow(box(width = 12,
                             solidHeader = T, status = "success",
                             div(style = "text-align:justify",includeMarkdown("Docs/MD/productos.md"))
                            )
                        ),
                fluidRow(box(width = 12,
                             solidHeader = T, status = "success",
                             div(style = "text-align:justify",includeMarkdown("Docs/MD/productos1-5.md"))
                )
                ),
                fluidRow(box(width = 12,
                             solidHeader = T,
                             div(tags$img(src = "Figure1.png", height = 470, width = 824.4), style="text-align: center;"))),
                fluidRow(box(width = 12,
                             solidHeader = T, status = "success",
                             div(style = "text-align:justify",includeMarkdown("Docs/MD/productos2.md"))
                            )
                        ),
                fluidRow(box(width = 12, solidHeader = T, collapsible = T, collapsed=TRUE, title = "NOTAS TÉCNICAS", status = "success",
                        div(style = "text-align:justify",includeMarkdown("Docs/MD/notas-productos.md"))
                    )
                    )
        ),
        tabItem(tabName = "com_ex", h1("Comercio Exterior"),
                fluidRow(
                    box(width = 12, solidHeader = T, status = "success", collapsible = T, 
                        div(style = "text-align:justify",includeMarkdown("Docs/MD/Com_Ex_1.md"))
                    )
                ),
                fluidRow(
                    box(width = 4,
                        solidHeader = T, status = "success",
                        selectInput("pais", "Pais:", 
                                        choices = unique(pais_ano$Pais)),
                            hr(),
                            helpText("Selecciona un país")
                        ),
                    tabBox(title = "Total Anual", width = 8,
                           tabPanel("Valor en €", withSpinner(plotOutput("comex_eur")), color = "green"),
                           tabPanel("Cantidad en 100kg",withSpinner(plotOutput("comex_kg")))
                    )
                ),
                fluidRow(
                    box(width = 12, solidHeader = T, status = "success",
                        div(style = "text-align:justify",includeMarkdown("Docs/MD/Com_Ex_2.md"))
                        )
                )
        ),
        tabItem(tabName = "tab_map", h1("Mapa CCAA"),
               
                fluidRow(
                    box(width = 8, solidHeader = T,
                        withSpinner(plotlyOutput("map"))
                    ),
                    box(width = 4, solidHeader = T, status = "success",
                        div(style = "text-align:justify",includeMarkdown("Docs/MD/Mapa.md"))
                    )
                )
        )
))

dashboardPage(
    skin = "green",
    dashboardHeader(title = "Agro Análisis"),
    SideBar,
    Body
)
