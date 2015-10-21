library(dplyr)
library(tidyr)
library(jsonlite)
library(tm)
library(nnet)
library(ggplot2)

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
train <- fromJSON('train.json')
test <- fromJSON('test.json')

# Create Corpus from both train and test ingredients
text_source <- VectorSource(c(train$ingredients, test$ingredients))
corpus <- Corpus(text_source)

dtm <- DocumentTermMatrix(corpus)
dtm_sparse <- removeSparseTerms(dtm, 0.9)
train_ingredients <- as.data.frame(as.matrix(dtm_sparse)[1:nrow(train),])

test_ingredients <- as.data.frame(as.matrix(dtm_sparse)[(nrow(train)+1):dtm$nrow,])

train_ingredients$cuisine <- as.factor(train$cuisine)

mod <- multinom(cuisine ~ ., data = train_ingredients)

pred<-predict(mod,test_ingredients,"probs")

cuisine <- as.factor(train$cuisine)

indices<-apply(pred, 1, which.max)
hist(indices)

submission<-data.frame(test$id)
submission$cuisine <- as.vector(cuisine[indices])

names(submission) <-c('id', 'cuisine')
write.csv(submission, "submission.csv", row.names=FALSE)


