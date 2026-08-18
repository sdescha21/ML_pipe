from pathlib import Path

import great_expectations as gx # using version 1.20.0

context = gx.get_context(mode='file')

print("Great Expectations initialized successfully")
print(context)

project_root = Path.cwd().parent

source_folder = project_root / "src" / "data" / "raw"
data_source_name = 
# validator = context.data_sources.pandas_default.read_csv(
# "https://github.com/sdescha21/ML_pipe/blob/main/src/data/raw/Telco-Customer-Churn.csv"
# )

# Define Expectations for the data:
validator.expect_column_values_to_not_be_null("customerID")
validator.expect_column_values_to_be_between(
    "tenure", min_value=0, max_value=45
)
validator.save_expectation_suite(discard_failed_expectations=False)


# Denife checkpoint to examine data and check if it matched the defined Expectations:
checkpoint = context.add_or_update_checkpoint(
    name="my_quickstart_checkpoint",
    validator=validator,
)

# get validation results:
checkpoint_result = checkpoint.run()

# view results:
context.view_validation_result(checkpoint_result)
