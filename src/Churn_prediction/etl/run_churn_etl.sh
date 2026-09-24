#!/bin/bash

python src/Churn_prediction/etl/churn_etl.py --input=data/raw/Telco-Customer-Churn.csv \
--output=data/processed/Telco-Customer-Churn-interim.csv

