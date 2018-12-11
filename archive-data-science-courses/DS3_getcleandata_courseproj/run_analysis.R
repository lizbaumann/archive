#############################################################################################
# Getting and Cleaning Data, week 3 Programming Assignment:
# NOTE assumes R working directory already set and you unzip the downloaded file as-is
#############################################################################################
downloadData <- function() { # just holding this code, do not need to rerun each time
        download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                      destfile="runData.zip", method="curl")
}

# Assumes you now go to working directory and unzip the file manually. 

# Use readData function to read various files in to R.
readData <- function(file.name, column.types=NA, missing.types, skiprows=0, maxrows=-1) {
        read.table(file=paste("./UCI HAR Dataset/", file.name, sep=""), 
                   sep="", 
                   quote = "\"", 
                   na.strings=missing.types,
                   colClasses=column.types,
                   nrows=maxrows,
                   skip=skiprows
                   )
}

missingtypes <- c("NA","", "Not available", "Not Available", "?", " ", "N/A", "n/a")

#############################################################################################
# 1. Merge the training and the test sets to create one data set.
#############################################################################################
train <- readData(file.name="train/X_train.txt", column.types="numeric", missing.types=missingtypes)
test <- readData(file.name="test/X_test.txt", column.types="numeric", missing.types=missingtypes)
rundata <- rbind(train, test)
# dim(rundata)   # 10299 rows, 561 col

# column names: note this is needed in step 4 but seems easier to do it now:
features <- readData(file.name="features.txt", column.types=c("numeric","character"), missing.types=missingtypes)

# Looking over feature names, would be good to do some clean up for: 
# messy characters such as - , (), also define t=time, f=frequency:
features$V2 <- gsub("-","_",features$V2,fixed=T)
features$V2 <- gsub("(","Of",features$V2,fixed=T)
features$V2 <- gsub(")","",features$V2,fixed=T)
features$V2 <- gsub(",","_and_",features$V2,fixed=T)
features$V2 <- gsub("tBody","timeBody",features$V2,fixed=T)
features$V2 <- gsub("tGravity","timeGravity",features$V2,fixed=T)
features$V2 <- gsub("fBody","freqBody",features$V2,fixed=T)
features$V2 <- gsub("fGravity","freqGravity",features$V2,fixed=T)


colnames(rundata) <- features$V2
# dim(features)   # 561 rows, 2 cols


#############################################################################################
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
#    Note, I assumed we do not want the 'meanFreq()' variables, only want mean() and std().
#############################################################################################
allcols <- colnames(rundata)
keepcols <- c(grep("meanOf",allcols,fixed=T), grep("stdOf",allcols,fixed=T))   # numeric vector
keepcols <- sort(keepcols)
rundata.meanstd <- rundata[, keepcols]
# dim(rundata.meanstd)   # 10299 rows, 66 col


#############################################################################################
# 3. Use descriptive activity names to name the activities in the data set.
#############################################################################################
# You also need subject, get that first
train.subs <- readData(file.name="train/subject_train.txt", column.types="numeric", missing.types=missingtypes)
test.subs <- readData(file.name="test/subject_test.txt", column.types="numeric", missing.types=missingtypes)
rundata.subs <- rbind(train.subs,test.subs)
# dim(rundata.subs): 10299 1

rundata.meanstd.more <- cbind(subjectNbr=rundata.subs$V1, rundata.meanstd)

# The class labels match up to rows, use the activity_labels to translate to the 6 activities
train.labels <- readData(file.name="train/y_train.txt", column.types="numeric", missing.types=missingtypes)
test.labels <- readData(file.name="test/y_test.txt", column.types="numeric", missing.types=missingtypes)
rundata.labels <- rbind(train.labels,test.labels)
activity.labels <- readData(file.name="activity_labels.txt", column.types=c("numeric","character"), 
                            missing.types=missingtypes)
colnames(rundata.labels) <- "activityNbr"
colnames(activity.labels) <- c("activityNbr", "activityName")
# dim(rundata.labels): 10299 1 . . . dim(activity.labels): 6 2 

rundata.meanstd.more <- cbind(activityNbr=rundata.labels$activityNbr, rundata.meanstd.more)

# CAUTION: merge (by default) reorders the data! So do this now:
rundata.meanstd.more <- merge(activity.labels, rundata.meanstd.more, by.x = "activityNbr", by.y = "activityNbr", sort=FALSE)
rundata.meanstd.more <- rundata.meanstd.more[,2:ncol(rundata.meanstd.more)]
# dim(rundata.meanstd.more)   # 10299 rows, 68 col


#############################################################################################
# 4. Appropriately label the data set with descriptive variable names. 
#    Note this step was already performed in step 1.
#############################################################################################


#############################################################################################
# 5. From the data set in step 4, create a second, independent tidy data set with the 
#    average of each variable for each activity and each subject.
#    Write tidy dataset to a txt file. This dataset has 180 rows (30 subjects x 6 activities), 
#    and 68 columns (subject, activity, and 66 mean or std variable averages).
#############################################################################################
library(plyr)
rundata.tidy <- ddply(rundata.meanstd.more, .(subjectNbr, activityName), numcolwise(mean))
write.table(x=rundata.tidy, file="rundata_tidy.txt", row.names=FALSE)

# Note you can read this data back in with:
# indata <- read.table("rundata_tidy.txt", header = TRUE)
