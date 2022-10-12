# Shiny app for re-rendering already published documents on a Connect server 

#### Global ####

library(shiny)
library(rsconnect)
library(connectapi)
library(dplyr)
library(shinycssloaders)
library(gitlink) # https://github.com/colearendt/gitlink

client <- connectapi::connect(
  server = 'https://colorado.rstudio.com/rsc/',
  api_key = Sys.getenv("CONNECT_API_KEY")
)

# Get list of pieces of content that I've deployed, so we can select ones to update
content <- get_content(client, owner_guid = Sys.getenv("OWNER_GUID"), limit = Inf) %>%
  filter(grepl("rmd-static", app_mode, ignore.case = TRUE)) 

#### Shiny App ####

ui <- shinyUI(
  fluidPage(
    ribbon_css("https://github.com/leesahanders/Shiny_Rmarkdown_Rendererer_Example", text = "Link to Code (git)", fade = FALSE),
    titlePanel("Programmatic Document Updates Example"),
    helpText("Select a piece of content to update"),
    h3("Logged in user"),
    verbatimTextOutput("userText"),
    selectInput("rmd_content", "Content", choices = NULL),
    actionButton("report", "Update Report", class = "btn-success"), 
    uiOutput("rmd_url"),
    shinycssloaders::withSpinner(htmlOutput("document"), color = "#0dc5c1", color.background = "#0275D8", type=3, size = 2, hide.ui = FALSE),
  )
)

server <- function(input, output, session) {
  
  output$userText <- renderText({
    paste( sep = "",
           "Welcome ", session$user,"!", "\n"
    )
  })
  
  ui_rmd <- eventReactive(input$report, {
    
    # Lookup guid from content name
    message("Starting update, please wait")
    content_guid <- content %>% filter(name == rmd()) %>% select(guid)
    
    # Get details about the content item we want to trigger and any variants that already exist
    rmd_content <- content_item(client, content_guid)
    rmd_content_variant <- get_variant_default(rmd_content)
    
    # # Create object that will execute a variant on demand
    my_rendering <- variant_render(rmd_content_variant)
    
    # Trigger render, poll task while waiting for information about a deployment and message out the result.
    message("Polling update task, please wait")
    poll_task(my_rendering)
    content_url <- content %>% filter(name == rmd()) %>% select(content_url)
    
    # Pop-up box when done
    showModal(modalDialog(
      title = "Complete ",
      tags$div("Finished: ", tags$a(href = content_url, " Document updated .")),
      easyClose = TRUE
    ))
    
    # HTML(paste0("<p>Update complete</p>"))
  })
  
  output$document <- renderUI({
    ui_rmd()
  })
  
  user <- reactive({
    session$user
  })
  
  observeEvent(user(), {
    choices <- case_when(
      user() == "lisa.anders" ~ unique(content$name[1-9]),
      user() == "roger.andre" ~ unique(content$name[1-2]),
      TRUE ~ unique(content$name[1])
    )
    updateSelectInput(inputId = "rmd_content", choices = choices)
  })
  
  rmd <- reactive({
    input$rmd_content
  })
  
  output$rmd_url <- renderUI({
    content_url <- content %>% filter(name == rmd()) %>% select(content_url)
    url <- a("link", href=content_url)
    HTML(paste("Document selected: ", url))
  })
  
}

shinyApp(ui, server)


