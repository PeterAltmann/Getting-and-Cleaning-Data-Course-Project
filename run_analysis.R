#Check if dir for data exists, create if not.
if(!dir.exists(paste(getwd(), "/Data", sep = ""))){
        dir.create("./Data")
}
setwd(paste(getwd(), "/Data", sep = ""))

#download.file with method = "curl" did not work for link. This package works.
if(!require(downloader)){
        install.packages("downloader")
        library(downloader)
}

#the readr package is good for loading the data into list
if(!require(readr)){
        install.packages("readr")
        library(readr)
}

#The dplyr package is just so nice :)
if(!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}

#This part downloads the necessary data file.
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest <- getwd()
download(fileUrl, dest, mode = "wb")

#Unzip and load relevant files
unzip("S4data.zip")
xtestf <- "./UCI HAR Dataset/test/X_test.txt"
xtrainf <- "./UCI HAR Dataset/train/X_train.txt"
featuresf <- "./UCI HAR Dataset/features.txt"
activitylabelsf <- "./UCI HAR Dataset/activity_labels.txt"
testsubjectf <- "./UCI HAR Dataset/test/subject_test.txt"
trainsubjectf <- "./UCI HAR Dataset/train/subject_train.txt"
ytestf <- "./UCI HAR Dataset/test/y_test.txt"
ytrainf <- "./UCI HAR Dataset/train/y_train.txt"

#create a tibble for each file
x_test <- tbl_df(read.csv(xtestf, sep = "", header = FALSE))
x_train <- tbl_df(read.csv(xtrainf, sep = "", header = FALSE))
features_tbl <- tbl_df(read.csv(featuresf, sep = "", header = FALSE))
activity_labels <- tbl_df(read.csv(activitylabelsf, sep = "", header = FALSE))
test_subject <- tbl_df(read.csv(testsubjectf, sep = "", header = FALSE))
train_subject <- tbl_df(read.csv(trainsubjectf, sep = "", header = FALSE))
y_test <- tbl_df(read.csv(ytestf, sep = "", header = FALSE))
y_train <- tbl_df(read.csv(ytrainf, sep = "", header = FALSE))

#create a tibble for subject and activity data

subject_activity_test <- cbind(test_subject, y_test, x_test)
subject_activity_train <- cbind(train_subject, y_train, x_train)

#create a vector containing the column names and pass it to the two tibbles
column_names <- c("subject", "activity", as.character(features_tbl[[2]]))
colnames(subject_activity_test) <- column_names
colnames(subject_activity_train) <- column_names

#create subsetting vector for specified measures
subsetting_vector <- grepl("^activity|^subject|mean|std", column_names,
                           ignore.case = TRUE)

#I remove columns first (too save object.size) and then combine the tibbles
subject_activity_test_sub <- subject_activity_test[, subsetting_vector]
subject_activity_train_sub <- subject_activity_train[, subsetting_vector]
untidy_data <- rbind(subject_activity_test_sub, subject_activity_train_sub)
tidy_data <- summarize_all(group_by(untidy_data, "subject", "activity"), mean)
