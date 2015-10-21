library(dplyr)
library(tidyr)
library(jsonlite)
library(tm)
library(nnet)
library(ggplot2)
library(caret)
library(rpart)
library(rpart.plot)
library(randomForest)
library(party)

test_url <- "https://www.kaggle.com/c/whats-cooking/download/test.json.zip"
train_url <- "https://www.kaggle.com/c/whats-cooking/download/train.json.zip"

if (!file.exists("test.json.zip")) {
  #download.file(test_url, "test.json.zip")
}
if (!file.exists("train.json.zip")) {
  #download.file(train_url, "train.json.zip")
}

unzip("train.json.zip")
unzip("test.json.zip")

#- load the JSON and convert to list
train <- fromJSON('train.json')
test <- fromJSON('test.json')

# Create Corpus from both train and test ingredients
text_source <- VectorSource(c(train$ingredients, test$ingredients))
corpus <- Corpus(text_source)

# Apply some transformations
corpus <- tm_map(corpus, stemDocument)
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, removeWords, c("green", "black"))
corpus <- tm_map(corpus, removePunctuation)

dtm <- DocumentTermMatrix(corpus)

dtm_sparse <- removeSparseTerms(dtm, 0.9)

train_ingredients <- as.data.frame(as.matrix(dtm_sparse)[1:nrow(train),])

#test_ingredients <- as.data.frame(as.matrix(dtm_sparse)[(nrow(train)+1):dtm$nrow,])

train_ingredients$cuisine <- as.factor(train$cuisine)

train_df <- tbl_df(train_ingredients)

# Divide trainning set into training and validation set
training_df <- slice(train_df, 1:floor(1+nrow(train_df)*0.8))
validate_df <- slice(train_df, floor(1+nrow(train_df)*0.8):nrow(train_df))

#mod <- multinom(cuisine ~ ., data = training_df)
#pred<-predict(mod,test_ingredients,"probs")

#pred<-predict(mod,select(validate_df, -cuisine),"probs")


#cuisine <- as.factor(train$cuisine)

#indices<-apply(pred, 1, which.max)
#hist(indices)

#compare<-data.frame(as.vector(cuisine[indices]))
#compare$true <- validate_df$cuisine
#names(compare) <-c('test', 'true')
#levels(compare$test)<-levels(validate_df$cuisine)
#nnCM <- confusionMatrix(compare$test, compare$true)
#nnCM
#compare<-mutate(compare, match = (test == true))

#score<-sum(compare$match)/nrow(compare)
#score

set.seed(9347)
cartModelFit <- rpart(cuisine ~ ., data = training_df, method = "class")
prp(cartModelFit)
cartPredict <- predict(cartModelFit, newdata = select(validate_df, -cuisine), type = "class")
cartCM <- confusionMatrix(cartPredict, validate_df$cuisine)
cartCM

rfModel <- randomForest(cuisine ~ ., data = training_df, ntree=2000, type =classification)
rfPredict <- predict(rfModel, newdata = select(validate_df, -cuisine), type = "class")
rfCM <- confusionMatrix(rfPredict, validate_df$cuisine)
rfCM

#submission<-data.frame(test$id)
#submission$cuisine <- as.vector(cuisine[indices])

#names(submission) <-c('id', 'cuisine')

#write.csv(submission, "submission.csv", row.names=FALSE)


