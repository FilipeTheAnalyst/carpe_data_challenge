import snowflake.connector
import pandas as pd

# Snowflake connection parameters
snowflake_params = {
    'account': 'yl45797.east-us-2.azure',
    'user': 'student089',
    'password': 'deGNC%!BN4nzlD9X',
    'warehouse': 'developer_wh_089',
    'database': 'analytics_089',
    'schema': 'carpe_data'
}

# Snowflake connection
conn = snowflake.connector.connect(**snowflake_params)
cursor = conn.cursor()

# Define the path to your TXT file
file_path = 'Gowalla_totalCheckins.txt'

# Read data from TXT file using pandas
df = pd.read_csv(file_path, delimiter='\t')  # Adjust delimiter as needed

# Upload data to Snowflake using COPY INTO
# First, create a temporary stage
stage_name = 'carpe_data_stage'
table_name = 'checkin'
cursor.execute(f"CREATE TEMPORARY STAGE {stage_name}")

# Upload data to the stage using pandas' to_csv() function
stage_file_path = f"@{stage_name}/data.csv"
df.to_csv(stage_file_path, sep=',', index=False)  # Adjust delimiter as needed

# Copy data from the stage to your target table
copy_query = f"COPY INTO {table_name} FROM {stage_file_path} FILE_FORMAT = (TYPE = CSV)"
cursor.execute(copy_query)

# Close the cursor and connection
cursor.close()
conn.close()