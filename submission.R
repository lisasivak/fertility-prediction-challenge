#
clean_df <- function(df, background_df = NULL){
  # Preprocess the input dataframe to feed the model.
  ### If no cleaning is done (e.g. if all the cleaning is done in a pipeline) leave only the "return df" command
  
  # Parameters:
  # df (dataframe): The input dataframe containing the raw data (e.g., from PreFer_train_data.csv or PreFer_fake_data.csv).
  # background (dataframe): Optional input dataframe containing background data (e.g., from PreFer_train_background_data.csv or PreFer_fake_background_data.csv).
  
  # Returns:
  # data frame: The cleaned dataframe with only the necessary columns and processed variables.
  
  ## This script contains a bare minimum working example
  # Create new age variable
  df$age <- 2024 - df$birthyear_bg
  
  # Selecting variables for modelling
  
  keepcols = c('nomem_encr', # ID variable required for predictions,
               'age')        # newly created variable
  
  ## Keeping data with variables selected
  df <- df[ , keepcols ]
  
  return(df)
}

predict_outcomes <- function(df, background_df = NULL, model_path = "./model.rds"){
  
  if( !("nomem_encr" %in% colnames(df)) ) {
    warning("The identifier variable 'nomem_encr' should be in the dataset")
  }
  
  model <- readRDS(model_path)
  df <- clean_df(df, background_df)
  
  vars_without_id <- colnames(df)[colnames(df) != "nomem_encr"]
  
  predictions <- predict(model, 
                         subset(df, select = vars_without_id), 
                         type = "response") 
  predictions <- ifelse(predictions > 0.5, 1, 0)  
  
  df_predict <- data.frame("nomem_encr" = df[ , "nomem_encr" ], "prediction" = predictions)
  names(df_predict) <- c("nomem_encr", "prediction") 
  
  return( df_predict )
}
