
"""
feature_engineering_pipeline.py

A modular, reproducible feature engineering pipeline using scikit-learn.
Takes cleaned data and outputs modeling-ready features (X) and target (y),
while saving the fitted pipeline for future inference.
"""

import logging
import random
from dataclasses import dataclass
import numpy as np
import pandas as pd
from pathlib import Path
import joblib

from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler


