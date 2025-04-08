terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "bigquery.googleapis.com",
    "storage-component.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  
  project = var.project_id
  service = each.key
  disable_on_destroy = false
}

# Service account for the project
resource "google_service_account" "citibike_sa" {
  account_id   = "citibike-project"
  display_name = "Citibike Project Service Account"
  project      = google_project_service.apis["iam.googleapis.com"].project
}

# Create GCS bucket
resource "google_storage_bucket" "project_bucket" {
  name          = var.bucket_name
  location      = "US"
  storage_class = "STANDARD"
  force_destroy = false

  versioning {
    enabled = true
  }

  labels = {
    environment = "dev"
  }

  depends_on = [
    google_project_service.apis["storage-component.googleapis.com"]
  ]
}

# Create BigQuery dataset
resource "google_bigquery_dataset" "project_dataset" {
  dataset_id    = var.bigquery_dataset_id
  friendly_name = "Citibike Trip Data"
  description   = "Dataset for Citibike trip data"
  location      = "US"

  labels = {
    environment = "dev"
  }

  depends_on = [
    google_project_service.apis["bigquery.googleapis.com"]
  ]
}

# IAM bindings
resource "google_project_iam_binding" "bq_access" {
  project = google_project_service.apis["iam.googleapis.com"].project
  role    = "roles/bigquery.admin"

  members = [
    "serviceAccount:${google_service_account.citibike_sa.email}",
  ]

  depends_on = [
    google_service_account.citibike_sa
  ]
}

resource "google_project_iam_binding" "gcs_access" {
  project = google_project_service.apis["iam.googleapis.com"].project
  role    = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.citibike_sa.email}",
  ]

  depends_on = [
    google_service_account.citibike_sa
  ]
}

# Optionally grant the service account access to the bucket
resource "google_storage_bucket_iam_binding" "bucket_access" {
  bucket = google_storage_bucket.project_bucket.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.citibike_sa.email}",
  ]
}

# Output important information
output "service_account_email" {
  value = google_service_account.citibike_sa.email
}

output "bucket_name" {
  value = google_storage_bucket.project_bucket.name
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.project_dataset.dataset_id
}