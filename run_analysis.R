library(dplyr) # upload the dplyr library

# Step 1 - Read in the training and the test data and merge them

train.activity.data <- read.csv("./UCI HAR Dataset/train/X_train.txt", colClasses = "numeric", header = FALSE, sep = "") # read in the training data stored in the file X_train.txt
test.activity.data <- read.csv("./UCI HAR Dataset/test/X_test.txt", colClasses = "numeric", header = FALSE, sep = "") # read in the test data stored in the file X_test.txt
train.test.data <- rbind(train.activity.data, test.activity.data) # combined training and test data

# Step 2 - Extract only the data associated with features in the form of the mean and the standard deviation of the measured variables

feature.list <- read.csv("./UCI HAR Dataset/features.txt", colClasses = "character", header = FALSE, sep = "", col.names = c("feature_num", "feature_name")) # read in the list of features stored in the file features.txt
mean.std.inds <- grepl("mean()", feature.list$feature_name, fixed = TRUE) | grepl("std()", feature.list$feature_name, fixed = TRUE) # logical vector that indicates whether the feature is the mean or the standard deviation of the corresponding variable
data.mean.std <- train.test.data[, mean.std.inds] # choose only data associated with the features in the form of the mean and the standard deviation of the measured variables

# Step 3 - Use descriptive activity names to name the activities in the data set

activity.list <- read.csv("./UCI HAR Dataset/activity_labels.txt", colClasses = c("numeric", "character"), header = FALSE, sep = "", col.names = c("activity_num", "activity_name")) # read in the list of activities stored in the file activity_labels.txt

train.activity.nums <- read.csv("./UCI HAR Dataset/train/y_train.txt", colClasses = "numeric", header = FALSE, col.names = "activity_num") # read in the activity labels associated with the indiviual observations in the training set
train.activity.labels <- data.frame(activity.list$activity_name[train.activity.nums$activity_num]) # change activity numbers in training set to descriptive names
colnames(train.activity.labels) <- "activity" # give column the label "activity"

test.activity.nums <- read.csv("./UCI HAR Dataset/test/y_test.txt", colClasses = "numeric", header = FALSE, col.names = "activity_num") # read in the activity labels associated with the individual observations in the test set
test.activity.labels <- data.frame(activity.list$activity_name[test.activity.nums$activity_num]) # change activity numbers in test set to descriptive names
colnames(test.activity.labels) <- "activity" # give column the label "activity"

activity.labels <- rbind(train.activity.labels, test.activity.labels) # combine the training activity labels and the test activity labels

data.labels.mean.std <- cbind(activity.labels, data.mean.std) # adds a column representing the activity name for each observation

# Step 4 - Label dataset with descriptive variable names. 

feature.mean.std <- feature.list[mean.std.inds,] # store features in the form of the mean and the standard deviation of the variables
col.names <- gsub("()", "", feature.mean.std$feature_name, fixed = TRUE) # clean the names of features by removing the brackets "()"

train.subject.nums <- read.csv("./UCI HAR Dataset/train/subject_train.txt", colClasses = "numeric", header = FALSE, col.names = "subject") # read in the subject number for each observation in the training set
test.subject.nums <- read.csv("./UCI HAR Dataset/test/subject_test.txt", colClasses = "numeric", header = FALSE, col.names = "subject") # read in the subject number for each observation in the test set
subject.nums <- rbind(train.subject.nums, test.subject.nums) # combines the subject numbers for the observations in the training and the test sets

dataset <- cbind(subject.nums, data.labels.mean.std) # add a column to the data set to indicate the subject number corresponding to each observation
colnames(dataset) <- c("subject", "activity", col.names) # assign descriptive names to each variable
dataset <- arrange(dataset, subject, activity) # arrange the dataset based on subject and activity

# Step 5 - Create a second, independent tidy data set with the average of each variable for each activity and each subject.

subject.activity <- group_by(dataset, subject, activity) # group the dataset by subject and activity
dataset.tidy <- data.frame(summarise_each(subject.activity, funs(mean))) # compute the mean of each variable for each activity and subject and save the new data as a data frame

write.table(dataset.tidy, "tidy_dataset.txt", row.names = FALSE) # write the new the tidy dataset to the working directory

