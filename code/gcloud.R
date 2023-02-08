b4b_deploy_gce <- function(instance_name, data_bucket, auction_id, 
                           shapefile, split_col, gb, months, waterfiles, output_bucket) {
    
    gs_bucket <- glue::glue("gs://{data_bucket}")
    gs_output_bucket <- glue::glue("gs://{output_bucket}")
    
    gce_res <- system2("gcloud", 
                       args = c(
                           "compute",
                           "instances",
                           "create-with-container",
                           instance_name,
                           "--project=bid4birds-337119",
                           "--zone=us-central1-a",
                           "--machine-type=e2-standard-16",
                           "--network-interface=network-tier=PREMIUM,subnet=default",
                           "--maintenance-policy=MIGRATE",
                           "--provisioning-model=STANDARD",
                           "--service-account=964299681615-compute@developer.gserviceaccount.com",
                           "--scopes=https://www.googleapis.com/auth/cloud-platform",
                           "--image=projects/cos-cloud/global/images/cos-stable-101-17162-40-56",
                           "--boot-disk-size=50GB",
                           "--boot-disk-type=pd-balanced",
                           "--boot-disk-device-name=b4b-compute-bid",
                           "--container-image=us-central1-docker.pkg.dev/bid4birds-337119/b4b-compute/b4bcompute:latest",
                           "--container-restart-policy=never",
                           glue::glue("--container-arg={gs_bucket}"),
                           glue::glue("--container-arg={auction_id}"),
                           glue::glue("--container-arg={shapefile}"),
                           glue::glue("--container-arg={split_col}"),
                           glue::glue("--container-arg={gb}"),
                           glue::glue("--container-arg={months}"),
                           glue::glue("--container-arg={waterfiles}"),
                           glue::glue("--container-arg={gs_output_bucket}"),
                           "--no-shielded-secure-boot",
                           "--shielded-vtpm",
                           "--shielded-integrity-monitoring",
                           "--labels=container-vm=cos-stable-101-17162-40-5",
                           "--format='json'"
                       ), 
                       stdout = TRUE)
    
    resp <- jsonlite::parse_json(gce_res[-1])
    return(resp)
}


b4b_gce_get_instance_id <- function(instance_name) {
    res <- system2(command = "gcloud", 
            args = glue::glue("compute instances describe {instance_name} --zone=us-central1-a --format=\"value(id)\""), 
            stdout = TRUE)
    
    return(res)
}

b4b_get_logs_for_instance <- function(instance_name, limit=10) {
    
    instance_id <- b4b_gce_get_instance_id(instance_name)
    
    resp <- system2(command = "gcloud", 
            args = glue::glue("logging read \"resource.type=gce_instance AND logName=projects/bid4birds-337119/logs/cos_containers AND resource.labels.instance_id={instance_id}\" --limit 20 --format=\"json\" "), 
            stdout = TRUE)
    
    json_res <- jsonlite::parse_json(resp)
    
    purrr::map_df(json_res, function(log) {
        tibble::tibble(
            log_timestamp = log$timestamp, 
            message = log$jsonPayload$message
        )
    })
}





delete_gce <- function(instance_name) {
    gce_res <- system2("gcloud", 
                       args = c(
                           "compute",
                           "instances",
                           "delete", 
                           instance_name, 
                           "--zone=us-central1-a",
                           "--format='json'"
                       ), 
                       stdout = TRUE, stderr = TRUE)
    
    message(gce_res)
}


b4b_gce_list <- function() {
    gce_res <- system2("gcloud", 
                       args = c(
                           "compute",
                           "instances",
                           "list",
                           "--format='json'"
                       ), 
                       stdout = TRUE, stderr = TRUE)
    
    resp <- jsonlite::parse_json(gce_res)
    
    purrr::map_df(resp, function(x) {
        run_time <- difftime(lubridate::now("UTC"), lubridate::as_datetime(x$creationTimestamp), units = "mins")
        tibble::tibble(
            `bid name` = x$name, 
            status = x$status, 
            `runtime (mins)` = round(run_time)
        )
    })
    
}

b4b_check_creds <- function() {
    resp <- system2("gcloud", 
                    args = c("auth list --format=\"json\""), 
                    stdout = TRUE)
    
    json_resp <- jsonlite::parse_json(resp)
    
    return(list(account = json_resp[[1]]$account, status = json_resp[[1]]$status))
}
