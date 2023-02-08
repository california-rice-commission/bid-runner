shinyUI(fluidPage(

    # Application title
    titlePanel("B4B Bid Runner"),

    # Sidebar with a slider input for number of bins
    tabsetPanel(
        tabPanel("Run Bid", 
                 sidebarLayout(
                     sidebarPanel(
                         width = 3, 
                         tags$h4("Shapefile Splits Parameters"),
                         textInput("bid_name", "Give bid a unique name (no spaces)"),
                         textInput("gcs_bucket", "Select Bucket for Source Data"),
                         textInput("b4b_auction_id", "Enter Auction ID for Bid"),
                         textInput("b4b_shapefile", "Enter Shapefile for Bid"),
                         textInput("b4b_split_col", "Enter Split Column for Bid"), 
                         
                         tags$hr(), 
                         tags$h4("Split-level Analysis Parameters"),
                         textInput("b4b_months", "Enter Months (comma seperated)"), 
                         textInput("b4b_waterfiles", "Enter waterfiles (comma seperated)"), 
                         
                         tags$hr(),
                         
                         textInput("b4b_output_bucket", "Enter bucket for output"), 
                         actionButton("b4b_run_bid", "Run Bid", icon = icon("rocket"), class = "btn-success"), 
                         
                         tags$hr(),
                         tags$br(),
                         tags$p("Test credentials to verify connection to GCloud is active"),
                         actionButton("check_gcp_creds", "Check Credentials"),
                         tableOutput("creds_resp_table")
                     ),
                     
                     # Show a plot of the generated distribution
                     mainPanel(
                     )
                 )),
        tabPanel("Check Running Bid", 
                 sidebarLayout(
                     sidebarPanel(
                         width = 3,
                         textInput("running_bid_name", "Enter bid name"), 
                         actionButton("running_bid_logs", "View logs", icon = icon("rocket"), class = "btn-success"),
                         
                         tags$hr(),
                         tags$h4("GCP Virtual Machine Console"),
                         tags$a(href="https://console.cloud.google.com/compute/instances?authuser=0&project=bid4birds-337119", "GCP VMs", target="_blank"),
                         tags$br(),
                         tags$br(),
                         actionButton("show_running_ce", "Show Running Bids"),
                         tableOutput("current_running_bids")
                     ),
                     
                     # Show a plot of the generated distribution
                     mainPanel(
                         tableOutput("running_bid_logs_table")
                     )
                 ))
    )
))
