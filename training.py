"""
This is an example script to train your model given the (cleaned) input dataset.

This script will not be run on the holdout data, 
but the resulting model model.joblib will be applied to the holdout data.

It is important to document your training steps here, including seed, 
number of folds, model, et cetera
"""

# List your libraries and modules here. Don't forget to update environment.yml if you use packages that are not there!
import pandas as pd
from sklearn.linear_model import LogisticRegression
import joblib


def train_save_model(cleaned_df, outcome_df):
    """
    Trains a model using the cleaned dataframe and saves the model to a file.

    Parameters:
    cleaned_df (pd.DataFrame): The cleaned data from clean_df function to be used for training the model.
    outcome_df (pd.DataFrame): The data with the outcome variable 
    (e.g., from PreFer_train_outcome.csv or PreFer_fake_outcome.csv).
    """
    
    ## This script contains a bare minimum working example
    #random.seed(1) # not useful here because logistic regression deterministic
    
    # Combine cleaned_df and outcome_df
    model_df = pd.merge(cleaned_df, outcome_df, on="nomem_encr")

    # Filter cases for whom the outcome is not available
    model_df = model_df[~model_df['new_child'].isna()]  
    
    # Logistic regression model
    model = LogisticRegression()

    # Fit the model
    model.fit(model_df[['age', 'gender_bg']], model_df['new_child'])

    # Save the model
    joblib.dump(model, "model.joblib")


train = pd.read_csv("path to the data\\PreFer_train_data.csv")
