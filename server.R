shinyServer(function(input, output) {

    observeEvent(input$b4b_run_bid, {
        resp <- b4b_deploy_gce(
            instance_name = input$bid_name, 
            data_bucket = input$gcs_bucket, 
            auction_id = input$b4b_auction_id,
            shapefile = input$b4b_shapefile,
            split_col = input$b4b_split_col,
            gb = 48, 
            months = input$b4b_months,
            waterfiles = input$b4b_waterfiles,
            output_bucket = input$b4b_output_bucket
        )
    })
    
    observeEvent(input$gce_regresh_logs, {
        output$gce_logs <- renderTable({
            b4b_get_logs_for_instance(input$name)
        })
    })
    
    observeEvent(input$running_bid_logs, {
        output$running_bid_logs_table <- renderTable({
            b4b_get_logs_for_instance(input$running_bid_name)
        })
    })
    
    observeEvent(input$show_running_ce, {
        output$current_running_bids <- renderTable({
            b4b_gce_list()
        })
    })
    
    observeEvent(input$check_gcp_creds, {
        output$creds_resp_table <- renderTable(tibble::as_tibble(b4b_check_creds()))
    })
})
