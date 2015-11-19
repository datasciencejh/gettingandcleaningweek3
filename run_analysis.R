require("data.table")
require("reshape2")

#location of data file
url <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"


#if file not exists then download
if (! file.exists(".\\data\\dataset.zip" ))
{

  download.file(url,destfile = ".\\data\\dataset.zip")
  
  #unzip the datafile
  unzip(".\\data\\dataset.zip" , exdir =  ".\\data")
  
}
#activities
features <- read.table(".\\data\\UCI HAR Dataset\\features.txt")[,2]

#get only mean or  standard deviation feature
features_interest <- grepl("mean|std", features)

# read activities
activities <- read.table(".\\data\\UCI HAR Dataset\\activity_labels.txt")[,2]

#read test data 
X_test <- read.table(".\\data\\UCI HAR Dataset\\test\\X_test.txt")
y_test <- read.table(".\\data\\UCI HAR Dataset\\test\\y_test.txt")
subject_test <- read.table(".\\data\\UCI HAR Dataset\\test\\subject_test.txt")
names(X_test)=features
#now filter only interested parameters
X_test = X_test[,features_interest]

# Load activity labels
y_test[,2] = activities[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

#combine and get the final test data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)


# Load and process X_train & y_train data.
X_train <- read.table(".\\data\\UCI HAR Dataset\\train\\X_train.txt")
y_train <- read.table(".\\data\\UCI HAR Dataset\\train\\y_train.txt")
subject_train <- read.table(".\\data\\UCI HAR Dataset\\train\\subject_train.txt")
names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,features_interest]
y_train[,2] = activities[y_train[,1]]

names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

#combine and get the final train data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data using rbind
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)
#dcast and get the tidy data

tidydata   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
#finally write the result
write.table(tidydata, file = ".\\data\\UCI HAR Dataset\\tidydata.txt")