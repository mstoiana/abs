if (!requireNamespace("shiny", quietly = TRUE)) {
  install.packages("shiny")
}
if (!requireNamespace("rsdmx", quietly = TRUE)) {
  install.packages("rsdmx")
}
#Load libraries 
library(shiny)
library(rsdmx)

#UI Definition https://mastering-shiny.org/action-layout.html 
ui <- fluidPage(
  titlePanel("SDMX Data Retrieval"),
  sidebarLayout(
    sidebarPanel(
      textInput("dataflowID", "Enter a Dataflow ID from https://api.data.abs.gov.au/dataflow", value = ""),
      textInput("startDate", "Enter a start date for the data. If no startPeriod is provided, data will be returned from the earliest period available", value = ""),
      textInput("endDate", "Enter an end date for the data  If no endPeriod is provided data will be returned to the latest period available.", value = ""),
      actionButton("submit", "Submit"),
      textOutput("errorMsg")
    ),
    mainPanel(
      tableOutput("data"),
      textOutput("timeTaken"),
      tableOutput("dimensions")
    )
  )
)

#Server
server <- function(input, output) {
  observeEvent(input$submit, {
    req(input$dataflowID) # Ensure Dataflow ID is provided
    
    #Construct args for rsdmx
    args <- list(providerId = "ABS", resource = "data", flowRef = input$dataflowID)
    error_msg <- NULL
    
    if (nzchar(input$startDate)) {
      args$start <- input$startDate
    }
    
    if (nzchar(input$endDate)) {
      args$end <- input$endDate
    }
    
    start.time <- Sys.time()
    
    # Call readSDMX with the constructed argument list
    sdmx <- do.call(readSDMX, args)
    df <- as.data.frame(sdmx)
    
    end.time <- Sys.time()
    
    output$data <- renderTable({
      head(df)
    })
    
    output$timeTaken <- renderText({
      paste("Import time taken:", as.numeric(difftime(end.time, start.time, units = "secs")), "seconds")
    })
    output$dimensions <- renderTable({
      dim(df)
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
#todo store data locally and add metadata
