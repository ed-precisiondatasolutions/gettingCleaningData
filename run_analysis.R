
## Movement data cleansing - data transformed from 'wide' to 'long'
## Only mean and std measurements included in final output
## Initial data - Total rows X data - train + test = 10299, Total columns (base) = 561
## Note: Can't use plyr > dplyr to select columns - not available for current r version on machine - 3.1.2

require(reshape)
require(sqldf)

#data file details
dpath <- file.path("~", "movement_data", "train") 
dpath2 <-  file.path("~", "movement_data", "test") 

#X data files - measurement & activity
dfile <- "X_train.txt"
dfile2 <- "X_test.txt"

#Subject files
sfile <- "subject_train.txt"
sfile2 <- "subject_test.txt"

#data headers from features
fpath <- file.path("~", "movement_data")
ffile <- "features.txt"

#Column headings              
cols <- c(readLines(paste(fpath,"/",ffile,sep="")))

#Load the X train data
xtemp <- read.table(paste(dpath,"/",dfile,sep=""), header=FALSE, col.names = cols, colClasses = "character")
#Load the X test data
xtemp2 <- read.table(paste(dpath2,"/",dfile2,sep=""), header=FALSE, col.names = cols, colClasses = "character")
#Row Bind data
fullx <- rbind(xtemp, xtemp2)

#Subject data
stemp <- read.table(paste(dpath,"/",sfile,sep=""), header=FALSE, col.names = "subject", colClasses = "numeric")
stemp2 <- read.table(paste(dpath2,"/",sfile2,sep=""), header=FALSE, col.names = "subject", colClasses = "numeric")
#Row Bind data
fullsubs <- rbind(stemp, stemp2)

#Column Bind Subjects to subset X data
fullsubsx <- cbind(fullsubs, fullx)
#Clean up column names
names(fullsubsx) <- sub("X[[:digit:]]*[[:punct:]]{1}", "", names(fullsubsx))

#Empty vector for column numbers required
v=NULL

cnames <- c("subject", "features", "measures", "activity")
cclasses <- c("numeric","character","numeric","numeric")

#Empty df for transposed data

subsetdf <- read.table(text = "",
                       colClasses = cclasses,
                       col.names = cnames)

#Loop through column names to get columns reqd.
for(i in colnames(fullsubsx))
{
   
    if(grepl("mean\\.", i)|grepl("Mean\\.", i))
    {

        vec <- fullsubsx[,i]
        splitdf <- data.frame(fullsubsx$subject, i, colsplit(vec, "-00", c(i,"id")))
        colnames(splitdf) <- cnames
        #Row Bind data
        subsetdf <- rbind(subsetdf, splitdf)
       
    
    } 
    else if(grepl("std", i)) { 
        
        vec <- fullsubsx[,i]
        splitdf <- data.frame(fullsubsx$subject, i, colsplit(vec, "-00", c(i,"id")))
        colnames(splitdf) <- cnames
        #Row Bind data
        subsetdf <- rbind(subsetdf, splitdf)
        
    } else {
       
       #Will generate warnings which can be ignored
        write.table(i,"~/xcolsremoved.txt",append = TRUE)
        
    }
    
}

#Decode activity codes
subsetdf$activity = as.character(subsetdf$activity)
subsetdf[subsetdf$activity == "1",]$activity = "WALKING"
subsetdf[subsetdf$activity == "2",]$activity = "WALKING_UPSTAIRS"
subsetdf[subsetdf$activity == "3",]$activity = "WALKING_DOWNSTAIRS"
subsetdf[subsetdf$activity == "4",]$activity = "SITTING"
subsetdf[subsetdf$activity == "5",]$activity = "STANDING"
subsetdf[subsetdf$activity == "6",]$activity = "LAYING"

#Final tidy report df
reportdf <- sqldf("select subject,activity,features, AVG(measures) 
                  from subsetdf where activity <> -1 group by subject,activity,features")

write.table(reportdf,"~/movementReport.txt",row.name=FALSE)
