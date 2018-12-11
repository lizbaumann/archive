library(shiny)
xoptions <- c("age", "year", "thickness")
coloroptions <- c("alive_or_died", "gender", "has_ulcer")

shinyUI(pageWithSidebar(
        headerPanel("Malignant Melanoma Data: Patient Survival Time"),
        sidebarPanel(
                em('Source: R MASS package. The Melanoma data frame has data on 
                   205 patients in Denmark with malignant melanoma.'),
                h4('Choose X-variable and how to color this plot against patient survival time:'),
                selectInput('xvar', 'X Variable*:', xoptions),
                selectInput('color', 'Color plot by:', coloroptions,
                            selected=coloroptions[[2]]), 
                p('* thickness = tumour thickness in mm. year = year of operation.')
        ),
        mainPanel(
                plotOutput('plot1')
        )
))

