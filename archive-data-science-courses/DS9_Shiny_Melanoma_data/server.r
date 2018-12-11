library(ggplot2)
library(MASS)
data(Melanoma)
# time, status, sex, age, year, thickness, ulcer

# Goal: plot of an x var to y=time, colored by alivedead, gender, hasulcer
mel <- Melanoma
# create factor names for status, sex, ulcer variables
mel$alive_or_died[mel$status==1] <- 'Died_from_melanoma'
mel$alive_or_died[mel$status==2] <- 'Alive'
mel$alive_or_died[mel$status==3] <- 'Died_from_other_cause'

mel$gender[mel$sex==1] <- 'Male'
mel$gender[mel$sex==0] <- 'Female'
mel$sex[mel$sex==0] <- 2 # for coloring

mel$has_ulcer[mel$ulcer==1] <- 'Yes'
mel$has_ulcer[mel$ulcer==0] <- 'No'
mel$ulcer[mel$ulcer==0] <- 2 # for coloring

shinyServer(function(input, output, session) {
        
        # Combine the selected variables into a new data frame
        selectedXY <- reactive({
                mel[, c(input$xvar, "time")]
        })

        selectedColorName <- reactive({
                mel[, input$color]
        })

        selectedColorVal <- reactive({
                colorvals <- ifelse(input$color=="alive_or_died", "status", 
                                    ifelse(input$color=="gender", "sex", "ulcer"))
                mel[, colorvals]        
        })
        
        output$plot1 <- renderPlot({
                par(mar = c(5.1, 4.1, 0, 1))
                plot(selectedXY(),
                     col = selectedColorVal(),
                     pch = 20, cex = 2, ylab = 'survival time in days')
                legend("topright", pch = 20, title = input$color, 
                       legend = unique(selectedColorName()), 
                       col = unique(selectedColorVal()))
        })
        
})
