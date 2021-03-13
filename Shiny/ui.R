## ui.R ##
library(shiny)
library(shinydashboard)
library(shinycssloaders)

# Each sidebar Item have to match with the corresponding tab Item with the tabName

# SideBar
    # To manage diferent internal tabs and external content with links.
SideBar = dashboardSidebar(
    sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Widgets", tabName = "widgets", icon = icon("th")),
        menuItem("Apartados", icon = icon("grain"), startExpanded = F,
                 menuItem("Sub-Apartados", icon = icon("spider"),
                          menuSubItem("Sub-Sub-Apartado", tabName = "subsubapartado")
                          )
                 ),
        menuItem("Github", icon = icon("fire"),
                 href = "https://github.com/DanielRamosHoogwout/UniversityHack"),
        menuItem("Test1", tabName = "test1")
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
                        plotOutput("plot1", height = 250)),
                    
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
                    ),
                )
        ),
        # Second tab content
        tabItem(tabName = "widgets",
                h2("Widgets tab content")
        ),
        tabItem(tabName = "subsubapartado",
                h1("Pene")
        ),
        tabItem(tabName = "test1", h1("Test1"),
                box(width = 4,      
                    # Define the sidebar with one input
                    selectInput("pais", "Pais:", 
                                    choices = unique(data4$Pais)),
                        hr(),
                        helpText("Selecciona un país")
                    ),
                # Create a spot for the barplot
                box(width = 8,
                    withSpinner(plotOutput("plot1"))
                )
    )
))


dashboardPage(
    dashboardHeader(title = "Agro Análisis"),
    SideBar,
    Body
)




