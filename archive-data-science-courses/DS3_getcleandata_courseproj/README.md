## Brief Synopsis of the Goal of this Study:

The goal of this study is to summarizes a subset of sensor data by subject and physical activity. The data used was collected from sensors contained in smartphones that measure a subject's position and direction. 30 subjects performed 6 activities, and 561 features (sensor data statistics) were captured on each subject-activity combination. Please see the 'License' section below for more on the underlying data source.

## R Script Used and Steps Performed: 

There is one script, run_analysis.R, which contains 5 steps. Each step uses as input the prior step result.

A preliminary step 0 is to set R's working directory, download the data into that directory and unzip all files.

* 0. Data used is downloaded from:
    url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    Unzipping this file creates a folder with the data and metadata / readme files.
* 1. Merge the training and the test sets to create one data set.
* 2. Extract only the measurements on the mean and standard deviation for each measurement. 
* 3. Use descriptive activity names to name the activities in the data set.
* 4. Appropriately label the data set with descriptive variable names.
* 5. From the data set in step 4, create a second, independent tidy data set with the 
    average of each variable for each activity and each subject.
    Write the tidy dataset to a txt file.

Please refer to the CodeBook.md file for details on these steps as well as variable and transformation details.



## License:

Please refer to the following publication for more information on the underlying dataset: 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

A few excerpts copied directly from the study's 'README.txt' file, that are especially relevant to this analysis (please refer to the full details within the .zip file above for more information):

Human Activity Recognition Using Smartphones Dataset

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually.
