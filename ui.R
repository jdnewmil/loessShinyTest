
library(shiny)
library(shinyRGL)

shinyUI(fluidPage(

  # Application title
  titlePanel( "LOESS Wave Fitting Simulator" ),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput( "pts"
                 , "Number of pts:"
                 , min = 1
                 , max = 500
                 , value = 100
                 ),
      sliderInput( "gridx"
                   , "Number of grid x values:"
                   , min = 10
                   , max = 101
                   , value = 41
      ),
      sliderInput( "gridy"
                 , "Number of grid y values:"
                 , min = 10
                 , max = 101
                 , value = 41
                 ),
      numericInput( "span"
                  , "LOESS Span parameter:"
                  , min = 0.01
                  , max = 20
                  , value = 0.2
                  ),
      numericInput( "noise"
                  , "Noise magnitude:"
                  , min = 0.01
                  , max = 1
                  , value = 0.1
                  )
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel( "RGL", webGLOutput( "distPlot" ) ),
        tabPanel( "Tile", plotOutput( "rasterPlot" ) ),
        tabPanel( "Contour", plotOutput( "contourPlot" ) )
      )
    )
  )
))
