#Import Libraries

import argparse
import logging
import random
from dataclasses import dataclass
from pathlib import Path
from typing import List

import numpy as np
import pandas as pd

#temp data source:
project_root = Path.cwd().parents[2]

@dataclass
class PipelineConfig:
    """Configuration for data cleaning pipeline"""
    raw_data_path : Path = project_root / "data" / "data_quality" / "processed_data" / "Telco_Customer_Churn_interim.csv"
    cleaned_data_path: Path = Path("data/processed_data/Telco_Customer_Churn_cleaned.csv")
    random_seed: int = 42 #MAY NOT NEED THIS UNTIL SPLITTING DATA INTO TRAIN AND TEST SETS
    outlier_std_threshold: float = 3.0
    target_column: str = "target"
    id_column: str = "id"





    #    # Initialize configuration
    # pipeline_config = PipelineConfig(
    #     raw_data_path=Path("data/raw/my_ml_dataset.csv"),
    #     cleaned_data_path=Path("data/processed/my_ml_dataset_cleaned.csv"),
    #     random_seed=42,
    #     outlier_std_threshold=3.0,
    #     target_column="churn",
    #     id_column="customer_id",
    #     numerical_cols=["age", "tenure", "monthly_charges"],
    #     categorical_cols=["gender", "contract_type", "payment_method"]
    # ) 

#need this?
    numerical_cols: List[str] = ["age", "income"]
    categorical_cols: List[str] = ["gender", "education"]


# =========================
# 2. set up and utilities
# =========================

def setup_logging(log_level: int = logging.INFO) -> None:
    """Configures the logging format and level for reproducibility and debugging."""
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


# def set_global_seeds(seed: int) -> None:
#     """Sets seeds for numpy and random to ensure reproducibility."""
#     random.seed(seed)
#     np.random.seed(seed)


# ===============================
# Cleaning Functions
# ===============================

def load_data(input: Path) -> pd.DataFrame:
    logger = logging.getLogger(__name__)
    logger.info(f"Loading data from {input}...")

    """"read in raw data"""
    if not input.exists():
        logger.error(f"Input file {input} does not exist.")
        raise FileNotFoundError(f"Input file {input} does not exist.")
    
    with open(input, 'r') as f:
        df = pd.read_csv(f)
        logger.info(f"Data loaded successfully with shape {df.shape}.")
    return df


def drop_duplicates_and_ids(df: pd.DataFrame, id_col: str) -> pd.DataFrame:
    """Drop duplicate rows and the ID column from the DataFrame."""
    logger = logging.getLogger(__name__)
    initial_shape = df.shape
    df = df.drop_duplicates()
    logger.info(f"Dropped {initial_shape[0] - df.shape[0]} duplicate rows.")

    """Drop the ID column if it exists."""
    if id_col in df.columns:
        df = df.drop(columns = [id_col])
        logger.info(f"Dropped ID column '{id_col}' from the DataFrame.")

    return df


def ensure_correct_data_types(df: pd.DataFrame, config: PipelineConfig) -> pd.DataFrame:
    """Ensure that numerical columns are of type float and categorical columns are of type object."""
    logger = logging.getLogger(__name__)

    for col in config.numerical_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')
            logger.info(f"Ensured numerical column '{col}' is of type float.")
        else:
            logger.warning(f"Numerical column '{col}' not found in DataFrame.")

    for col in config.categorical_cols:
        if col in df.columns:
            df[col] = df[col].astype('category')
            logger.info(f"Ensured categorical column '{col}' is of type category.")
        else:
            logger.warning(f"Categorical column '{col}' not found in DataFrame.")

    logger.info("Data types is optimized")
    return df

def remove_outliers(df: pd.DataFrame, numerical_cols: List[str], outlier_std_threshold: float) -> pd.DataFrame:
    """Remove outliers from the DataFrame (numerical cols only) based on z-score threshold."""
    logger = logging.getLogger(__name__)
    initial_shape = df.shape

    for col in numerical_cols:
        if col in df.columns:
            mean = df[col].mean()
            std_dev = df[col].std()
            z_scores = (df[col] - mean) / std_dev
            df = df[np.abs(z_scores) < outlier_std_threshold]
            logger.info(f"Removed outliers from column '{col}' using z-score threshold {outlier_std_threshold}. New shape: {df.shape}.")
        else:
            logger.warning(f"Numerical column '{col}' not found in DataFrame.")

    return df


def save_data(df: pd.DataFrame, output_path: Path) -> None:
    """Save the cleaned DataFrame to a CSV file."""
    logger = logging.getLogger(__name__)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    df.to_csv(output_path, index=False)
    logger.info(f"Cleaned data saved to {output_path}. Final shape: {df.shape}.")


# ===============================
# Main execution pipeline
# ===============================

def run_pipeline(config: PipelineConfig) -> None:
    logger = logging.getLogger(__name__)
    logger.info("="*50)
    logger.info("STARTING DATA CLEANING PIPELINE")
    logger.info("="*50)

    #1 setup
    set_global_seeds(config.random_seed)

    #2. Load data
    df = load_data(config.raw_data_path)

    #3. Clean and transform
    df = drop_duplicates_and_ids(df, config.id_column)
    df = ensure_correct_data_types(df, config)
    df = remove_outliers(df, config.numerical_cols, config.outlier_std_threshold)

    #4. save cleaned data
    save_data(df, config.cleaned_data_path)

    logger.info("="*50)
    logger.info("DATA CLEANING PIPELINE COMPLETED SUCCESSFULLY")
    logger.info("="*50)

if __name__ == "__main__":
    setup_logging()
    #pipeline_config = PipelineConfig()

    parser = argparse.ArgumentParser(description="Data cleaning pipeline")
    parser.add_argument("--raw-data", type=Path, default = PipelineConfig.raw_data_path, help="Path to the raw data CSV file")
    parser.add_argument("--outlier-threshold", type = float, default = PipelineConfig.outlier_std_threshold, help="Z-score threshold for outlier removal")

    args = parser.parse_args()

    pipeline_config = PipelineConfig(
        raw_data_path = args.raw_data,
        outlier_std_threshold = args.outlier_threshold
    )

    try:
        main(pipeline_config)
    except Exception as e:
        logging.exception(f"Pipeline failed: {e}")
        sys.exit(1)
    
    
    #run_pipeline(pipeline_config)




# def handle_missing_values(df: pd.DataFrame, config: PipelineConfig) -> pd.DataFrame:
#     """Handle missing values in the DataFrame."""
#     logger = logging.getLogger(__name__)
#     initial_shape = df.shape

#     # Drop rows with missing target values
#     if config.target_column in df.columns:
#         df = df.dropna(subset=[config.target_column])
#         logger.info(f"Dropped rows with missing target values. New shape: {df.shape}.")
#     else:
#         logger.warning(f"Target column '{config.target_column}' not found in DataFrame.")

#     # Fill missing numerical values with median
#     for col in config.numerical_cols:
#         if col in df.columns:
#             median_value = df[col].median()
#             df[col] = df[col].fillna(median_value)
#             logger.info(f"Filled missing values in numerical column '{col}' with median value {median_value}.")
#         else:
#             logger.warning(f"Numerical column '{col}' not found in DataFrame.")

#     # Fill missing categorical values with mode
#     for col in config.categorical_cols:
#         if col in df.columns:
#             mode_value = df[col].mode()[0]
#             df[col] = df[col].fillna(mode_value)
#             logger.info(f"Filled missing values in categorical column '{col}' with mode value '{mode_value}'.")
#         else:
#             logger.warning(f"Categorical column '{col}' not found in DataFrame.")

#     return df


    

 