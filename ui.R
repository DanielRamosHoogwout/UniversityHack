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
        menuItem("Datos", tabName = "dashboard", icon = icon("hdd")),
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
        tabItem(tabName = "dashboard",
                h2("Ejemplo"),
                fluidRow( # default width = 6 (half the dashboard)
                    box(title = "1.Plot", status = "primary",
                        # plotOutput("plot1", height = 250)
                        ),
                    
                    box(
                        title = "2.Controls", status = "warning",
                        sliderInput("slider", "Number of observations:", 1, 100, 50)
                    )
                ),
                fluidRow( #second fluid row
                    box(width = 2,
                        title = "3.Test Solid Header and Collapse", status = "primary",
                        solidHeader = T, collapsible = T
                    ),
                    box( width = 2,
                        title = "4.Test Background color", background = "black",
                        "text1", br(), "text2"
                    ),
                    tabBox( width = 8, # Box con multiples ventanas
                        title = "5.First tabBox",
                        id = "tabset1", height = "250px",
                        tabPanel("Tab1", "First tab content"),
                        tabPanel("Tab2", "Tab content 2")
                    )
                )
        ),
        # Second tab con texto
        tabItem(tabName = "intro",
                h2("Introducción"),
                fluidRow(box(width = 12, solidHeader = TRUE,
                             div(style = "text-align:justify",includeMarkdown("Docs/Test1.md"))
                    )
                )
        ),
        # tabItem(tabName = "subsubapartado",
        #         h1("Pene")
        # ),
        tabItem(tabName = "productos", h1("Efecto del covid sobre productos agroalimentários"),
                fluidRow( 
                    box(width = 4,
                        status = "primary",
                        selectInput("producto1", "Selecciona una producto:",
                                    choices = unique(data1$Producto)),
                        selectInput("variable1", "Selecciona una métrica:",
                                    choices = c("scVolumen", "scPrecio_Medio", 
                                                "scCons_cpt", "scGasto_cpt"))
                    ),
                    box(width = 8,
                        withSpinner(plotOutput("prod1"))
                    )
                    
                )
        ),
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




