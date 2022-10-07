ui <- bootstrapPage(
  h3("Session URL components: Available from interactive apps only (Shiny)"),
  verbatimTextOutput("urlText"),
  
  h3("R System components"),
  verbatimTextOutput("rText"),  
  
  h3("Env Variables"),
  verbatimTextOutput("envvarText")
)

server <- function(input, output, session) {
  
  # Return the components of the URL in a string:
  output$urlText <- renderText({
    paste(sep = "",
          "protocol: ", session$clientData$url_protocol, "\n",
          "hostname: ", session$clientData$url_hostname, "\n",
          "pathname: ", session$clientData$url_pathname, "\n",
          "port: ",     session$clientData$url_port,     "\n",
          "search: ",   session$clientData$url_search,   "\n",
          "sys info user: ",   Sys.info()[["user"]],   "\n",
          "session clientdata user: ",   session$clientData$user,   "\n",
          "session user: ",   session$user,   "\n"
    )
  })
  
  # Return R system values
  output$rText <- renderText({
    paste(sep = "",
          "linux whoami user: ",   system("whoami", intern=T),   "\n",
          "linux $USER user: ",   system('echo "$USER"', intern=T),   "\n",
          "RStudio USERNAME: ",   Sys.getenv("USERNAME"),   "\n",
          "RStudio user: ",   Sys.info()["user"],   "\n",
          "RStudio LOGNAME: ",   Sys.getenv("LOGNAME"),   "\n"
    )
  })
  
  # Environment parameters
  output$envvarText <- renderText({
    paste(
      capture.output(
        # Uncomment this to see environment variables and values 
        # str(as.list(Sys.getenv()))
        
        # Environment variable names only 
        str(as.list(names(as.data.frame(as.list(Sys.getenv())))))
      ),
      collapse = "\n"
    )
  })
}

shinyApp(ui, server)