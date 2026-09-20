from pathlib import Path
import pandas as pd
import numpy as np
import great_expectations as gx # using version 1.20.0

from great_expectations.expectations import (
    ExpectColumnValuesToBeUnique,
    ExpectColumnValuesToNotBeNull,
    ExpectColumnValuesToBeBetween,
    ExpectColumnValuesToBeInSet,
)

def main():
    #
    # Data Preparation:
    # Load the data from the CSV file:

    # read in .csv file
    
    project_root = Path.cwd().parents
    print(project_root)
    #("Telco-Customer-Churn.csv")
    data_dir = project_root /"src" / "data" / "raw"
    f_path = data_dir / "Telco-Customer-Churn.csv"
    print("Loading data from CSV file from path:", f_path)


    with open(f_path, 'r') as f:
        df = pd.read_csv(f)


    # Define columns by type numeric or value_set:
    
    numeric_cols = ["tenure", "MonthlyCharges", "TotalCharges"]
    #coerce TotalCharges to numeric, forcing errors to NaN:
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors = 'coerce')


    value_set_cols = [
       "gender", "Partner", "Dependents", "PhoneService", "MultipleLines", 
        "InternetService", "OnlineSecurity", "OnlineBackup", "SeniorCitizen", 
        "DeviceProtection", "TechSupport", "StreamingTV", "StreamingMovies", 
        "Contract", "PaperlessBilling", "PaymentMethod", "Churn"
        ]

    # Set up GX context:
    print("Initializing Great Expectations context...")

    context = gx.get_context()

    # Define data source/how to connect to data
    data_source_name = 'pandas'
    try:
        data_source = context.data_sources.add_pandas(name = data_source_name)
    except gx.exceptions.DataContextError:
        data_source = context.data_sources.get('pandas')
    #data_source = context.data_sources.add_pandas(name = 'pandas')


    # Add data asset
    asset_name = 'Telco-Customer-Churn'
    try:
        data_asset = data_source.get_asset(asset_name)
    except gx.exceptions.DataContextError:
        data_asset = data_source.add_dataframe_asset(name = asset_name)

    # Create a batch definition (entire df)
    batch_def_name = 'Telco-batch'
    try:
        batch_definition = data_asset.get_batch_definition(batch_def_name)
    except gx.exceptions.DataContextError:
        batch_definition = data_asset.add_batch_definition_whole_dataframe(batch_def_name)

    batch = batch_definition.get_batch(batch_parameters= {"dataframe": df})

    print("Great Expectations initialized successfully")
    print(context)
    print(data_source)


    # Define Expectation Suite:
    suite_name = "telco_expectations"
    suite = gx.ExpectationSuite(name = suite_name)

    # Primary Key validations:
    suite.add_expectation(ExpectColumnValuesToNotBeNull(column = "customerID"))
    suite.add_expectation(ExpectColumnValuesToNotBeNull(column = "churn"))
    suite.add_expectation(ExpectColumnValuesToBeUnique(column = "customerID"))

    # Numeric columns expectations:
    for col in numeric_cols:
        min_val = float(df[col].dropna().min())
        max_val = float(df[col].dropna().max())

        suite.add_expectation(
            ExpectColumnValuesToBeBetween(
                column = col,
                min_value = min_val,
                max_value = max_val
            )
        )


    # Value set columns expectations:
    for col in value_set_cols:
        unique_vals = df[col].dropna().unique().tolist()

        suite.add_expectation(
            ExpectColumnValuesToBeInSet(
                column = col,
                value_set = unique_vals
            )
        )

    # Save the Expectation Suite to Data Context::
    context.suites.add_or_update(suite)

    print(f"Suite '{suite_name}' successfully created with {len(suite.expectations)} expectations.")


    # Create Validation Definition (bridges specific batch of data to an Expectation Suite):
    print("Running validation checkpoint...")

    definition_name = "telco_validation"

    validation_definition = gx.ValidationDefinition(
        data = batch_definition, suite = suite, name = definition_name
    )

    # Create a Checkpoint to run the validation definition:

    try:
        checkpoint = context.checkpoints.get("telco_checkpoint")

    except gx.exceptions.DataContextError:
        checkpoint = context.checkpoints.add(
            gx.Checkpoint(
                name = "telco_checkpoint",
                validation_definitions = [validation_definition],
                actions=[action_list],
                result_format="SUMMARY",
            )
        )

    # Execute the validation and get the results:

    validation_results = checkpoint.run(
        batch_parameters = {"dataframe": df}
    )

    print(validation_results)

    if validation_results.success:
        print("SUCCESS: All expectations passed! The dataframe is valid.")
    else:
        print("FAILURE: Some expectations failed.")    

    ### Can create action to send results to email

if __name__ == "__main__":
    main()

