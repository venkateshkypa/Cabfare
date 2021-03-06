
# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
########### Loading Libraries ###############################################
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.pyplot as plt
import scipy.stats as stats
from datetime import datetime as date
import warnings
warnings.filterwarnings('ignore')
from geopy.distance import geodesic
from geopy.distance import great_circle
from scipy.stats import chi2_contingency
import statsmodels.api as sm
from statsmodels.formula.api import ols
from patsy import dmatrices
from statsmodels.stats.outliers_influence import variance_inflation_factor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
from sklearn import metrics
from sklearn.linear_model import LinearRegression as lm 
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import RandomizedSearchCV
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestRegressor
from sklearn.tree import DecisionTreeRegressor
from xgboost import XGBRegressor
import xgboost as xgb
from sklearn.externals import joblib

############## Set Working Directory #####################################

os.chdir('C:\\Users\\kyvenkat\\Desktop\\W0376 Backup\\Documents Backup\\Python Files')
os.getcwd()

################## Importing Data #######################################
cabfare = pd.read_csv("C:\\Users\\kyvenkat\\Desktop\\W0376 Backup\\Datasets\\cabfare.csv")
cabfare.head(5)
cabfare.dtypes

########### Converting Required Datatypes #############################
cabfare['fare_amount'] = pd.to_numeric(cabfare['fare_amount'],errors = 'coerce')
cabfare['passenger_count'] = pd.to_numeric(cabfare['passenger_count'],errors = 'coerce') 
cabfare['pickup_datetime']=pd.to_datetime(cabfare['pickup_datetime'],errors = 'coerce')
cabfare["pickup_datetime"] = pd.to_datetime(cabfare["pickup_datetime"],format= "%Y-%m-%d %H:%M:%S UTC")

############## Removing General Outliers ####################################
cabfare = cabfare.drop(cabfare[cabfare["fare_amount"]<=0].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["passenger_count"]<1].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["passenger_count"]>6].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["pickup_longitude"]==0].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["pickup_latitude"]==0].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["dropoff_longitude"]==0].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["dropoff_latitude"]==0].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["pickup_longitude"]>180].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["pickup_longitude"]< -180].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["dropoff_longitude"]>180].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["dropoff_longitude"]< -180].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["pickup_latitude"]>90].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["pickup_latitude"]< -90].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["dropoff_latitude"]>90].index, axis=0)
cabfare = cabfare.drop(cabfare[cabfare["dropoff_latitude"]< -90].index, axis=0)

############ Missing Values Analysis #########################################
missing_val = pd.DataFrame(cabfare.isnull().sum())
cabfare[cabfare['pickup_datetime'].isnull()].index
missing_val = missing_val.rename(columns = {'index':'variables',0:'Missing Values'})
missing_val_percentage = (missing_val['Missing Values']/len(cabfare))*100
missing_val.insert(1,"Percentage",missing_val_percentage)
missing_val  =missing_val.sort_values('Missing Values', ascending = False)

############### Missing Value Analysis ###############################################
# 1. For fare_amount
# Actual Value = 7
# Mean Value = 15.1164
# Median Value = 8.5

# Choosing random value 
#cabfare['fare_amount'].loc[1000]
#Replaing selected value with NA and Impute with mean
#cabfare['fare_amount'].loc[1000] = np.nan 
#cabfare['fare_amount'].fillna(cabfare['fare_amount'].mean()).loc[1000]
#cabfare['fare_amount'].fillna(cabfare['fare_amount'].mean(), inplace=True)

#Replacing select random value with NA and Impute with median
#cabfare['fare_amount'].loc[1000] = np.nan 
#cabfare['fare_amount'].fillna(cabfare['fare_amount'].median()).loc[1000]

cabfare['fare_amount'].fillna(cabfare['fare_amount'].median(), inplace=True)

# 2. For passenger_count
# Actual Value = 1
# Mode Value = 1
# Median Value = 1
# Choosing random value 

#cabfare['passenger_count'].loc[1000]
#Replaing selected value with NA and Impute with mean
#cabfare['passenger_count'].loc[1000] = np.nan 
#cabfare['passenger_count'].fillna(cabfare['passenger_count'].mode()[0]).loc[1000]

#cabfare['passenger_count'].fillna(cabfare['passenger_count'].mode()[0], inplace=True)

#Replacing select random value with NA and Impute with median
#cabfare['passenger_count'].loc[1000] = np.nan 
#cabfare['passenger_count'].fillna(cabfare['passenger_count'].median()).loc[1000]

cabfare['passenger_count'].fillna(cabfare['passenger_count'].median(),inplace=True)

####### Removing date_time index which is not in the the standard date& time format
cabfare = cabfare.drop(cabfare[cabfare['pickup_datetime'].isnull()].index, axis=0)

################## Reset Index Number ##############################################
cabfare = cabfare.reset_index(drop=True)

############## Converting Passenger_count as factors  ########################

cabfare['passenger_count']=cabfare['passenger_count'].round().astype('object').astype('category')

####### Adding more variables by splitting datetime variable ################
cabfare['pick_year'] = cabfare['pickup_datetime'].apply(lambda row: row.year) 
cabfare['pick_month']= cabfare['pickup_datetime'].apply(lambda row: row.month)  
cabfare['pickup_hours']= cabfare['pickup_datetime'].apply(lambda row: row.hour) 
cabfare['pickup_day']= cabfare['pickup_datetime'].apply(lambda row: row.dayofweek)

########## Converting longitude & latitude into distance #################################

cabfare['distance']=cabfare.apply(lambda x: great_circle((x['pickup_latitude'],x['pickup_longitude']), (x['dropoff_latitude'],   x['dropoff_longitude'])).m, axis=1)

############## Remove where distance is zero #######################
cabfare = cabfare.drop(cabfare[cabfare['distance']==0].index, axis=0)

########## Dropping unwanted variables ##########################################

cabfare = cabfare.drop(['pickup_datetime','pickup_longitude','pickup_latitude','dropoff_longitude','dropoff_latitude'], axis = 1)

################### Converting year,month, day & hour into factors and levels###################
# 1. defining internal function and apply where ever it is required

def time(x):
    ''' for sessions in a day using hour column '''
    if (x >=7) and (x <= 12):
        return 'Morning'
    elif (x >=19) and (x <=24 ):
        return 'Late Night'
    elif (x >= 12) and (x <= 18):
        return'After Noon'
    elif (x >=0) and (x <= 6) :
        return 'Early Morning'
    
cabfare['pickup_hours'] = cabfare['pickup_hours'].apply(time)
cabfare['pickup_hours'] = cabfare['pickup_hours'].astype('category')
cabfare["pickup_hours"] = cabfare["pickup_hours"].cat.codes
#################### Separating numeric & categorical variabless ############################################

cabtrain_cat_var = ['passenger_count','pickup_day','pick_year','pick_month','pickup_hours']

cabtrain_num_var = ['fare_amount','distance']

cabfare[cabtrain_cat_var]=cabfare[cabtrain_cat_var].apply(lambda x: x.astype('category') )

cabfare['pickup_day'] = cabfare['pickup_day'].cat.codes
cabfare['pick_year'] = cabfare['pick_year'].cat.codes
cabfare['pick_month'] = cabfare['pick_month'].cat.codes

#################### Outlier Analysis ##################################################

    
def outlier_calculation(x):
    ''' calculating outlier index and replacing them with NA  '''
    #Extract quartiles
    q75, q25 = np.percentile(cabfare[x], [75 ,25])
    print(q75,q25)
    #Calculate IQR
    iqr = q75 - q25
    #Calculate inner and outer fence
    minimum = q25 - (iqr*1.5)
    maximum = q75 + (iqr*1.5)
    print(minimum,maximum)
    #Replace with NA
    cabfare.loc[cabfare[x] < minimum,x] = np.nan
    cabfare.loc[cabfare[x] > maximum,x] = np.nan  

# Finding the outliers for fare_amount & distance
outlier_calculation('fare_amount')
outlier_calculation('distance')

# Imputing with missing values using median
cabfare['fare_amount'].fillna(cabfare['fare_amount'].median(), inplace=True)    
cabfare['distance'].fillna(cabfare['distance'].median(), inplace=True) 
 
#  Again converting to categorical variables  
cabfare[cabtrain_cat_var]=cabfare[cabtrain_cat_var].apply(lambda x: x.astype('category') )

############# Feature Selection ################################

# Correlation analysis for numeric variables
sns.heatmap(cabfare[cabtrain_num_var].corr(), square=True, cmap='RdYlGn',linewidths=0.5,linecolor='w',annot=True)
plt.title('Correlation matrix ')
 
# ANOVA for Categorical Variables and find significant variables 
model = ols('fare_amount ~ C(passenger_count)+C(pick_year)+C(pick_month)+C(pickup_hours)+C(pickup_day)',data=cabfare).fit() 
anova_table = sm.stats.anova_lm(model) 
anova_table

############# Dropping Insignificant Variable ##############
cabfare = cabfare.drop(['pickup_day'], axis = 1)

#################### Normalization ########################################
sns.distplot(cabfare['distance'],bins=100)

cabfare['distance'] = (cabfare['distance'] - min(cabfare['distance']))/(max(cabfare['distance']) - min(cabfare['distance']))

################ Setting train & test data #################################
 
x = cabfare.drop('fare_amount',axis=1).values
y = cabfare['fare_amount'].values
x_train,x_test,y_train,y_test=train_test_split(x,y,test_size=0.2)

print(cabfare.shape, x_train.shape, x_test.shape,y_train.shape,y_test.shape)

###################### Multiple Linear Regression ###################################

lm_model=lm().fit(x_train,y_train)
predictions=lm_model.predict(x_test)

expected_values = x_test
predicted_values = predictions

rms = np.sqrt(mean_squared_error(y_test, predictions))
## rms value =2.62

####################### Decision Tree ###########################################
tree = DecisionTreeRegressor()
tree.fit(x_train,y_train)
predictions = tree.predict(x_test)

rms = np.sqrt(mean_squared_error(y_test, predictions))

#rms value = 3.49

#####################  Random Forest ###########################################

forest = RandomForestRegressor()
forest.fit(x_train,y_train)
predictions = forest.predict(x_test)

rms = np.sqrt(mean_squared_error(y_test, predictions))

# rms value =2.707

############### XGBoost Method ##############################################
Xgb = XGBRegressor()
Xgb.fit(x_train,y_train)
predictions = Xgb.predict(x_test)

rms = np.sqrt(mean_squared_error(y_test, predictions))

# rms value = 2.473

############## Loading Test file ##############################################

cabfare_test = pd.read_csv("C:\\Users\\Venkatesh K\\Downloads\\test\\test.csv")


cabfare_test['passenger_count'] = pd.to_numeric(cabfare_test['passenger_count'],errors = 'coerce') 
cabfare_test['pickup_datetime']=pd.to_datetime(cabfare_test['pickup_datetime'],errors = 'coerce')
cabfare_test["pickup_datetime"] = pd.to_datetime(cabfare_test["pickup_datetime"],format= "%Y-%m-%d %H:%M:%S UTC")

cabfare_test['distance']=cabfare_test.apply(lambda x: great_circle((x['pickup_latitude'],x['pickup_longitude']), (x['dropoff_latitude'],   x['dropoff_longitude'])).m, axis=1)

cabfare_test['pick_year'] = cabfare_test['pickup_datetime'].apply(lambda row: row.year) 
cabfare_test['pick_month']= cabfare_test['pickup_datetime'].apply(lambda row: row.month)  
cabfare_test['pickup_hours']= cabfare_test['pickup_datetime'].apply(lambda row: row.hour) 
cabfare_test['pickup_day']= cabfare_test['pickup_datetime'].apply(lambda row: row.dayofweek)

cabfare_test = cabfare_test.drop(['pickup_datetime','pickup_longitude','pickup_latitude','dropoff_longitude','dropoff_latitude'], axis = 1)

cabtest_cat_var = ['pick_year','pick_month','pickup_hours','pickup_day']
cabtest_num_var = ['distance']

cabfare_test['pickup_hours'] = cabfare_test['pickup_hours'].apply(time)
cabfare_test['pickup_hours'] = cabfare_test['pickup_hours'].astype('category')
cabfare_test["pickup_hours"] = cabfare_test["pickup_hours"].cat.codes
#################### Separating numeric & categorical variabless ############################################

cabfare_test[cabtest_cat_var]=cabfare_test[cabtest_cat_var].apply(lambda x: x.astype('category') )

cabfare_test['pickup_day'] = cabfare_test['pickup_day'].cat.codes
cabfare_test['pick_year'] = cabfare_test['pick_year'].cat.codes
cabfare_test['pick_month'] = cabfare_test['pick_month'].cat.codes

cabfare_test[cabtest_cat_var]=cabfare_test[cabtest_cat_var].apply(lambda x: x.astype('category') )


cabfare_test = cabfare_test.drop(['pickup_day'],axis=1)



################ Finalize Model #################################
 

Xgb = XGBRegressor()
Xgb.fit(x,y)
predictions = Xgb.predict(cabfare_test.values)


a=pd.read_csv("C:\\Users\\kyvenkat\\Desktop\\W0376 Backup\\Datasets\\cabfare_test.csv")
cabfare_test_pickup_datetime=a['pickup_datetime']

pred_results_wrt_date = pd.DataFrame({"pickup_datetime":cabfare_test_pickup_datetime,"fare_amount" : predictions})

joblib.dump(Xgb, 'cab_fare_xgboost_model.pkl') 


pred_results_wrt_date.to_csv(r'C:\Users\kyvenkat\Desktop\W0376 Backup\Documents Backup\pred_results_wrt_date_python.csv')

