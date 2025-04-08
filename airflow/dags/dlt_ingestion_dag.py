from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import os
import subprocess

# Define BigQuery dataset and project ID
bigquery_project_id = "citibike-zoomcamp-project"
bigquery_dataset_id = "citibike_tripdata"

# Default arguments
default_args = {
    "owner": "airflow",
    "start_date": datetime(2025, 1, 1),  # Start from January 2025
    "retries": 1,
}

# Define callable to run upload_new_data.py
def run_upload_new_data(year, month, **context):
    """Trigger the upload_new_data.py script for the specified year and month."""
    # Prepare the command to run the script
    command = [
        "python3",
        "/opt/airflow/dags/upload_new_data.py",  # Path to your Python script
        "--year", str(year),
    ]
    
    # Log the year and month
    print(f"Running upload for {year}-{month:02d}...")

    # Execute the Python script
    subprocess.run(command, check=True)

# Define DAG
with DAG(
    dag_id="dlt_citibike_pipeline",
    default_args=default_args,
    schedule_interval="@monthly",  # Run monthly
    catchup=True,  # To catch up on past months if not run
    start_date=datetime(2025, 1, 1),  # Start from January 2025
    end_date=datetime(2025, 12, 31),  # End in December 2025 (adjust as needed)
) as dag:

    # Define the task to run upload_new_data.py for each month
    for month in range(1, 13):
        run_upload_new_data_task = PythonOperator(
            task_id=f"upload_new_data_{month:02d}",
            python_callable=run_upload_new_data,
            op_args=[2025, month],  # Pass year and month as arguments
            provide_context=True,
        )
