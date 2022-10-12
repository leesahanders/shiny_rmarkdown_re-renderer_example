## These are examples for deploying programmatically using rsconnect 
# Refer to: 
# https://docs.rstudio.com/connect/admin/appendix/deployment-guide/ 
# https://rstudiopbc.atlassian.net/wiki/spaces/SUP/pages/36212280/Troubleshooting+deployments+with+rsconnect 


#################################### FIRST
# This will "auto-detect" if it has been deployed before, meaning that it depends on having the manifest.json file and rsconnect directory with the correct information

library(rsconnect)

rsconnect::writeManifest()

rsconnect::deployApp(
  appDir = getwd(),
  #appFiles = NULL,
  account = "lisa.anders",
  server = "colorado.rstudio.com"
)

#################################### SECOND
# This will attempt to deploy to the defined appId. If the content types don't match (for example, overwriting a shiny app with a static rmarkdown), then it will throw an error. User will be prompted for whether or not they want to overwrite the existing content in the Console window. 

library(rsconnect)

rsconnect::writeManifest()

rsconnect::deployApp(
  appDir = getwd(),
  appId = "12929",
  #account = "lisa.anders",
  server = "colorado.rstudio.com",
  forceUpdate = TRUE
)


#################################### THIRD
# We can also run this without needing user inputs by forcing the content to be overwritten without prompting with forceUpdate = TRUE and by authenticating to the server using an API rather than through the GUI. 

# addServer("https://colorado.rstudio.com/rsc/__api__", "myserver")
addConnectServer("https://colorado.rstudio.com/rsc/", "myserver")

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