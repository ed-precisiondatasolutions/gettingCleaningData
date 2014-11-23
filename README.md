Getting & Cleaning Data - Course Project
===================

This repo has been created to submit the Course Project for Getting and Cleaning Data.

Contents are:

- Code Book
- run_analysis.R script
- Tidy data file from script above

# Project Overview

Project required cleansing and reporting from designated data sets:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

This data was sourced from wearable tech and contained movement records from a group of subjects engaging into certain activities. Training and test data sets from the above location were merged in order to produce the final tidy output file.
For detailed information on the data sourced and actions performed by the run_analysis script refer to the Code Book included.

# run_analysis.R script

This single script will import the training and test data files from a movement_data dir below users home dir.
Sub dirs below the movement_data dir have been maintained as per the zip source > test, train and UCI HAR Dataset.

As per project instructions, only the average of the mean and std measurements are included in the final output file.
Within the script 'other' data is removed - the column headings of this data is written to the file - xcolsremoved.txt during execution.


