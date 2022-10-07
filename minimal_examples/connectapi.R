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