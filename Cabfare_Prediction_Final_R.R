########### Cabfare_Prediction Project #################################  

rm(list = ls())
set.seed(123)

###### Setting working directory #############################

setwd('C:/Users/kyvenkat/Desktop/W0376 Backup/Documents Backup')
getwd()

#### loading libraries #######################################

x = c("ggplot2", "corrgram", "DMwR", "usdm", "caret", "randomForest", "e1071",
      "DataCombine", "rpart.plot", "rpart",'xgboost','stats','lubridate','geosphere','gbm','xgboost')
#load Packages
lapply(x, require, character.only = TRUE)
rm(x)

######## Importing  Data ############################################
cabfare<-read.csv("C:\\Users\\kyvenkat\\Desktop\\W0376 Backup\\Datasets\\cabfare.csv", header = TRUE)

######## Exploratory Data Analysis###############################################

# Finding the class of the variables  




# Changing the required datatypes

cabfare$fare_amount<-as.numeric(as.character(cabfare$fare_amount))
cabfare$passenger_count<-round(cabfare$passenger_count)
cabfare$pickup_datetime<-as.factor(as.character(ymd_hms(cabfare$pickup_datetime)))


########### Remove all values in each variable which are not in its usual range ##############
# latitide cannot be greater than +90 and less than -90
# longitude cannot be greater than +180 and less than -180 
# cab fare  in general cannot be a negative value 
# passenger count cannot be '0' or less than that i.e. atlease 1 passenger should be there in a cab and at the same time
# passenger count cannot be greater than 6 as a cab/car at maximum can accommodate only 6 or less that 6  people in a ride 


if(any(cabfare$fare_amount<= 0)){
  cabfare<-cabfare[-which(cabfare$fare_amount<= 0),]
}else cabfare<-cabfare[which(cabfare$fare_amount> 0),]

if(any(cabfare$pickup_longitude> 180)){
  cabfare<-cabfare[-which(cabfare$pickup_longitude> 180),]
}else cabfare<-cabfare[which((cabfare$pickup_longitude< 180)),]

if(any(cabfare$pickup_longitude< -180)){
  cabfare<-cabfare[-which(cabfare$pickup_longitude< -180),]
}else cabfare<-cabfare[which((cabfare$pickup_longitude> -180)),]

if(any(cabfare$pickup_latitude> 90)){
  cabfare<-cabfare[-which(cabfare$pickup_latitude> 90),]
}else cabfare<-cabfare[which((cabfare$pickup_latitude< 90)),]

if(any(cabfare$pickup_latitude< -90)){
  cabfare<-cabfare[-which(cabfare$pickup_latitude< -90),]
}else cabfare<-cabfare[which((cabfare$pickup_latitude> -90)),]

if(any(cabfare$dropoff_longitude> 180)){
  cabfare<-cabfare[-which(cabfare$dropoff_longitude> 180),]
}else cabfare<-cabfare[which((cabfare$dropoff_longitude< 180)),]

if(any(cabfare$dropoff_longitude< -180)){
  cabfare<-cabfare[-which(cabfare$dropoff_longitude< -180),]
}else cabfare<-cabfare[which((cabfare$dropoff_longitude> -180)),]

if(any(cabfare$dropoff_latitude> 90)){
  cabfare<-cabfare[-which(cabfare$dropoff_latitude> 90),]
}else cabfare<-cabfare[which((cabfare$dropoff_latitude< 90)),]

if(any(cabfare$dropoff_latitude< -90)){
  cabfare<-cabfare[-which(cabfare$dropoff_latitude< -90),]
}else cabfare<-cabfare[which((cabfare$dropoff_latitude> -90)),]

if(any(cabfare$passenger_count< 1)){
  cabfare<-cabfare[-which(cabfare$passenger_count< 1),]
}else cabfare<-cabfare[which((cabfare$passenger_count> 1)),]

if(any(cabfare$passenger_count> 6)){
  cabfare<-cabfare[-which(cabfare$passenger_count> 6),]
}else cabfare<-cabfare[which((cabfare$passenger_count< 6)),]

if(any(cabfare$pickup_longitude== 0)){
  cabfare<-cabfare[-which(cabfare$pickup_longitude== 0),]
}else cabfare<-cabfare[which((cabfare$pickup_longitude!= 0)),]

if(any(cabfare$pickup_latitude== 0)){
  cabfare<-cabfare[-which(cabfare$pickup_latitude== 0),]
}else cabfare<-cabfare[which((cabfare$pickup_latitude!= 0)),]

if(any(cabfare$pickup_longitude== 0)){
  cabfare<-cabfare[-which(cabfare$pickup_longitude== 0),]
}else cabfare<-cabfare[which((cabfare$pickup_longitude!= 0)),]

if(any(cabfare$dropoff_longitude== 0)){
  cabfare<-cabfare[-which(cabfare$dropoff_longitude== 0),]
}else cabfare<-cabfare[which((cabfare$dropoff_longitude!= 0)),]

if(any(cabfare$dropoff_latitude== 0)){
  cabfare<-cabfare[-which(cabfare$dropoff_latitude== 0),]
}else cabfare<-cabfare[which((cabfare$dropoff_latitude!= 0)),]



################ Missing value analysis ###########################################################

# finding the column sum of all missing variables in the dataset

sapply(cabfare, function(x) sum(is.na(x)))

# finding the number of missing values in each variable and the percentage of missing values 

Missing_Val<-data.frame(apply(cabfare,2, function(x) sum(is.na(x))))
row.names(Missing_Val)
Missing_Val$Variables<-row.names(Missing_Val)
row.names(Missing_Val)<-NULL
names(Missing_Val)<-c("Missing Values", "Variables")
Missing_Val<-  Missing_Val[c(2,1)]
Missing_Val$MissingPercentage<-((Missing_Val$`Missing Values`)/ (nrow(cabfare))*100)
Missing_Val = Missing_Val[order(-Missing_Val$MissingPercentage),]


################## Imputation of Missing Values #########################################################

## 1. For fare_amount:

#Actual value = 16.5 (i.e. cabfare[8,1] value)


#Median = 8.5
#Mode = 6.5 
#KNN = 12.4

# 1. Median Method

cabfare$fare_amount[which(is.na(cabfare$fare_amount))]<-median(cabfare$fare_amount, na.rm = TRUE)

cabfare[8,1]<-NA
cabfare[8,1]

# 2. Mode Method

get_mode<-function(x){
  uniq<-na.omit(unique(x))
  uniq[which.max(tabulate(match(x,uniq)))]
}

cabfare$fare_amount[which(is.na(cabfare$fare_amount))]<-get_mode(cabfare$fare_amount)

cabfare[8,1]<-NA
cabfare[8,1]

# 3. knn Imputation

cabfare<-knnImputation(cabfare,k=3)


cabfare[8,1]<-NA
cabfare[8,1]

## 2. For passenger_count

# Actual Value = 3 (i.e.cabafare[25,7] value)
# Median = 1
# Mode = 1
# Knn = 1

## 1. Median

cabfare$passenger_count[which(is.na(cabfare$passenger_count))]<-median(cabfare$passenger_count, na.rm = TRUE)

cabfare[25,7]<-NA
cabfare[25,7]


## 2. Mode

get_mode<-function(x){
  uniq<-na.omit(unique(x))
  uniq[which.max(tabulate(match(x,uniq)))]
}

cabfare$passenger_count[which(is.na(cabfare$passenger_count))]<-get_mode(cabfare$passenger_count)

cabfare[25,7]<-NA
cabfare[25,7]

## 3. Knn method

cabfare<-knnImputation(cabfare,k=3)


cabfare[25,7]<-NA
cabfare[25,7]

############## Finalize Imputation Technique ##########################

cabfare<-knnImputation(cabfare,k=3)

################# Convert required datatypes ########################


cabfare$passenger_count<-ceiling(cabfare$passenger_count)
cabfare$passenger_count<-factor(cabfare$passenger_count, levels = c(1:6))


############# Feature Engineering   #########################################################################
## splitting the pick_datetime into Year, Month, Day and Hours i.e. adding more variables to the existing dataset


cabfare$pickup_datetime<-ymd_hms(cabfare$pickup_datetime) # library(lubridate)
cabfare$pickup_day<-as.factor(format(as.POSIXct(cabfare$pickup_datetime,format="%D-%M-%Y %H:%M:%S"),"%u"))
cabfare$pickup_month<-as.factor(format(as.POSIXct(cabfare$pickup_datetime,format="%D-%M-%Y %H:%M:%S"),"%m"))
cabfare$pick_year<-as.factor(format(as.POSIXct(cabfare$pickup_datetime,format="%H:%M:%S"),"%Y"))
cabfare$pickup_hours<-as.numeric(format(as.POSIXct(cabfare$pickup_datetime,format="%D-%M-%Y %H:%M:%S"),"%H"))
cabfare$pick_year<-factor(cabfare$pick_year, levels = c(2009,2010,2011,2012,2013,2014,2015), labels = c(1:7))

## Assigning levels to the pickup_hours 

cabfare$pickup_hours[which((cabfare$pickup_hours >=7) & (cabfare$pickup_hours <= 12))]<-'Mornings'
cabfare$pickup_hours[which((cabfare$pickup_hours > 18) & (cabfare$pickup_hours <= 24))]<-'Late Night'
cabfare$pickup_hours[which((cabfare$pickup_hours > 12) & (cabfare$pickup_hours <= 18))]<-'After Noon'
cabfare$pickup_hours[which((cabfare$pickup_hours >= 0) & (cabfare$pickup_hours < 7))]<-'Early Morning'
cabfare$pickup_hours<-factor(cabfare$pickup_hours,levels = c("Mornings","Late Night","After Noon","Early Morning"), labels = c(1:4))


## Calculating distance travelled based on latitude & longitude 



distance<-function(long1,lat1,long2,lat2){
  
  d<<-NULL
  for (i in 1:nrow(cabfare)) {
    
    dist<-distm(c(long1[i],lat1[i]),c(long2[i],lat2[i]),fun = distHaversine)  
    
    d<<-c(d,dist)
  }
  
}

distance(long1 = cabfare$pickup_longitude, lat1 = cabfare$pickup_latitude,
         long2 = cabfare$dropoff_longitude,lat2 = cabfare$dropoff_latitude)

## Adding variable 'distance' to the data 

cabfare$distance<-d

rm(d) # removing 'd' which is a temporary variable 


### Fare cannot be charged for the '0' distance travelled therefore removig all rows for which distance is 0

cabfare<-cabfare[-which(cabfare$distance==0),]

cabfare_New<-subset(cabfare, select = -c(pickup_longitude,pickup_latitude,dropoff_longitude,dropoff_latitude,pickup_datetime))


################# ####################  Outlier Analysis ##############################################

## outlier analysis will only be done for numeric variables 

numeric_index<-sapply(cabfare_New, is.numeric)

# Outlier analysis will be done only on fare_amount & distance
# We have to find outlier values for fare_amount & distance and subsequently 
# replace with 'NA' and filling 'NA's with values through suitable imputation techniques
# since we have chosen knn Imputation technique we will replace outlier values through knn imputation method


# 1. Outliers for distance

val_dist = cabfare_New$distance[cabfare_New$distance %in% boxplot.stats(cabfare_New$distance)$out]

cabfare_New$distance[which(cabfare_New$distance%in% val_dist)]=NA

cabfare_New<-knnImputation(cabfare_New, k=3)

# 2. Outliers for fare_values

val_fare = cabfare_New$fare_amount[cabfare_New$fare_amount %in% boxplot.stats(cabfare_New$fare_amount)$out]

cabfare_New$fare_amount[which(cabfare_New$fare_amount%in% val_fare)]=NA

cabfare_New<-knnImputation(cabfare_New, k=3)








################################ Feature Selection ###################################################


# selecting features or variables for the model
# correlation plot for numeric variables


corrgram(cabfare_New[,numeric_index], order = NULL, lower.panel = panel.shade, upper.panel = panel.pie, text.panel = panel.txt, 
         main = "Correlation Plot")

# since the cabfare data contains both numeric & categorical variables 'ANOVA' technique is used to find out the required features or variables 


anova<-aov(fare_amount~ pickup_hours+passenger_count+pickup_day+pickup_month+pick_year, data = cabfare_New)
summary(anova)


### Checking Multicollinearity 

VIF = as.data.frame(vif(anova)) 


# maximum VIF value is 1.85407 which shows there is no multicollinearity between the categorical variables


# Dropping variable(s) whose p>0.05 
#Assign new name for the data after dropping insignificant variables


cabfare_rem=subset(cabfare_New, select = -c(pickup_day))

##################### Scaling or Normalization #####################################################

# Check the distribution of data. If the data is normally distributed then we would go for standardization
#else go for normalization 

 
qplot(cabfare_rem$fare_amount,geom = 'histogram', xlab ='fare_amount', ylab = 'frequency') # slightly left skewed
qplot(cabfare_rem$distance,geom = 'histogram', xlab ='distance', ylab = 'frequency') # slightly left skewed

# Since distribution is not following normal distribution thereore we would go for normalizing the data 

normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

# Normalizing the distance variable 

cabfare_rem$distance<-normalize(cabfare_rem$distance)



##################### Reparing Cabfare_test Data ####################################################

Cabfare_test<-read.csv("C:\\Users\\kyvenkat\\Desktop\\W0376 Backup\\Datasets\\cabfare_test.csv", header = TRUE)


Cabfare_test$pickup_datetime<-ymd_hms(Cabfare_test$pickup_datetime) # library(lubridate)
test_pickup_datetime<- Cabfare_test["pickup_datetime"]

Cabfare_test$pickup_day<-as.factor(format(as.POSIXct(Cabfare_test$pickup_datetime,format="%D-%M-%Y %H:%M:%S"),"%u"))
Cabfare_test$pickup_month<-as.factor(format(as.POSIXct(Cabfare_test$pickup_datetime,format="%D-%M-%Y %H:%M:%S"),"%m"))
Cabfare_test$pick_year<-as.factor(format(as.POSIXct(Cabfare_test$pickup_datetime,format="%H:%M:%S"),"%Y"))
Cabfare_test$pickup_hours<-as.numeric(format(as.POSIXct(Cabfare_test$pickup_datetime,format="%D-%M-%Y %H:%M:%S"),"%H"))
Cabfare_test$pick_year<-factor(Cabfare_test$pick_year, levels = c(2009,2010,2011,2012,2013,2014,2015), labels = c(1:7))

Cabfare_test$pickup_hours[which((Cabfare_test$pickup_hours >=7) & (Cabfare_test$pickup_hours <= 12))]<-'Early Mornings'
Cabfare_test$pickup_hours[which((Cabfare_test$pickup_hours >=19) & (Cabfare_test$pickup_hours <= 24))]<-'Mornings'
Cabfare_test$pickup_hours[which((Cabfare_test$pickup_hours >=12) & (Cabfare_test$pickup_hours <=18))]<-'After Noon'
Cabfare_test$pickup_hours[which((Cabfare_test$pickup_hours >=0) & (Cabfare_test$pickup_hours <= 6))]<-'Late Nights'
Cabfare_test$pickup_hours<-factor(Cabfare_test$pickup_hours,levels = c("Mornings","Late Nights","After Noon","Early Mornings"), labels = c(1:4))

Cabfare_test$passenger_count<-factor(Cabfare_test$passenger_count, levels = c(1:6))

distance<-function(long1,lat1,long2,lat2){
  
  d12<<-NULL
  for (i in 1:nrow(Cabfare_test)) {
    
    dist<-distm(c(long1[i],lat1[i]),c(long2[i],lat2[i]),fun = distHaversine)  
    
    d12<<-c(d12,dist)
  }
  
}


distance(long1 = Cabfare_test$pickup_longitude, lat1 = Cabfare_test$pickup_latitude,
         long2 = Cabfare_test$dropoff_longitude,lat2 = Cabfare_test$dropoff_latitude)

Cabfare_test$distance<-d12
rm(d12)

Cabfare_test<-subset(Cabfare_test, select = -c(pickup_longitude,pickup_latitude,dropoff_longitude,dropoff_latitude))

Cabfare_test<-subset(Cabfare_test, select = -c(pickup_day))

Cabfare_test<-Cabfare_test[-which(Cabfare_test$distance==0),]  

Cabfare_test$distance<-normalize(Cabfare_test$distance)

###################### First we split Cabfare data into train & test datasets later after finalizing the model we will apply on Cabfare_test data ###########################

#####################  Devoloping  Train & Test Datasets ##################################

idx<- sample(1:nrow(cabfare_rem), size = 0.8*nrow(cabfare_rem))
Cab_train<-cabfare_rem[idx,]
Cab_test<-cabfare_rem[-idx,]


# Error metric used to select the model is RMSE


################################# Multiple Linear Regression Method #############################################

lm_model<-lm(fare_amount~., data = Cab_train)
summary(lm_model)

lm_pred<-predict(lm_model, Cab_test[,2:6])

regr.eval(Cab_test[,1],lm_pred, stats = c("mae","mse","rmse","mape"))

# RMSE = 2.372


################################ Decision Tree Technique #####################################

Dt_model = rpart(fare_amount ~ ., data = Cab_train, method = "anova")
summary(Dt_model)
Dt_pred<-predict(Dt_model, Cab_test[,2:6])

regr.eval(Cab_test[,1],Dt_pred, stats = c("mae","mse","rmse","mape"))

#RMSE = 2.564

################################ Random Forrest Technique ##################################



Rf_model = randomForest(fare_amount ~.,data=Cab_train)
summary(Rf_model)
Rf_pred<-predict(Rf_model,Cab_test[,2:6])
regr.eval(Cab_test[,1],Rf_pred, stats = c("mae","mse","rmse","mape"))

#RMSE = 2.590

################################ Gradient Boosting Method #######################################


boost<-gbm(fare_amount~.,data = Cab_train, distribution = "gaussian", n.trees = 10000, shrinkage = 0.01, interaction.depth = 4)
summary(boost) #Summary gives a table of Variable Importance and a plot of Variable Importance
gbm_pred<-predict(boost,Cab_test[,2:6], n.trees = 10000)
regr.eval(Cab_test[,1],gbm_pred, stats = c("mae","mse","rmse","mape"))

# RMSE = 2.326

################################### XGBoost Technique ########################################################



train_data_matrix<- as.matrix(sapply(Cab_train[,-1], as.numeric))
test_data_matrix<- as.matrix(sapply(Cab_test[,-1], as.numeric))

xgboost_model = xgboost(data = train_data_matrix ,label = Cab_train$fare_amount,nrounds = 15,verbose = FALSE)
xgb_pred<-predict(xgboost_model,test_data_matrix)

regr.eval(Cab_test[,1],xgb_pred, stats = c("mae","mse","rmse","mape"))

# RMSE = 2.325


Rf_pred_values<- data.frame(test_pickup_datetime, "predictions" = Rf_pred)


################### Applying Selected Technique on the Cabfare_test data ######################################


boost_model<-gbm(fare_amount~.,data = Cab_train, distribution = "gaussian", n.trees = 10000, shrinkage = 0.01, interaction.depth = 4)

gbm_pred<-predict(boost_model,Cabfare_test[,2:6], n.trees = 10000)



saveRDS(boost_model,"C:\\Users\\kyvenkat\\Desktop\\W0376 Backup\\Datasets\\Final_Model_Cabafare.rds")

Final_Cabfare_model<- readRDS("C:\\Users\\kyvenkat\\Desktop\\W0376 Backup\\Datasets\\Final_Model_Cabafare.rds")

print(Final_Cabfare_model)


Cabfare_wrt_datetime = data.frame(Cabfare_test$pickup_datetime,"predictions" = gbm_pred)

############## Writing Predicted values in .csv file ##################

write.csv(Cabfare_wrt_datetime,"cabfare_predictions_R.csv",row.names = FALSE)






