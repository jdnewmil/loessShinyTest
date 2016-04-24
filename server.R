
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(rgl)
options( rgl.useNULL = TRUE )
library(shinyRGL)
library(ggplot2)
library(directlabels)

gridxmin <- -5
gridxmax <- 5
gridymin <- -5
gridymax <- 5

shinyServer( function( input, output ) {

  dta2 <- reactive({
    set.seed( 41 )
    N <- input$pts
    result <- data.frame( x = runif( N, gridxmin, gridxmax )
                        , y = runif( N, gridymin, gridymax )
                        )
    result$z <- with( result, sin( sqrt( x^2 + y^2 ) ) ) + rnorm( N, 0, input$noise )
    result
  })
  
  dta2.l <- reactive({
    loess( z ~ x + y, data = dta2(), degree = 1, span = input$span )
  })
  
  dta2.r <- reactive({
    result <- setNames( vector( "list", 4 )
                      , c( "zs", "df", "pred.x", "pred.y" )
                      )
    result$pred.x <- seq( gridxmin, gridxmax, length.out = input$gridx )
    result$pred.y <- seq( gridymin, gridymax, length.out = input$gridy )
    result$df <- expand.grid( x = result$pred.x, y = result$pred.y )
    result$zs <- predict( dta2.l(), newdata = result$df, se = FALSE )
    result$df$z <- as.vector( result$zs )
    result$df$z[ is.na( result$df$z ) ] <- 0
    result
  })
  
  output$distPlot <- renderWebGL({

    open3d()
    axes3d()
    dtar <- dta2.r()
    with( dtar, surface3d( pred.x, pred.y, zs, col="green" ) )
    with( dta2(), points3d( x, y, z ) )
    title3d( xlab = "x", ylab = "y", zlab = "z" )
  })
  
  output$rasterPlot <- renderPlot({
    dtar <- dta2.r()
    ggplot( dtar$df, aes( x=x, y=y, z=z, fill=z ) ) +
      geom_raster( stat = "identity" )
  })

  output$contourPlot <- renderPlot({
    dtar <- dta2.r()
    ggp <- ggplot( dtar$df, aes( x=x, y=y, z=z ) ) +
      geom_contour( mapping = aes( x=x, y=y, z=z, colour = ..level.. ) )
    direct.label( ggp, "bottom.pieces" )
  })
  
})
