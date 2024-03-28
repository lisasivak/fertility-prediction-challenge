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


def clean_df(df, background_df=None):
    """
    Preprocess the input dataframe to feed the model.
    # If no cleaning is done (e.g. if all the cleaning is done in a pipeline) leave only the "return df" command

    Parameters:
    df (pd.DataFrame): The input dataframe containing the raw data (e.g., from PreFer_train_data.csv or PreFer_fake_data.csv).
    background (pd.DataFrame): Optional input dataframe containing background data (e.g., from PreFer_train_background_data.csv or PreFer_fake_background_data.csv).

    Returns:
    pd.DataFrame: The cleaned dataframe with only the necessary columns and processed variables.
    """

    ## This script contains a bare minimum working example
    # Create new variable with age
    df["age"] = 2024 - df["birthyear_bg"]

    # Imputing missing values in age with the mean
    df["age"] = df["age"].fillna(df["age"].mean())
    
    # Imputing missing values in education (oplmet_2020) with the mode
    df["oplmet_2020"] = df["oplmet_2020"].fillna(df["oplmet_2020"].mode())

    # Selecting variables for modelling
    keepcols = [
        "nomem_encr",  # ID variable required for predictions,
        "age"          # newly created variable
    ] 

    # Keeping data with variables selected
    df = df[keepcols]

    return df


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
    model.fit(model_df[['age', 'oplmet_2020']], model_df['new_child'])

    # Save the model
    joblib.dump(model, "model.joblib")


train = pd.read_csv("path to the data\\PreFer_train_data.csv")
