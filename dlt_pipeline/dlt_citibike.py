import dlt
import requests
import os
import zipfile
import pandas as pd
import argparse
from google.cloud import storage
from datetime import datetime

# Configure GCS & BigQuery
gcs_bucket_name = "citibike-bucket"
bigquery_project_id = "citibike-zoomcamp-project"
bigquery_dataset_id = "citibike_tripdata"
bigquery_table_name = "citibike_trips"

# Set local storage paths
local_storage_path = "citibike_local_data"
os.makedirs(local_storage_path, exist_ok=True)

# Citi Bike source URL
s3_base_url = "https://s3.amazonaws.com/tripdata/"
file_prefix = "JC"

# Setup argument parser
parser = argparse.ArgumentParser(description="Run the pipeline for CitiBike data")
parser.add_argument('--year', type=str, required=True, help="Year for CitiBike data")
args = parser.parse_args()
year = args.year

# Initialize GCS client
storage_client = storage.Client()
bucket = storage_client.bucket(gcs_bucket_name)

def upload_to_gcs(local_path, gcs_path):
    """Upload a file to GCS in Parquet format"""
    try:
        blob = bucket.blob(gcs_path)
        blob.upload_from_filename(local_path)
        print(f"Uploaded {local_path} to gs://{gcs_bucket_name}/{gcs_path}")
    except Exception as e:
        print(f"Failed to upload {local_path} to GCS: {e}")

def process_monthly_data(month):
    """Download, process and upload monthly data"""
    file_url = f"{s3_base_url}{file_prefix}-{year}{month:02d}-citibike-tripdata.csv.zip"
    print(f"Processing {file_url}...")
    
    # Download and unzip
    response = requests.get(file_url)
    if response.status_code != 200:
        print(f"Failed to download {file_url}")
        return None
    
    zip_file_name = os.path.join(local_storage_path, file_url.split("/")[-1])
    with open(zip_file_name, "wb") as zip_file:
        zip_file.write(response.content)
    
    with zipfile.ZipFile(zip_file_name, 'r') as zip_ref:
        # Skip __MACOSX directory if it exists
        for file in zip_ref.namelist():
            if "__MACOSX" not in file:
                zip_ref.extract(file, local_storage_path)
        
        # Get the extracted CSV file
        csv_file = None
        for file in zip_ref.namelist():
            if file.endswith(".csv"):
                csv_file = os.path.join(local_storage_path, file)
                break
    
    if not csv_file:
        print(f"No CSV file found in {zip_file_name}")
        return None
    
    # Process and convert to Parquet
    df = pd.read_csv(csv_file)

    # Check if 'started_at' and 'ended_at' exist, and handle accordingly
    if 'started_at' not in df.columns or 'ended_at' not in df.columns:
        print(f"Missing 'started_at' or 'ended_at' columns in the CSV file.")
        return None
    
    # Basic cleaning
    df = df.dropna(subset=['started_at', 'ended_at'])
    df['started_at'] = pd.to_datetime(df['started_at'])
    df['ended_at'] = pd.to_datetime(df['ended_at'])
    
    # Save as Parquet
    parquet_file = csv_file.replace('.csv', '.parquet')
    df.to_parquet(parquet_file, index=False)
    
    # Upload to GCS
    gcs_path = f"citibike/{year}/{os.path.basename(parquet_file)}"
    upload_to_gcs(parquet_file, gcs_path)
    
    return parquet_file

@dlt.source
def citibike_data():
    """Process all months and yield combined data"""
    all_data = []
    
    for month in range(1, 13):
        parquet_file = process_monthly_data(month)
        if parquet_file:
            df = pd.read_parquet(parquet_file)
            all_data.append(df)
    
    if all_data:
        combined_df = pd.concat(all_data, ignore_index=True)
        
        # Additional transformations
        combined_df['duration_minutes'] = (
            combined_df['ended_at'] - combined_df['started_at']
        ).dt.total_seconds() / 60
        
        # Yield data to append to the existing BigQuery table
        yield dlt.resource(
            [combined_df],
            name="citibike_trips",
            write_disposition="append"  # Append data to the existing table
        )

# Define & Run the Pipeline with year-specific dataset
pipeline = dlt.pipeline(
    pipeline_name=f"citibike_data_{year}",
    destination="bigquery",
    dataset_name=bigquery_dataset_id
)

info = pipeline.run(citibike_data())
print(info)

# Cleanup local files
try:
    for f in os.listdir(local_storage_path):
        os.remove(os.path.join(local_storage_path, f))
        print(f"Deleted {f}")
except Exception as e:
    print(f"Error during cleanup: {e}")
