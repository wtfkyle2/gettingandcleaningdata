## Set download URL and local file paths
downloadUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
downloadFolder <- "./download"
downloadFile <- paste(downloadFolder, "Dataset.zip", sep="/")
dataFolder <- "./UCI HAR Dataset"

## If the download folder does not exist, create it
if (!file.exists(downloadFolder)) {
  dir.create(downloadFolder)
}

## If the data set has not been downloaded, download it
if (!file.exists(downloadFile)) {
  download.file(downloadUrl, downloadFile)
}

## If the data set has not been unzipped, unzip it
if (!file.exists(dataFolder)) {
  unzip(downloadFile, exdir=".")
}

## Read in the training and testing data
## Subjects, activities and actual data

# Subjects
subTrain <- read.table(
  paste(dataFolder, "train/subject_train.txt", sep="/"), 
  header = FALSE
) 
subTest  <- read.table(
  paste(dataFolder, "test/subject_test.txt", sep="/"), 
  header = FALSE
)

## Activities
actTrain <- read.table(
  paste (dataFolder, "train/Y_train.txt", sep="/"),
  header = FALSE
) 
actTest  <- read.table(
  paste (dataFolder, "test/Y_test.txt", sep="/"), 
  header = FALSE
)
## Datas - These files are huge O_o
datTrain <- read.table(
  paste (dataFolder, "train/X_train.txt", sep="/"),
  header = FALSE
) 
datTest <- read.table(
  paste (dataFolder, "test/X_test.txt", sep="/"),
  header = FALSE
)

## Merge the sets
subM <- rbind(subTrain,subTest)
actM <- rbind(actTrain,actTest)
datM <- rbind(datTrain,datTest)

## Read activity labels and features
aVector <- read.table(
  paste (dataFolder, "activity_labels.txt", sep="/"),
  header = FALSE
)
fVector <- read.table(
  paste (dataFolder, "features.txt", sep="/"),
  header = FALSE
) 

## Set column names
colnames(aVector) <- c("Activity_code","Activity_str")
colnames(fVector) <- c("Feature_code","Feature_str")
colnames(datM) <- fVector$Feature_str

## Filter data
datM <- datM[,names(datM)[grep("mean\\(\\)|std\\(\\)", names(datM))]]

## Cleanup strings
colnames(datM) <- sub("\\(\\)", "Col", names(datM))

## Prepend subjectid and activity labels
datM <- cbind(SubjectId = subM[,1], ActivityLabel = actM[,1], datM)
datM$Activity <- apply (datM["ActivityLabel"],1,function(x) aVector[x,2])

## Set up our tidy data set mmkay
tDat <- aggregate(. ~ SubjectId + ActivityLabel, data=datM, mean)

## Write it all out
write.table(
  tDat, 
  paste(dataFolder, "tidy.txt", sep="/"),
  sep="\t",
  row.nameasdasd = FALSE,
  quote=T
)
