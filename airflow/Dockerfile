FROM apache/airflow:2.8.1-python3.10

# Copy the dlt_pipeline folder into the image
COPY ./dlt_pipeline /opt/airflow/dlt_pipeline

# Install additional Python dependencies
RUN pip install --no-cache-dir -r /opt/airflow/dlt_pipeline/requirements.txt