# Shiny app for re-rendering already published documents on a Connect server 

#### Global ####

library(shiny)
library(rsconnect)
library(connectapi)
library(dplyr)
library(shinycssloaders)

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
    titlePanel("Programmatic Document Updates Example"),
    helpText("Select a piece of content to update"),
    selectInput("change_users", "Change to a different user", choices = c("Don't switch", "Lisa1", "Lisa2")),
    selectInput("rmd_content", "Content", choices = NULL),
    actionButton("report", "Update Report", class = "btn-success"), 
    uiOutput("rmd_url"),
    shinycssloaders::withSpinner(htmlOutput("document"), color = "#0dc5c1", color.background = "#0275D8", type=3, size = 2),
    verbatimTextOutput("sessionText"),
    verbatimTextOutput("envvarText")
  )
)

server <- function(input, output, session) {
  
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
    
    showModal(modalDialog(
      title = "Complete ",
      # paste0("Update complete: ",content_url),
      #urlModal(url = content_url, title = "Link", subtitle = NULL),
      #paste0('Update complete: <a href="',content_url,'">Link</a>'),
      tags$div("Finished: ", tags$a(href = content_url, " Document updated .")),
      easyClose = TRUE
    ))
    
    HTML(paste0("<p>Update complete</p>"))
  })
  
  output$document <- renderUI({
    ui_rmd()
  })
  
  user <- reactive({
    input$change_users
  })
  
  observeEvent(user(), {
    choices <- case_when(
      user() == "Lisa1" ~ unique(content$name[1-4]),
      user() == "Lisa2" ~ unique(content$name[4-9]),
      TRUE ~ unique(content$name[1-2])
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
  
  # Exploring session information for seeing current user
  output$sessionText <- renderText({
    paste(sep = "",
          "protocol: ", session$clientData$url_protocol, "\n",
          "hostname: ", session$clientData$url_hostname, "\n",
          "pathname: ", session$clientData$url_pathname, "\n",
          "port: ",     session$clientData$url_port,     "\n",
          "search: ",   session$clientData$url_search,   "\n",
          "sys info user: ",   Sys.info()[["user"]],   "\n",
          "session clientdata user: ",   session$clientData$user,   "\n",
          "session user: ",   session$user,   "\n",
          "linux whoami user: ",   system("whoami", intern=T),   "\n",
          "linux $USER user: ",   system('echo "$USER"', intern=T),   "\n",
          "RStudio USERNAME: ",   Sys.getenv("USERNAME"),   "\n",
          "RStudio user: ",   Sys.info()["user"],   "\n",
          "RStudio LOGNAME: ",   Sys.getenv("LOGNAME"),   "\n",
          "/etc/passwd file: ", paste0(system("sed 's/:.*//' /etc/passwd | sort -r", intern=T), collapse = ", "),   "\n",
          "rstudio-connect group: ", paste0(system("getent group rstudio-connect", intern=T), collapse = ", "),   "\n"
    )
  })
  
  # Exploring env information for seeing current user
  # output$envvarText <- renderText({
  #   paste(
  #     capture.output(
  #       str(as.list(Sys.getenv()))
  #     ),
  #     collapse = "\n"
  #   )
  # })
}

shinyApp(ui, server)


