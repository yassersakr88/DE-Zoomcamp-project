
# Citi Bike Data Engineering Project
![project](https://github.com/user-attachments/assets/5e91a5b8-e904-492c-b6c1-56450289b71d)
## Overview

This project involves building a data engineering pipeline to process and analyze Citi Bike trip data. The pipeline utilizes several tools and technologies to automate the ingestion, transformation, and loading (ETL) of data from the Citi Bike dataset into Google Cloud Storage (GCS) and BigQuery. The solution also includes data orchestration using Airflow and data transformation using dbt.

## Technologies Used

- **Python**: Programming language used for scripting.
- **Apache Airflow**: Used for orchestrating the ETL pipeline.
- **Google Cloud Storage (GCS)**: For storing raw and processed data.
- **BigQuery**: Data warehouse for storing the cleaned and transformed data.
- **dbt**: Data transformation tool used to create models for analyzing the Citi Bike data.
- **dlt**: Data loading tool for loading data from GCS into BigQuery.
- **Terraform**: Infrastructure as Code (IaC) tool to manage cloud resources.
- **GitHub Actions**: For CI/CD and automating deployment.

## Setup and Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yassersakr88/DE-Zoomcamp-project.git
   cd DE-Zoomcamp-project
   ```
   
2. **Create a virtual environment:**
```bash
python3 -m venv .venv
source .venv/bin/activate  # For Unix-based systems
.venv\Scripts\activate     # For Windows-based systems
```

3. **Install the required dependencies:**
```bash
pip install -r requirements.txt
```

4. **Set up Google Cloud credentials:**
Download your Google Cloud service account credentials in JSON format.

Set the ``` GOOGLE_APPLICATION_CREDENTIALS``` environment variable to point to your service account file:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service_account.json"
```
## Running the Project
### Airflow Setup
1. **Start Airflow using Docker Compose:**

In the ```airflow/``` directory, run:
```bash
docker-compose up -d
```
This will start the Airflow web server and scheduler in the background.

2. **Access the Airflow UI:**

Open your browser and navigate to ```http://localhost:8080```. The default login is ```airflow``` for both the username and password.

3. **Trigger Airflow DAGs:**

- ```dlt_ingestion_dag.py```: Responsible for backfilling the historical Citi Bike data.
- ```upload_new_data.py```: Triggered by dlt_ingestion_dag.py to upload new datasets into GCS and BigQuery.

## Running dbt
1. **Run dbt models:**

To run your dbt models, use the following command:
```bash
dbt run
```
This will execute all the dbt models and transform your Citi Bike data in BigQuery.

## Infrastructure Setup
1. **Terraform Setup:**

To deploy the infrastructure in Google Cloud (GCS, BigQuery, etc.), navigate to the terraform/ directory and run the following commands:
```bash
terraform init
terraform plan
terraform apply
```
This will create the necessary cloud resources for your data pipeline.

## Data Flow
1. Data Ingestion: Raw Citi Bike data is ingested from the source S3 bucket into GCS using the dlt pipeline.
2. Data Transformation: Data is cleaned and transformed using dbt models to prepare it for analysis.
3. Data Loading: The transformed data is loaded into BigQuery for further analysis and reporting.
4. Orchestration: Airflow orchestrates the entire pipeline, ensuring smooth execution of tasks.

## Data Insights
![Screenshot 2025-04-09 180030](https://github.com/user-attachments/assets/01413aef-861f-40bb-a7a0-9eb88606c013)
![Screenshot 2025-04-09 180044](https://github.com/user-attachments/assets/95fba5bb-0c5a-4c57-989f-f726d5b28b62)
![Screenshot 2025-04-09 180105](https://github.com/user-attachments/assets/3dc4db20-28c1-4c28-afc4-0fa43893289b)

## Contributing
Feel free to fork this repository, create issues, and submit pull requests. Contributions are welcome!
Also feel free to contact me through
- Email -> yasser.mansour88@gmail.com
- Twitter -> yasser_sakr88








