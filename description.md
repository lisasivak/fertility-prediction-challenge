# Description of submission

This example demonstrates a problem that is likely to be quite common. There are many cases when some category of a categorical variable is present in the holdout data, but absent in the training data. If you are creating dummy variables at the preprocessing stage (or using one-hot encoding, etc.), applying the same clean_df function to the training and to the holdout data will lead to different results - to the datasets with different sets of variables. This will lead to the failed run on the fake data and on the holdout data. 


In this example we use LASSO regression. It requires all categorical variables to be turned into dummies. 
We include a variable cf20m180 (satisfaction with relationships with the current partner) in a model. 
If we select only cases in the training data for which the outcome is available, there are no people who answered 0 and 1 (very dissatisfied). This is why there will be two columns missing 2 (for cf20m180==0 and cf20m180==1)
These categories however appear in the full train set - and are likely to appear in the holdout data, in which case it will introduce errors.

In this example we create additional factor levels to deal with this problem.


UPD: plus test adding external data using fake external data
