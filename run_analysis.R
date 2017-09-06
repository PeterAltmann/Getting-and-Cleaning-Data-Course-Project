#requires packages
if(!require(plyr)){
        install.packages("plyr")
        library(plyr)
}

if(!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}

if(!require(reshape2)){
        install.packages("reshape2")
        library(reshape2)
}

#Unzip and load relevant files into data frames
list.files() %>% 
        grep("*.zip$", ., value=TRUE) %>%
        unzip

x_test <- "./UCI HAR Dataset/test/X_test.txt" %>% 
        read.csv(sep = "", header = FALSE) %>% 
        tbl_df()

x_train <- "./UCI HAR Dataset/train/X_train.txt" %>% 
        read.csv(sep = "", header = FALSE) %>% 
        tbl_df()

features_tbl <- "./UCI HAR Dataset/features.txt" %>% 
        read.csv(sep = "", header = FALSE) %>% 
        tbl_df()

activity_labels <- "./UCI HAR Dataset/activity_labels.txt" %>% 
        read.csv(sep = "", header = FALSE) %>% 
        tbl_df()

subject_test <- "./UCI HAR Dataset/test/subject_test.txt" %>% 
        read.csv(sep = "", header = FALSE) %>% 
        tbl_df()

subject_train <- "./UCI HAR Dataset/train/subject_train.txt" %>% 
        read.csv(sep = "", header = FALSE) %>% 
        tbl_df()
y_test <- "./UCI HAR Dataset/test/y_test.txt" %>% 
        read.csv(sep = "", header = FALSE) %>% 
        tbl_df()

y_train <- "./UCI HAR Dataset/train/y_train.txt" %>% 
        read.csv(sep = "", header = FALSE) %>% 
        tbl_df()

#FROM HERE ON THE SCRIPT FOLLOWS THE ASSIGNMENT STEPS
#1. Merges the training and the test sets to create one data set.
merged_data <- rbind(x_train, x_test) %>% 
        cbind(rbind(y_train, y_test), .) %>%
        cbind(rbind(subject_train, subject_test), .)

#2. Extracts only the measurements on the mean and std for each measurement.
extr_df <- as.character(features_tbl[[2]]) %>% 
        c("subject", "activity", .) %>%
        grepl("^activity|^subject|mean|std", ., ignore.case = TRUE) %>%
        merged_data[, .]

#3. Uses descriptive activity names to name the activities in the data set
extr_df[, 2] <- extr_df[, 2] %>%
        mapvalues(from = 1:6, to = as.character(activity_labels[[2]][1:6]))
        
#4. Appropriately labels the data set with descriptive variable names.
colnames(extr_df) <- 
        as.character(features_tbl[[2]]) %>%
        grepl("mean|std", ., ignore.case = TRUE) %>%
        as.character(features_tbl[[2]])[.] %>%
        c("subject", "activity", .)

#5. From the data set in step 4, creates a second, independent tidy data set
#with the average of each variable for each activity and each subject.
#n.b. the script creates two tidy files, one wide and one narrow
tidy_data_wide <- extr_df %>%
        group_by(subject, activity) %>%
        summarize_all(mean)

tidy_data_narrow <- tidy_data_wide %>%
        melt(id = c("subject", "activity"), variable.name = "feature") %>% 
        arrange(subject, activity)

#write file output
write.table(tidy_data_narrow, file = "datafile.txt", row.name = FALSE)
