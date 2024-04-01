train_save_model <- function(cleaned_df, outcome_df) {
  
  
  # Combine cleaned_df and outcome_df to match on ID
  model_df <- merge(cleaned_df, outcome_df, by = "nomem_encr")
  
  # glmnet requires matrix, merge turned it into data.frame
  model_df <- as.matrix(model_df)
  
  # features without outcome and identifier
  X <- model_df[ , !(colnames(model_df) %in% c("nomem_encr", "new_child"))]
  # outcome only
  y <- model_df[ , colnames(model_df) == "new_child"]
  
  # LASSO regression
  # cross-validation, to retrieve ideal lambda
  # hyperparameter tuning
  set.seed(1)
  CV <- cv.glmnet(x = X, 
                  y = y, 
                  family = "binomial",
                  nfolds = 10, standardize = FALSE)
  optimal_lambda_test <- CV$lambda.min
  
  # Run model with optimal lambda
  model <- glmnet(x = X, 
                  y = y, 
                  family = "binomial", 
                  lambda = optimal_lambda_test, standardize = FALSE )
  
  # Save the model
  saveRDS(model, "model.rds")
  
}