library(dplyr)
library(tidyr)
library(jsonlite)

test_url <- "https://www.kaggle.com/c/whats-cooking/download/test.json.zip"
train_url <- "https://www.kaggle.com/c/whats-cooking/download/train.json.zip"

if (!file.exists("test.json.zip")) {
  download.file(test_url, "test.json.zip")
}
if (!file.exists("train.json.zip")) {
  download.file(train_url, "train.json.zip")
}

unzip("train.json.zip")
unzip("test.json.zip")

#- load the JSON and convert to list
#train <- fromJSON('../input/train.json')
#test <- fromJSON('../input/test.json')