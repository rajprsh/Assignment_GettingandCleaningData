## Initial Activities :  Pulling and reading the data
# Pulling the data
setwd("D:/CourseRa/Assignments/Getting and Cleaning Data")
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# unzipping the file

unzip(zipfile="./data/Dataset.zip",exdir="./data")
my_filepath <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(my_filepath, recursive=TRUE)

# reading the files
Test_Activity  <- read.table(file.path(my_filepath, "test" , "Y_test.txt" )header = FALSE)
Train_Activity <- read.table(file.path(my_filepath, "train", "Y_train.txt"),header = FALSE)
Train_Sub <- read.table(file.path(my_filepath, "train", "subject_train.txt"),header = FALSE)
Test_Sub  <- read.table(file.path(my_filepath, "test" , "subject_test.txt"),header = FALSE)
Test_Feat  <- read.table(file.path(my_filepath, "test" , "X_test.txt" ),header = FALSE)
Train_Feat <- read.table(file.path(my_filepath, "train", "X_train.txt"),header = FALSE)

## Assignment 1: Merges the training and the test sets to create one data set
# combining rows in the relevant tables
Sub_All <- rbind(Train_Sub, Test_Sub)
Act_All<- rbind(Train_Activity, Test_Activity)
Feat_All<- rbind(Train_Feat, Test_Feat)

# setting names to variables
names(Sub_All)<-c("subject")
names(Act_All)<- c("activity")
Feat_AllNames <- read.table(file.path(my_filepath, "features.txt"),header=FALSE)
names(Feat_All)<- Feat_AllNames$V2

# Create data frame by merging all columns
bind_sub_act <- cbind(Sub_All, Act_All)
All_Data <- cbind(Feat_All, bind_sub_act)

## Assignment 2 :  Extracts only the measurements on the mean and standard deviation for each measurement

# Two steps: separate features on mean and Std. deviation; separate data on these features. 

sub_AllNames<-Feat_AllNames$V2[grep("mean\\(\\)|std\\(\\)", Feat_AllNames$V2)]
Select_Names<-c(as.character(sub_AllNames), "subject", "activity" )
Data2<-subset(All_Data,select=Select_Names)

## Assignment 3 :  Uses descriptive activity names to name the activities in the data set

# Two steps: Identify descriptive activities from the data set ; use the same to identify variables in the data frame
activityLabels <- read.table(file.path(my_filepath, "activity_labels.txt"),header = FALSE)
All_Data$activity<-factor(All_Data$activity)
All_Data$activity<- factor(All_Data$activity,labels=as.character(activityLabels$V2))


## Assignment 4 :  Appropriately labels the data set with descriptive variable names

# relabeling Identified for (1)  Acc to be replaced by Accelerometer; (2) Gyro to be replaced by Gyroscope; (3) Mag to be replaced by Magnitude; (4) BodyBody to be replaced by Body; (5) prefix t and f to be replaced by Time and Frequency respectively 

names(Data2)<-gsub("^t", "Time", names(Data2))
names(Data2)<-gsub("^f", "Frequency", names(Data2))
names(Data2)<-gsub("Acc", "Accelerometer", names(Data2))
names(Data2)<-gsub("Gyro", "Gyroscope", names(Data2))
names(Data2)<-gsub("Mag", "Magnitude", names(Data2))
names(Data2)<-gsub("BodyBody", "Body", names(Data2))

## Assignment 5 :  Creates a second, independent tidy data set and output it

library(plyr);
Data3<-aggregate(.~subject + activity, Data2, mean)
Data3<-Data3[order(Data3$subject, Data2$activity),]
write.table(Data3, file = "Tidy_Data.txt",row.name=FALSE)
