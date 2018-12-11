# Evaluating Correctness of Biceps Curls from Sensor Data


### Executive Summary

In this study, the aim is to develop a model that predicts the manner in which biceps curl exercises were performed - correctly, or one of 4 variations of incorrectness - given data from sensors worn by each of 6 participants while performing the exercise. This area of research is called Human Activity Recognition (HAR). The data for this study came from http://groupware.les.inf.puc-rio.br/har, this website also has a more detailed description of how the data was obtained and what others are using it for. A brief description is as follows:

Six young healthy participants were asked to perform one set of 10 repetitions of the Unilateral Dumbbell Biceps Curl in five different fashions, represented in the training data as variable classe (this is our outcome variable that we wish to predict on a test set): 

A = exactly according to the specification,  
B = throwing the elbows to the front,  
C = lifting the dumbbell only halfway,  
D = lowering the dumbbell only halfway,  
E = throwing the hips to the front  

Variables in the data set include this classe variable, user name, timestamp, time window, and 152 sensor measurement statistics. To build a model, I first randomly partitioned the training set into a train and test set, performed some exploratory data analysis, reduced the size of the training subset appropriately, and applied a random forest prediction model. The data partitioning allowed cross-validation of results from the train set to a test set where the outcome classe variable is present, so we can measure accuracy of the model (the 20-row supplied test set, which I will refer to as validation, has no outcome variable and is only used to submit final results to be validated externally). The application of the model to the final 20-case validation set is expected to have an accuracy rate approximately equal to the accuracy on the larger test set (out of sample error). To score correctly on all 20 cases, we should look for over 95% accuracy from our prediction model. A Random Forest model applied to a sizable portion of the base data was found to produce 99% accuracy.

Following describes the steps used to go from the raw data through to the result.


### Data Processing

Here I read in the data, and create train/test datasets by randomly partitioning the original training data set. The original training set is quite large, over 19000 rows, and to split it into a subset that allows reasonable time to run the model, I chose a relatively small proportion (20%) to train our model on, though this is still a sizable nominal number of observations. We used functions from the R caret package to both partition the data and train our model.



```r
library(caret)
```

```
## Loading required package: lattice
## Loading required package: ggplot2
```

```r
# download the csv files if not already available, and read the csv files 
if(!file.exists("training.csv")) {
        download.file("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv", 
              "training.csv", method="curl")
}
training0 <- read.csv("training.csv", na.strings = c("NA", "?", ""), stringsAsFactors=FALSE) 
training0$classe <- as.factor(training0$classe)

if(!file.exists("testing.csv")) {
        download.file("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv", 
              "testing.csv", method="curl")
}
validation <- read.csv("testing.csv", na.strings = c("NA", "?", ""), stringsAsFactors=FALSE) 

set.seed(12346)
inTrain <- createDataPartition(y=training0$classe, p=0.2, list=F)
training <- training0[inTrain, ]
testing <- training0[-inTrain, ]
```


### Explore the Data

Number of rows and columns in supplied full training dataset and subsetted training set, counts table of the outcome variable in the full training set, and show subset of data set contents:


```r
dim(training0)
```

```
## [1] 19622   160
```

```r
dim(training)
```

```
## [1] 3927  160
```

```r
table(training0$classe)
```

```
## 
##    A    B    C    D    E 
## 5580 3797 3422 3216 3607
```

```r
str(training0[,c(1:15,160)])  # illustrating data set structure and that some columns have lots of NAs
```

```
## 'data.frame':	19622 obs. of  16 variables:
##  $ X                   : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ user_name           : chr  "carlitos" "carlitos" "carlitos" "carlitos" ...
##  $ raw_timestamp_part_1: int  1323084231 1323084231 1323084231 1323084232 1323084232 1323084232 1323084232 1323084232 1323084232 1323084232 ...
##  $ raw_timestamp_part_2: int  788290 808298 820366 120339 196328 304277 368296 440390 484323 484434 ...
##  $ cvtd_timestamp      : chr  "05/12/2011 11:23" "05/12/2011 11:23" "05/12/2011 11:23" "05/12/2011 11:23" ...
##  $ new_window          : chr  "no" "no" "no" "no" ...
##  $ num_window          : int  11 11 11 12 12 12 12 12 12 12 ...
##  $ roll_belt           : num  1.41 1.41 1.42 1.48 1.48 1.45 1.42 1.42 1.43 1.45 ...
##  $ pitch_belt          : num  8.07 8.07 8.07 8.05 8.07 8.06 8.09 8.13 8.16 8.17 ...
##  $ yaw_belt            : num  -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 ...
##  $ total_accel_belt    : int  3 3 3 3 3 3 3 3 3 3 ...
##  $ kurtosis_roll_belt  : chr  NA NA NA NA ...
##  $ kurtosis_picth_belt : chr  NA NA NA NA ...
##  $ kurtosis_yaw_belt   : chr  NA NA NA NA ...
##  $ skewness_roll_belt  : chr  NA NA NA NA ...
##  $ classe              : Factor w/ 5 levels "A","B","C","D",..: 1 1 1 1 1 1 1 1 1 1 ...
```


##### Variables With Missing Data  

In exploring the dataset, I noticed a number of measurement variables have large numbers of missing data. Below shows that 100 fields are only populated when new_window = "yes" (406 instances). These look like summary statistics, their column names start with max, min, avg, amplitude, var, stddev, kurtosis, skewness. The remaining 52 measures fields are always populated for every row. The supplied test (validation) set of 20 records contains no data with new window="yes", so it seems like we can ignore the 100 fields with missing data. This leaves about 50 measurement variables, still quite a large number of variables, but manageable as long as we keep a reasonable number of rows in the training set.


```r
nas <- data.frame()
for (i in 1:ncol(training0)) {
        nas[i,1] <- colnames(training0)[i]
        nas[i,2] <- sum(is.na(training0[,i]))
        nas[i,3] <- nas[i,2]/nrow(training0)
}
colnames(nas) <- c("measure", "numNA", "pctNA")
nrow(nas[nas$pctNA != 0,]) # columns that have NAs 
```

```
## [1] 100
```

```r
notNA <- training0[!is.na(training0[,12]),]
table(notNA$new_window) # compare to full training set field
```

```
## 
## yes 
## 406
```

```r
table(training0$new_window) # ... only the new_window=yes data has these fields populated
```

```
## 
##    no   yes 
## 19216   406
```

```r
table(validation$new_window) # the test/validation set we will ultimately test model on:
```

```
## 
## no 
## 20
```

##### Preparing Training Data Subset for our Model

Here, on the training subset which will be put through a Random Forest model, I perform the removal of the columns with missing data, and additionally remove a few other extraneous columns (a row number X and two duplicate timestamp columns).


```r
training <- training[, nas$pctNA == 0]
training <- training[, c(2,5:60)]

testing <- testing[, nas$pctNA == 0]
testing <- testing[, c(2,5:60)]

dim(training) # this data set to be sent to the model
```

```
## [1] 3927   57
```


### Fit a Model and Evaluate Accuracy

Random Forest, a very widely used model for machine learning, was chosen for the model (using all variables in the training subset as reduced above) because it produced reasonably good accuracy figures on the held-out test set of data. I also tried a simple single decision tree model and Boosting (results not shown); the single tree was fast to run but did not perform with accuracy as good as was seen with the Random Forest (which can be thought of as repeated and aggregated results of single tree models), and Boosting was slower and produced results comparable but slightly less accurate than Random Forest. 

Size of the dataset was a concern; early attempts at including more rows in the train set did not run, so I settled on a relatively low proportion but still a sizable number of data rows. Standardizing numeric variables had little or no impact. Even with reducing the number of measurement columns from 152 to 52, that is still quite a lot of variables. Some correlations were seen among columns but I did not try reducing number of columns further. Boosting seemed like it might do well since it can take a lot of possibly weak predictors, weight and aggregate them to get a stronger predictor; while Boosting did do well, Random Forest did even better, so I chose Random Forest.

Model results follow:


```r
modRF <- train(classe ~ ., data=training, methods='rf') 
```

```
## Loading required package: randomForest
## randomForest 4.6-10
## Type rfNews() to see new features/changes/bug fixes.
```

```r
modRF 
```

```
## Random Forest 
## 
## 3927 samples
##   56 predictor
##    5 classes: 'A', 'B', 'C', 'D', 'E' 
## 
## No pre-processing
## Resampling: Bootstrapped (25 reps) 
## 
## Summary of sample sizes: 3927, 3927, 3927, 3927, 3927, 3927, ... 
## 
## Resampling results across tuning parameters:
## 
##   mtry  Accuracy  Kappa  Accuracy SD  Kappa SD
##    2    1         0.9    0.007        0.008   
##   40    1         1.0    0.004        0.006   
##   78    1         1.0    0.007        0.008   
## 
## Accuracy was used to select the optimal model using  the largest value.
## The final value used for the model was mtry = 40.
```

```r
predRF <- predict(modRF, newdata=testing)
confusionMatrix(predRF, testing$classe)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 4463   51    0    0    0
##          B    1 2971   33    0    0
##          C    0   14 2696   16    0
##          D    0    1    8 2554   35
##          E    0    0    0    2 2850
## 
## Overall Statistics
##                                         
##                Accuracy : 0.99          
##                  95% CI : (0.988, 0.991)
##     No Information Rate : 0.284         
##     P-Value [Acc > NIR] : <2e-16        
##                                         
##                   Kappa : 0.987         
##  Mcnemar's Test P-Value : NA            
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity             1.000    0.978    0.985    0.993    0.988
## Specificity             0.995    0.997    0.998    0.997    1.000
## Pos Pred Value          0.989    0.989    0.989    0.983    0.999
## Neg Pred Value          1.000    0.995    0.997    0.999    0.997
## Prevalence              0.284    0.194    0.174    0.164    0.184
## Detection Rate          0.284    0.189    0.172    0.163    0.182
## Detection Prevalence    0.288    0.191    0.174    0.166    0.182
## Balanced Accuracy       0.998    0.988    0.991    0.995    0.994
```

The confusion matrix shows the accuracy of the prediction on the test set is 99%, or in other words, inaccuracy of 1%. This is representative of the out of sample error, the error we would expect to find on applying the model to a held out dataset (as in the original testing set aka validation set).


### Applying the Model to the Supplied Testing Set

Below applies the Random Forest model to the supplied testing (validation) set of data and creates the 20 txt files to be submitted for the assignment. The results (A-E) for the 20 records are also listed. 


```r
answers <- predict(modRF, newdata=validation)
 
pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}
 
pml_write_files(answers)

answers
```

```
##  [1] B A B A A E D B A A B C B A E E A B B B
## Levels: A B C D E
```


### Conclusions

With a Random Forest model applied to 20% of the training data, I was able to predict the manner in which people performed biceps curl exercise with 99% accuracy as observed above. Applied to the supplied test (validation) set of 20 records, I would expect to get all 20 test records correct on submission, which is what I did see.
