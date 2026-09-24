"""
churn_etl.py
Standard ETL ppipeline for processing sample Telco Churn dataset
"""

import argparse
#import logging
import sys
import pandas as pd
from pathlib import Path
from loguru import logger
import json


# replace args.input and args.output predefined for testing purposes
project_root = Path.cwd().parent

input = project_root / "src" / "data" / "raw" / "Telco-Customer-Churn.csv"
output = project_root / "data" / "data_quality" / "processed_data" / "Telco_Customer_Churn_interim.csv"


####
# 1. Configure logging with timestamps using Loguru
####

#Path("logs").mkdir(parents = True, exist_ok = True) # for creating log files if needed

logger.remove() #remove default loguru handler

# function to return a json object with select fields from the log record
def serialize(record):
    subset = {
        "level": record["level"].name,
        "timestamp": record["time"].timestamp(),
        "message": record["message"]}
    return json.dumps(subset)


# function for setting formatting of log messages:
def formatter(record):
    record["extra"]["serialized"] = serialize(record)
    return "{extra[serialized]}\n"

logger.add(sys.stderr, format=formatter, level="INFO")


####
# 2. Extract data from .csv
####

def extract_data(file_path: Path) -> pd.DataFrame:
    """Reads raw data from a CSV file."""
    logger.info(f"Starting extraction from: {file_path}")
    
    if not file_path.exists():
        raise FileNotFoundError(f"Input file not found at {file_path}")
        
    df = pd.read_csv(file_path)
    logger.info(f"Successfully extracted {len(df)} rows and {len(df.columns)} columns.")
    return df


####
# 3. Transform data
####

def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    """Cleans and transforms the raw dataframe."""
    logger.info("Starting data transformation...")
    
    # Make a copy 
    df_clean = df.copy()
    
    # Fix the data issue blank spaces in TotalCharges
    numeric_cols = ["tenure", "MonthlyCharges", "TotalCharges"]
    for col in numeric_cols:
        if col in df_clean.columns:
            df_clean[col] = pd.to_numeric(df_clean[col], errors='coerce')
            

    # Drop exact duplicate rows if any exist
    initial_count = len(df_clean)
    df_clean = df_clean.drop_duplicates()
    logger.info(f"Dropped {initial_count - len(df_clean)} duplicate rows.")
    
    logger.info("Transformation complete.")
    return df_clean


####
# 4. Load data
####


def upload_data(df: pd.DataFrame, output_path: Path) -> None:
        """Saves the transformed dataframe to the destination."""
    logger.info(f"Starting upload to: {output_path}")

    output_path.parent.mkdir(parents = True, exist_ok = True)
    
    if output_path.suffix == ".parquet":
        df.to_parquet(output_path, index=False)
    else:
        df.to_csv(output_path, index=False)
 
    logger.info(f"Successfully uploaded {len(df)} rows and {len(df.columns)} columns to {output_path}.")
    

####
# 5.Main execution and CLI
####

def parse_arguments() -> argparse.Namespace:
    """Sets up command-line arguments."""
    parser = argparse.ArgumentParser(description="Run ETL Pipeline")
    parser.add_argument(
        "--input", 
        type=Path, 
        required=True, 
        help="Path to the raw input CSV file"
    )
    parser.add_argument(
        "--output", 
        type=Path, 
        required=True, 
        help="Path to save the cleaned output file (CSV or Parquet)"
    )
    return parser.parse_args()

def main() -> None:
    """Main orchestrator for the ETL pipeline."""
    args = parse_arguments()
    
    try:
        # Orchestrate the pipeline
        # raw_df = extract_data(args.input)
        # clean_df = transform_data(raw_df)
        # upload_data(clean_df, args.output)
        raw_df = extract_data(input)
        clean_df = transform_data(raw_df)
        upload_data(clean_df, output)
        
        logger.info("ETL Pipeline completed successfully.")
        
    except Exception as e:
        logger.error(f"ETL Pipeline failed with error: {e}", exc_info=True)
        # Exit with a non-zero status code so orchestrators (like Airflow) know it failed
        sys.exit(1) 

if __name__ == "__main__":
    main()