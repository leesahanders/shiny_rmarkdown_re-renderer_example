# How to write an app that programmatically allows select users to re-render Connect documents  

This app generates a list of available content on your Connect server and uses session information about the viewer to filter document options for triggering re-rendering. 

This is a very specific example, however it explores a couple different elements that may be useful if you've come across this page. Some of these include: 

 - Variable management
 - Programmatic publishing via an API, 
 - Capturing user information through the session

I hope you are able to get from here what you need and feel to free to add an issue if you have any suggestions/requests. 


### Check it out

![Triggering the Rmarkdown to generate from a Shiny App](/img/programmatic.gif "Example output")

### Setup

The key packages being used in this example are: 

 - [connectapi package](https://github.com/rstudio/connectapi) for content list and programmatic re-rendering (which compliments  [rsconnect](https://github.com/rstudio/rsconnect) )
 - [usethis](https://usethis.r-lib.org/index.html) for storing environment variables
 - [Shiny](https://shiny.rstudio.com/) for app framework and reactivity
 - [dplyr](https://dplyr.tidyverse.org/) for readability

### Shiny 

A simple reactive shiny template was used for setting up the initial reactivity. 

<details>
  <summary>Relevant reading:</summary>: 

 - Starting template: <https://shiny.rstudio.com/articles/dynamic-ui.html> 
 - Mastering shiny: <https://mastering-shiny.org/action-dynamic.html> 
 - Amazing database shiny app: <https://shanghai.hosting.nyu.edu/data/r/case-4-database-management-shiny.html> 
 - Shiny app as a package: <https://engineering-shiny.org/structuring-project.html> 
 - Converting a shiny app to async: <https://rstudio.github.io/promises/articles/casestudy.html> 
 - Shiny filter based on user inputs for dataframe: <https://stackoverflow.com/questions/72091981/r-shiny-filter-data-based-on-user-input-and-update-the-plot> 
 - Shiny app dealing with json: <https://community.rstudio.com/t/shiny-download-data-with-filter-parameters/80915/6> 
 - Shiny filters: <https://www.rdocumentation.org/packages/shinyfilter/versions/0.1.1> 
 - Build a login page in shiny: <https://www.listendata.com/2019/06/how-to-add-login-page-in-shiny-r.html>

</details>


### Variables are being saved to the user level .Renviron config file

For this project the following variables are being saved in the .Renviron file (credentials are stripped for security): 

 - CONNECT_API_KEY=**REDACTED**
 - CONNECT_SERVER=**REDACTED**
 - OWNER_GUID=**REDACTED**


[`usethis`](https://usethis.r-lib.org/) has a function for creating and editing the .Renviron file

```r
library(usethis)
usethis::edit_r_environ()
```

Add the variables to that file in the format `variable_name = "variable_value"` and save it. Restart the session so the new environment variables will be loaded with `ctrl shift f10` or through the RStudio IDE through the **Session** dropdown and selecting **Restart R**. 

Saved variables can be accessed with:

```r
variable_name <- Sys.getenv("variable_name")
```

 

<details>
  <summary>Relevant reading:</summary>

When working in a more complex environment structure where separate project, site, and user environments are being used [this support article has useful information](https://support.rstudio.com/hc/en-us/articles/360047157094-Managing-R-with-Rprofile-Renviron-Rprofile-site-Renviron-site-rsession-conf-and-repos-conf) with a [deeper dive into R's startup here](https://rviews.rstudio.com/2017/04/19/r-for-enterprise-understanding-r-s-startup/).

</details>

### Package management is using renv

This project is using [renv](https://rstudio.github.io/renv/articles/collaborating.html). In order to set up this example and have a working example run: 

```
library(renv)
renv::restore()
```

### Capturing user information 

By adding `session` to your server argument, the `session$clientData` can be accessed inside the app same as any `input` parameter. 

In this example (expanded on from [here](https://shiny.rstudio.com/articles/client-data.html)) the app will display the outputs of various session, R profile, and environment variables. 

<details>
  <summary>Example code, click to expand</summary>
    
```r
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

```

</details>

The output will show: 

![alt text](/img/session-image.PNG "Example output")


<details>
  <summary>Relevant reading:</summary>

 - [https://shiny.rstudio.com/articles/client-data.html](https://shiny.rstudio.com/articles/client-data.html)
 - [https://shiny.rstudio.com/articles/permissions.html](https://shiny.rstudio.com/articles/permissions.html)
 - [https://shiny.rstudio.com/reference/shiny/latest/session.html](https://shiny.rstudio.com/reference/shiny/latest/session.html)
 - [https://stackoverflow.com/questions/62546575/how-to-get-users-information-in-rshiny](https://stackoverflow.com/questions/62546575/how-to-get-users-information-in-rshiny)
 - [https://community.rstudio.com/t/identifying-current-user-in-rstudio-connect/33626/4](https://community.rstudio.com/t/identifying-current-user-in-rstudio-connect/33626/4)
 
 - Blog post on shiny usage tracking: <https://www.rstudio.com/blog/track-shiny-app-use-server-api/> 
 - Blog post about connect in general: <https://www.rstudio.com/blog/sharing-shiny-apps-on-rstudio-connect/> 
 - Sean Lopps article about using Connect with usage tracking: <https://shiny.rstudio.com/articles/usage-metrics.html> 
 - Filtering app based on viewer location: <https://stackoverflow.com/questions/40795172/shiny-how-to-filter-data-based-on-location-of-user-input-data> 
 - Tracking user activity support article: <https://support.rstudio.com/hc/en-us/articles/360041320233-How-do-I-track-user-activity-within-a-Shiny-application-> 
 - Great post from a user with rstudio connect getting user info: <https://stackoverflow.com/questions/62546575/how-to-get-users-information-in-rshiny>
 
 - The sales report app writeup: <https://shiny.rstudio.com/articles/permissions.html> 
 - The sales app code, at least the original version of it before it was moved: <https://github.com/Tavpritesh/shiny-dev-gallery/tree/master/personalized-ui> 
 - The docker repo, archived, with the sales app: <https://github.com/rstudio/docker-shiny-gallery/tree/master/ssp-personalized-ui> 

</details>

### Programmatic rendering 

There are two options for triggering rendering from the console. We can either use rsconnect to trigger publishing (where the content to be published is in the same folder as the app doing the triggering) or we can use connectapi to interface with the API to trigger render on our behalf for already published content. 

Using rsconnect: 

<details>
  <summary>Example, click to expand</summary>

This is the most basic version of publishing, showing the bare minimum that needs to be contained in order to successful deploy an app programmatically: 

```r
library(rsconnect)

rsconnect::writeManifest()

rsconnect::deployApp(
  appDir = getwd(),
  #appFiles = NULL,
  account = "lisa.anders",
  server = "colorado.rstudio.com"
)
```

This will attempt to deploy to the defined appId. If the content types don't match (for example, overwriting a shiny app with a static rmarkdown), then it will throw an error. User will be prompted for whether or not they want to overwrite the existing content in the Console window. 

```r
library(rsconnect)

rsconnect::writeManifest()

rsconnect::deployApp(
  appDir = getwd(),
  appId = "12929",
  #account = "lisa.anders",
  server = "colorado.rstudio.com",
  forceUpdate = TRUE
)
```

We can also run this without needing user inputs by forcing the content to be overwritten without prompting with forceUpdate = TRUE and by authenticating to the server using an API rather than through the GUI. 

```r
addConnectServer(Sys.getenv("CONNECT_SERVER"), "myserver")

# Connecting account via API key
rsconnect::connectApiUser(
  account = "lisa.anders",
  server = "myserver",
  apiKey = Sys.getenv("CONNECT_API_KEY"),
  forceUpdate = TRUE
)

message("Please wait, publishing")

rsconnect::deployApp(
  appDir = getwd(),
  appId = "12929",
  forceUpdate = TRUE
)
```

</details>


Using connectapi: 

<details>
  <summary>Example, click to expand</summary>

```r
library(rsconnect)
library(connectapi)
library(dplyr)

client <- connectapi::connect(
  server = Sys.getenv("CONNECT_SERVER"),
  api_key = Sys.getenv("CONNECT_API_KEY")
)

# Get list of all users so I can find my guid
users <- get_users(client, limit = Inf)

# Get list of pieces of content that I've deployed, so we can select a piece to re-deploy
content <- get_content(client, owner_guid = Sys.getenv("OWNER_GUID"), limit = Inf) %>%
  filter(grepl("rmd-static", app_mode, ignore.case = TRUE))

# Get details about a specific content item we want to trigger and any variants that already exist 
rmd_content <- content_item(client, "caffdf48-1f24-43c1-93a9-d0da6765abf1")
rmd_content_variant <- get_variant_default(rmd_content)

# Create object that will execute a variant on demand
my_rendering <- variant_render(rmd_content_variant)

# Trigger render, poll task while waiting for information about a deployment and message out the result. 
poll_task(my_rendering)

# Returns all renderings / content for a particular variant.
variant_history <- get_variant_renderings(rmd_content_variant)
```

</details>

<details>
  <summary>Relevant reading:</summary>

 - [connectapi package](https://github.com/rstudio/connectapi) for content list and programmatic re-rendering (which compliments   -  -  - [rsconnect](https://github.com/rstudio/rsconnect) )
 - [RStudio Connect: Server API Cookbook](https://docs.rstudio.com/connect/cookbook/deploying/)
 - [connectapi render](https://pkgs.rstudio.com/connectapi/reference/render.html)
 - [connectapi](https://pkgs.rstudio.com/connectapi/index.html)
 - [connectapi git](https://github.com/rstudio/connectapi)
 - [Community post on programmatic publishing](https://community.rstudio.com/t/programmatically-triggering-re-rendering-of-rmarkdown-document-hosted-on-rstudioconnect/61028)

</details>

### Bonus: Loading widgets! 

For this example a spinner widget has been added using [shinycssloaders](https://github.com/daattali/shinycssloaders) as well as a Modal pop-up message using [ModalURL](https://shiny.rstudio.com/reference/shiny/1.6.0/urlModal.html). 


<details>
  <summary>Relevant reading:</summary>

 - Progress bars: <https://shiny.rstudio.com/articles/progress.html> 
 - On best practices and preventing kicking off a ton of updates: <https://www.r-bloggers.com/2018/07/long-running-tasks-with-shiny-challenges-and-solutions/> Showing notifications: <https://shiny.rstudio.com/articles/notifications.html> 
 - Dean's blog post on busy indicator's: <https://deanattali.com/blog/advanced-shiny-tips/#busy-indicator>
 - Example of ModalURL: <https://community.rstudio.com/t/how-to-embed-a-hyperlink-in-modaldialog-text/52420>
 - One day I hope to understand and use isolation: <https://shiny.rstudio.com/articles/isolation.html> 
 - Tangentially related interesting post about closure error messages: <https://coolbutuseless.github.io/2019/02/12/object-of-type-closure-is-not-subsettable/> 

</details>


### Bonus: Git link! 

Using the [gitlink](https://github.com/colearendt/gitlink) package developed by Cole. 



