library(dplyr)
library(glmnet)
library(caret)
###
clean_df <- function(df, background_df = NULL){
  
  # select only cases where outcome is available 
  df <- df %>% filter(outcome_available == 1)
 
  ## Selecting variables
  keepcols = c('nomem_encr', # ID variable required for predictions,
               'birthyear_bg', # birthyear of respondents
               'gender_bg', # gender of respondents, factor
               'oplmet_2020',# highest educational level in 2020
               'cf20m024', # having a partner
               'cf20m180'  # satisfaction with relationships
               ) 
  
  ## Keeping data with variables selected
  df <- df %>% select(all_of(keepcols))
  ## function for getting mode
  mode <- function(x) {
    x <- x[ !is.na(x) ]
    ux <- unique(x)
    tab <- tabulate(match(x, ux))
    mode <- ux[tab == max(tab)]
    ifelse(length(mode) > 1, sample(mode, 1), mode)
  }
  
  # impute missing values with mode for other categorical variables and mean for continuous
  df <- df %>% 
    mutate(
      birthyear_bg = ifelse(is.na(birthyear_bg), 
                            mean(birthyear_bg, na.rm = TRUE), birthyear_bg),
      age = 2020 - birthyear_bg,
      gender_bg = ifelse(is.na(gender_bg),
                         mode(gender_bg), gender_bg),
      oplmet_2020 = ifelse(is.na(oplmet_2020),
                           mode(oplmet_2020), oplmet_2020),
      # add category "no partner" - 99 - in case there is no partner (cf20m024 == 2 )
      cf20m180 = case_when(cf20m024 == 2 ~ 99,
                           is.na(cf20m180) ~ 999, # other NAs impute with a new category 999
                           TRUE ~cf20m180),
      cf20m024 = ifelse(is.na(cf20m024), 999, cf20m024)
      
    ) %>% 
    # standardise continuous variable, create factor for categorical variables
    # needed for glmnet
    mutate(
      age_st = as.numeric(scale(age)), # z-scores, as.numeric to remove attributes
      gender_bg = factor(gender_bg),
      oplmet_2020 = factor(oplmet_2020),
      cf20m180 = factor(cf20m180),
      cf20m024 = factor(cf20m024)
    )
  
  
  # updating factor levels to keep all columns in the data when the variable will be turned into dummy - even if some categories are missing
  levels(df$cf20m180) <- c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10","99","999")  
  
  # add fake external data to test
  external <- read.csv('fake_external_data.csv')
  
  df <- left_join(df, external, by = 'age')
  
  # remove additional columns for age
  df <- df %>% select(-c(age, birthyear_bg))
  
  # turn factors into dummy variables, required for glmnet
  df <- model.matrix(~ ., df)
  
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
