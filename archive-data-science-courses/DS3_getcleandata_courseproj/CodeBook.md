## Brief Synopsis of the Goal of this Study:

The goal of this study is to summarizes a subset of sensor data by subject and physical activity. The data used was collected from sensors contained in smartphones that measure a subject's position and direction. 30 subjects performed 6 activities, and 561 features (sensor data statistics) were captured on each subject-activity combination. Please see the 'License' section in the README.md file for more on the underlying data source.


## Description of the variables in the output dataset:
subjectNbr: number identifying a person in the study
activityName: activity the person was performing: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
66 numeric variables representing the average of a mean or standard deviation variable over the subject / activity combination. The 66 numeric variables are:

 [1] "timeBodyAcc_meanOf_X"           "timeBodyAcc_meanOf_Y"           "timeBodyAcc_meanOf_Z"          
 [4] "timeBodyAcc_stdOf_X"            "timeBodyAcc_stdOf_Y"            "timeBodyAcc_stdOf_Z"           
 [7] "timeGravityAcc_meanOf_X"        "timeGravityAcc_meanOf_Y"        "timeGravityAcc_meanOf_Z"       
[10] "timeGravityAcc_stdOf_X"         "timeGravityAcc_stdOf_Y"         "timeGravityAcc_stdOf_Z"        
[13] "timeBodyAccJerk_meanOf_X"       "timeBodyAccJerk_meanOf_Y"       "timeBodyAccJerk_meanOf_Z"      
[16] "timeBodyAccJerk_stdOf_X"        "timeBodyAccJerk_stdOf_Y"        "timeBodyAccJerk_stdOf_Z"       
[19] "timeBodyGyro_meanOf_X"          "timeBodyGyro_meanOf_Y"          "timeBodyGyro_meanOf_Z"         
[22] "timeBodyGyro_stdOf_X"           "timeBodyGyro_stdOf_Y"           "timeBodyGyro_stdOf_Z"          
[25] "timeBodyGyroJerk_meanOf_X"      "timeBodyGyroJerk_meanOf_Y"      "timeBodyGyroJerk_meanOf_Z"     
[28] "timeBodyGyroJerk_stdOf_X"       "timeBodyGyroJerk_stdOf_Y"       "timeBodyGyroJerk_stdOf_Z"      
[31] "timeBodyAccMag_meanOf"          "timeBodyAccMag_stdOf"           "timeGravityAccMag_meanOf"      
[34] "timeGravityAccMag_stdOf"        "timeBodyAccJerkMag_meanOf"      "timeBodyAccJerkMag_stdOf"      
[37] "timeBodyGyroMag_meanOf"         "timeBodyGyroMag_stdOf"          "timeBodyGyroJerkMag_meanOf"    
[40] "timeBodyGyroJerkMag_stdOf"      "freqBodyAcc_meanOf_X"           "freqBodyAcc_meanOf_Y"          
[43] "freqBodyAcc_meanOf_Z"           "freqBodyAcc_stdOf_X"            "freqBodyAcc_stdOf_Y"           
[46] "freqBodyAcc_stdOf_Z"            "freqBodyAccJerk_meanOf_X"       "freqBodyAccJerk_meanOf_Y"      
[49] "freqBodyAccJerk_meanOf_Z"       "freqBodyAccJerk_stdOf_X"        "freqBodyAccJerk_stdOf_Y"       
[52] "freqBodyAccJerk_stdOf_Z"        "freqBodyGyro_meanOf_X"          "freqBodyGyro_meanOf_Y"         
[55] "freqBodyGyro_meanOf_Z"          "freqBodyGyro_stdOf_X"           "freqBodyGyro_stdOf_Y"          
[58] "freqBodyGyro_stdOf_Z"           "freqBodyAccMag_meanOf"          "freqBodyAccMag_stdOf"          
[61] "freqBodyBodyAccJerkMag_meanOf"  "freqBodyBodyAccJerkMag_stdOf"   "freqBodyBodyGyroMag_meanOf"    
[64] "freqBodyBodyGyroMag_stdOf"      "freqBodyBodyGyroJerkMag_meanOf" "freqBodyBodyGyroJerkMag_stdOf" 


### Transformations are described below in the context of the steps used to meet the objective of summarizing the data by activity and subject.


#### 1. Merge the training and the test sets to create one data set.
The main numeric data is contained in the following text files:
train/X_train.txt
test/X_test.txt

These were read into R and concatenated into the R dataset named rundata. This dataset has 10299 rows and 561 columns. The columns represent the different features tracked by the sensors, and each row represents a subject and activity. 

The rundata dataset at this point contained only the numeric variables and had no variable names. These shortcomings were next addressed so that the data could be made ready for summary and analysis.

#### 2. Extract only the measurements on the mean and standard deviation for each measurement. 
Variable names were linked into the rundata dataset from the supplied features.txt file. The feature names were somewhat descriptive but were scrubbed to make more readable and descriptive. There were some characters in the variable names that were changed to remove potentially troublesome (to work with in R) symbolic characters such as hyphens, commas, and parentheses. The data is on time and frequency, abbreviated with a starting t or f in the frequency file, I changed these to read 'time' and 'freq' respectively to be a bit more descriptive. 

The question we are trying to answer involves only mean and standard deviation variables, so the data was reduced at this point to remove all other variables. I noted that there are some feature variables described as 'mean frequency', I assumed that these were not part of the requested data. After applying the filter, there were 66 columns that contained means and standard deviation features.

#### 3. Use descriptive activity names to name the activities in the data set.
The combination of activity and subject provides context to the rows. The files train/y_train.txt and test/y_test.txt contain numeric indicators of the 6 activities that subject participants performed in the study: standing, walking downstairs, walking upstairs, walking, sitting, laying. Translation of the 6 numeric indicators with the descriptive activity names was performed by merging the numeric indicators with their names, available in the activity_labels.txt file, being careful not to undermine how data was originally sorted before the merging. The subject number (30 subjects) was also obtained from train/subject_train.txt and test/subject_test.txt. The subject number and activity name were placed into the dataset as columns to better describe the data and make it possible to summarize the data in the final step. The data set now has 68 columns: the 66 numeric mean and standard deviation variables, along with the addition of the two descriptor variables.

#### 4. Appropriately label the data set with descriptive variable names.
Note this step was actually already performed in step 1.

#### 5. From the data set in step 4, create a second, independent tidy data set.
This dataset will have the average of each variable for each activity and each subject. Write the tidy dataset to a txt file. This dataset has 180 rows (30 subjects x 6 activities), and 68 columns (subject, activity, and 66 mean or std variable averages).

I used the ddply() function from the plyr library to accomplish obtaining the averages by the two descriptor variable columns. The file was written out to a space delimited txt file. Column names were kept, row names were not though these were just default numeric values; the subject and activity are available separately in the first and second columns of the output file.


Note, one can use this code to read the tidy data table back in to R:

    indata <- read.table("rundata_tidy.txt", header = TRUE) 


