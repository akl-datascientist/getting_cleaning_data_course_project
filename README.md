---
title: "README Course Project"
author: "akl-datascientist"
date: "October 21, 2015"
output: html_document
---

## Creating Tidy Dataset
In this document, I describe in details that analysis performed to create the tidy dataset. Creating the tidy dataset comprised of 7 main steps.

### Step 1: Downloading the data
The first step was to download the data file and extract its contents. I downloaded the file and saved it as "activity.zip". Then I unzipped its contents in the working directory. Here is the code that was used to complete this task:
```
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" # URL to the data  
download.file(fileUrl, destfile = "./activity.zip", method = "curl") # download the file and name it "activit.zip"  
unzip("activity.zip") # unzip the contents of "activity.zip"  
```
The unzipped contents were a directory named "UCI HAR Dataset".

### Step 2: Reading in the trainig and test sets and merging them

The "UCI HAR Dataset" folder has two sub-directories: "train" and "test". Therefore, subsequently, I read in the training and test data files, both containing 561 features extracted from the acquired signals, however for different subjects. The training data was saved as "trainig.activity.data" and the test data was saved as "test.activity.data". Then I merged them using "rbind" to create one dataset which I named "train.test.data." Here is the code that was executed to complete this step. 
```
train.activity.data <- read.csv("./UCI HAR Dataset/train/X_train.txt", colClasses = "numeric", header = FALSE, sep = "") # read in the training data 
test.activity.data <- read.csv("./UCI HAR Dataset/test/X_test.txt", colClasses = "numeric", header = FALSE, sep = "") # read in the test data
train.test.data <- rbind(train.activity.data, test.activity.data) # combined training and test data
```
The result of this step was the merged dataframe "train.test.data" which still had the same number of columns equal to 561 but the number of rows was equal to the number of rows in the training set + the number of rows in the test set.

### Step 3 - Extracting only the data associated with features in the form of the mean and the standard deviation of the measured variables

In addition to the "train" and "test" sub-directories, the "UCI HAR Dataset" directory also contained a text file that contained a list of the 561 features. So, subsequently, I extracted only the features in the form of the mean and the standard deviation of the measures computed from the acquired signals. To do that, I first read in the text file containg the list of all the features and saved it as "features.list". Then I created a logical vector "mean.std.inds" to indicate whether a feature was the mean or the standard deviation of a measure computed from the acquired signals. Then this logical vector was used to create a new dataset whose columns where only features in the form of the mean and the standard deviation of the measures computed from the acquired signals. Here is the code that was executed to complete this step.
```
feature.list <- read.csv("./UCI HAR Dataset/features.txt", colClasses = "character", header = FALSE, sep = "", col.names = c("feature_num", "feature_name")) # read in the list of features
mean.std.inds <- grepl("mean()", feature.list$feature_name, fixed = TRUE) | grepl("std()", feature.list$feature_name, fixed = TRUE) # logical vector
data.mean.std <- train.test.data[, mean.std.inds] # choose only featurs of interest
```
The output of this step was the dataframe "data.mean.std" that contained only the 66 features that were in the form of the mean and the standard deviation of the measures computed from the acquired signals.

### Step 4 - Using descriptive activity names to name the activities in the data set

Furthermore, the "UCI HAR Dataset" also contained a text file that contained a list of the six activities that were peformed by the volunteers. Therefore, next, I read in the list of activities stored in the file "activity_labels.txt" and saved the list of activities as a data frame named "activity.list." Here is the code that was executed to read in the list of activities.
```
activity.list <- read.csv("./UCI HAR Dataset/activity_labels.txt", colClasses = c("numeric", "character"), header = FALSE, sep = "", col.names = c("activity_num", "activity_name")) # read in the list of activities
```
Also, I read in the activities corresponding to each row in the training set stored in the file "y_train.txt" and saved the data as a list named "train.activity.nums." Then the activities were replaced with descriptive names found in the data frame "activity.list." Here is the code that was executed to accomplish this task.
```
train.activity.nums <- read.csv("./UCI HAR Dataset/train/y_train.txt", colClasses = "numeric", header = FALSE, col.names = "activity_num") # read in the training set activity labels 
train.activity.labels <- data.frame(activity.list$activity_name[train.activity.nums$activity_num]) # change activity numbers to descriptive names
colnames(train.activity.labels) <- "activity" # give column the label "activity"
```
Similarly, the same objective as achieved with the test data activities. Here is the code that executed to read in the activities corresponding to each row in the test data and save them as a data frame named "test.activity.nums." The activities were then replaced with descriptive names. Here is the code that was executed.
```
test.activity.nums <- read.csv("./UCI HAR Dataset/test/y_test.txt", colClasses = "numeric", header = FALSE, col.names = "activity_num") # read in the test data activity labels 
test.activity.labels <- data.frame(activity.list$activity_name[test.activity.nums$activity_num]) # change activity numbers to descriptive names
colnames(test.activity.labels) <- "activity" # give column the label "activity"
```

Finally, the training and test set activities were merged using "rbind" and the resulting list was added as a column to the dataset created in Step 2 by merging the training and the test sets. Here is the code that was executed to complete this step.
```
activity.labels <- rbind(train.activity.labels, test.activity.labels) # combine the training activity labels and the test activity labels

data.labels.mean.std <- cbind(activity.labels, data.mean.std) # add a column representing the activity name for each observation
```
The output of this step was a data frame "data.labels.mean.std" containing the 66 features in the form of the mean and the standard deviation of the measures computed from the acquired signals + the activity corresponding to each observation or row.

### Step 5 - Labeling dataset with descriptive variable names. 
The fifth step was to give the columns in the created dataset from Step 4 meaningful descriptive names. Accordingly, the list of features that was read in in Step 3 was subset to extract the names of the features that were in the form of the mean and standard deviation of the measures compured from the acquired signals. Here is the code that was executed to do that.
```
feature.mean.std <- feature.list[mean.std.inds,] # store features in the form of the mean and the standard deviation of the variables
col.names <- gsub("()", "", feature.mean.std$feature_name, fixed = TRUE) # clean the names of features by removing the brackets "()"
```
We also added another column that indicated the number of the volunteer from 1 to 30. Here is the code that was executed to accomplish this.
```
train.subject.nums <- read.csv("./UCI HAR Dataset/train/subject_train.txt", colClasses = "numeric", header = FALSE, col.names = "subject") # read in the subject number for each observation in the training set
test.subject.nums <- read.csv("./UCI HAR Dataset/test/subject_test.txt", colClasses = "numeric", header = FALSE, col.names = "subject") # read in the subject number for each observation in the test set
subject.nums <- rbind(train.subject.nums, test.subject.nums) # combines the subject numbers for the observations in the training and the test sets
```
Finally, the columns were given descriptive names and the resulting dataset named "dataset" was arranged based on subject and activity. Here is the code that was executed to meet this objective.
```
dataset <- cbind(subject.nums, data.labels.mean.std) # add a column to the data set to indicate the subject number corresponding to each observation
colnames(dataset) <- c("subject", "activity", col.names) # assign descriptive names to each variable
dataset <- arrange(dataset, subject, activity) # arrange the dataset based on subject and activity
```
The output of this step was a complete dataset that had 68 columns, one column representing the subject number, another column an activity, and 66 columns representing the mean and the standard deviation of the measures computed from the acquired signals associated with the corresponding activity.

### Step 6 - Creating a second, independent tidy data set with the average of each variable for each activity and each subject.
The sixth step was the compute the average of each of the 66 features for each activity and each subject. Here is the code that was executed to do so.
```
subject.activity <- group_by(dataset, subject, activity) # group the dataset by subject and activity
dataset.tidy <- data.frame(summarise_each(subject.activity, funs(mean))) # compute the mean of each variable for each activity and subject and save the new data as a data frame
```
The result of this step was the tidy dataset named "dataset.tidy."

### Step 7 - Writing the tidy data set to a text file
Finally, the tidy set was written to text file named "tidy_dataset.txt." Here is the code that was executed to meet this objective.
```
write.table(dataset.tidy, "tidy_dataset.txt", row.names = FALSE) # write the new the tidy dataset to the working directory
```
