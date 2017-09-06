# 0. Final assignment
## 1. Introduction

This file describes how the run analysis.R script works. The description is structured into seven main steps. Two of these steps are prerequisites. These prerequisites are:
* The required packages list
* Unzipping and reading the necessary files

There are also five steps that follow the steps outlined in the Coursera assignment instructions. These five steps are:
1. Merge the training and the test sets to create one data set.
1. Extract only the measurements on the mean and std for each measurement.
1. Uses descriptive activity names to name the activities in the data set
1. Appropriately label the data set with descriptive variable names.
1. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

Each of these will be described below.

## 2. Prerequisites

The required packages list uses `if` statements to check if packages are loaded and installed. If not, it loads them or installs them and then loads them. The use of `require` instead of `library` is because `library` throws an error and halts if package is not installed. By using `require` it is possible to move on and install any missing package and then load it.

run_analysis.R uses the following packages: plyr, dplyr, and shape2. It is important to load plyr before dplyr.

After packages are loaded, the data file is unzipped. Since I do now know what the zip file will be called in the assignment, I use `list.files` and use a pipe to run a `grep` that looks for files that end with .zip. The grep output is then passed on to the `unzip` function.

With the files unzipped, the script then creates a data.frame for each required file.

## 3. Five Coursera steps
### 3.1. Merging train and test
With the files loaded and ready, the first step is to merge the training and the test sets into one larger data set. Using pipes I chain the following operations:
* `rbind` to add the rows of the X_train.txt file to the X_test.txt file. NOTE ORDER!
* `cbind` with nested `rbind` to add column with data for activity from the y_train.txt and y_test.txt files. NOTE ORDER!
* `cbind` with nested `rbind` to add column with data for subject from the subject_train.txt and subject_test.txt files. NOTE ORDER!
The output from this step is: merged_data

### 3.2. Extracting mean and std
The script then continues by extracting feature names for measures of mean and std from the features.txt file. The resulting character vector is expanded with two additional elements: one for "subject" and one for "activity" (to account for the additional rows added in the previous step). `grepl` then creates a logical vector that is used to subset the merged_data data.frame created in previous step.
The output from this step is: extr_df

### 3.3. Name activities
The function `mapvalues` makes it easy to change numeric data in the activity column to something more descriptive. The script uses the activity_labels.txt file for its descriptive naming. Simply put, each numerical value is replaced with its corresponding word.
The output from this step is: extr_df with changes to [, 2], i.e., every row in the second column.

### 3.4. Label variables
I found the variable names in features.txt quite descriptive already. The file features_info.txt and the code book contain more info. Similar to the step above, the script here creates a character vector using the features.txt file (to which it adds "subject" and "activity"). It then passes this character vector as the column names of extr_df.

### 3.5. Tidy data
The script here generates two tidy data sets. One is wide. The other is narrow. The narrow one follows all the rules of tidy data. `group_by` arranges the rows in the columns first by subject number, then by activity. The `summarize_all` returns the mean values by group. The narrow data set uses `melt` to move the columns for features into rows. The narrow data set only has four variables: subject, activity, feature, value.
