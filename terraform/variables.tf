variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "citibike-zoomcamp-project"
}

variable "region" {
  description = "The region to deploy the resources"
  type        = string
  default     = "us-central1"
}

variable "credentials_file" {
  description = "The path to the GCP service account key file"
  type        = string
  default     = "/home/yassersakr88/de-zoomcamp/citibike-zoomcamp-project-f8db35d0ef0e.json"
}

variable "bucket_name" {
  description = "The name of the Google Cloud Storage bucket"
  type        = string
  default     = "citibike-bucket"
}

variable "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset"
  type        = string
  default     = "citibike_tripdata"
}