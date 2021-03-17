## ui ##
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(ggrepel) 

# Each sidebar Item have to match with the corresponding tab Item with the tabName

# SideBar
    # To manage diferent internal tabs and external content with links.
SideBar = dashboardSidebar(
    sidebarMenu(
        menuItem("Introducción", tabName = "intro", icon = icon("th")),
        menuItem("Datos", tabName = "data", icon = icon("hdd")),
        # menuItem("Apartados", icon = icon("grain"), startExpanded = F,
        #          menuItem("Sub-Apartados", icon = icon("spider"),
        #                   menuSubItem("Sub-Sub-Apartado", tabName = "subsubapartado")
        #                   )
        #          ),
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
        # First tab content (dos cajas)
        tabItem(tabName = "data",
                h2("Datos"),
                fluidRow(box(width = 12, solidHeader = TRUE,
                             div(style = "text-align:justify",includeMarkdown("Docs/data.md"))
                )
                )
        ),
        # Second tab con texto
        tabItem(tabName = "intro",
                h2("Introducción"),
                fluidRow(box(width = 12, solidHeader = TRUE,
                             div(style = "text-align:justify",includeMarkdown("Docs/intro.md"))
                    )
                )
        ),
        # tabItem(tabName = "subsubapartado",
        #         h1("Pene")
        # ),
        tabItem(tabName = "productos", h1("Efecto del COVID-19 sobre productos agroalimentarios"),
                fluidRow( 
                    box(width = 4,
                        status = "primary",
                        selectInput("producto1", "Selecciona una producto:",
                                    choices = unique(data1$Producto)),
                        selectInput("variable1", "Selecciona una métrica:",
                                    choices = c("Volumen", "Precio", 
                                                "Consumo", "Gasto")),
                        withSpinner(verbatimTextOutput("index"))
                    ),
                    box(width = 8,
                        withSpinner(plotOutput("prod1"))
                    )
                    
                ),
                fluidRow(box(width = 12, solidHeader = TRUE,
                             div(style = "text-align:justify",includeMarkdown("Docs/productos.md"))
                )
                ),
                fluidRow(
                    box(width = 6,
                        withSpinner(plotOutput("clus"))
                )
        )),
        tabItem(tabName = "com_ex", h1("Comercio Exterior"),
                box(width = 4,      
                    # Define the sidebar with one input
                    selectInput("pais", "Pais:", 
                                    choices = unique(data4$Pais)),
                        hr(),
                        helpText("Selecciona un país")
                    ),
                # Create a spot for the barplot
                box(width = 8,
                    withSpinner(plotOutput("comex"))
                )
        ),
        tabItem(tabName = "tab_map", h1("Mapa CCAA"),
                # box(width = 4,      
                    # Define the sidebar with one input
                    # selectInput("pais", "Pais:", 
                    #             choices = unique(data4$Pais)),
                    # hr(),
                    # helpText("Selecciona un país")
                # ),
                # Create a spot for the barplot
                box(width = 8,
                    withSpinner(plotlyOutput("map"))
                )
        )
))


dashboardPage(
    dashboardHeader(title = "Agro Análisis"),
    SideBar,
    Body
)




