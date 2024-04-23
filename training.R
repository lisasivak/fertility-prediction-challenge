train_save_model <- function(cleaned_df, outcome_df) {
  # Trains a model using the cleaned dataframe and saves the model to a file.
  
  # Parameters:
  # cleaned_df (dataframe): The cleaned data from clean_df function to be used for training the model.
  # outcome_df (dataframe): The data with the outcome variable (e.g., from PreFer_train_outcome.csv or PreFer_fake_outcome.csv).
  
  ## This script contains a bare minimum working example
  set.seed(1) # not useful here because logistic regression deterministic
  
  # Combine cleaned_df and outcome_df
  model_df <- merge(cleaned_df, outcome_df, by = "nomem_encr")
  
  # Logistic regression model
  model <- glm(new_child ~ age, family = "binomial", data = model_df)
  
  # Save the model
  saveRDS(model, "model.rds")
}
