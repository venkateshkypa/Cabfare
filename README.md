# Cabfare Prediction Project

 GitHub folder contains: 
 1. R code of project in ‘.R format’:  Cab Fare Prediction Using R.R 
 2. Python code of project in ‘.ipynb format’: Cab Fare Prediction Using Python.py 
 3. Project report: Cab Fare Prediction.pdf 
 4. Problem Statement.pdf 
 5. Saved Model trained on entire training dataset from python: cab_fare_xgboost_model.rar
 6. Saved Model trained on entire training dataset from python:  	final_Xgboost_model_using_R.rar
 7. Predictions on test dataset in csv format:predictions_xgboost.csv

## Problem Statement 
 
The objective of this Project is to Predict Cab Fare amount based upon following data attributes in the dataset are as follows:

    pickup_datetime - timestamp value indicating when the cab ride started.
    pickup_longitude - float for longitude coordinate of where the cab ride started.
    pickup_latitude - float for latitude coordinate of where the cab ride started.
    dropoff_longitude - float for longitude coordinate of where the cab ride ended.
    dropoff_latitude - float for latitude coordinate of where the cab ride ended.
    passenger_count - an integer indicating the number of passengers in the cab ride.


### It is a regression Problem.
## All the steps implemented in this project
1. Data Pre-processing.
2. Data Visualization.
3. Outlier Analysis.
4. Missing value Analysis.
5. Feature Selection.
 -  Correlation analysis.
 -  Analysis of Variance(Anova) Test
 -  Multicollinearity Test.
6. Feature Scaling.
 -  Normalization.
7. Splitting into Train and Validation Dataset.
8. Model Development
I. Multiple Linear Regression 
II. Decision Tree Regression 
III. Random Forest Regression 
IV. Gradient Boosting Method
9. Improve Accuracy 
a) Algorithm Tuning
b) Ensembles------XGBOOST For Regression
Finalize Model 
a) Predictions on validation dataset 
b) Create standalone model on entire training dataset 
c) Save model for later use
11. R code both in text format and also .R file
12. Python code
