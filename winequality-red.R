## Comparison Of Supervised Machine Learning Models To Predict Red Wine Quality ##

#Importing the dataset
data <- read.csv('winequality-red.csv', sep = ';')
str(data)

  #Format outcome variable
data$quality <- ifelse(data$quality >= 7, 1, 0)
data$quality <- factor(data$quality, levels = c(0, 1))

#EDA
#Descriptive statistics
summary(data)

#Univariate analysis
  #Dependent variable
    #Frequency plot
par(mfrow=c(1,1))
barplot(table(data[[12]]), 
        main = sprintf('Frequency plot of the variable: %s', 
                       colnames(data[12])),
        xlab = colnames(data[12]),
        ylab = 'Frequency')

    #Check class BIAS
table(data$quality)
round(prop.table((table(data$quality))),2)

  #Independent variable
    #Boxplots
par(mfrow=c(3,4))
for (i in 1:(length(data)-1)){
  boxplot(x = data[i], 
          horizontal = TRUE, 
          main = sprintf('Boxplot of the variable: %s', 
                         colnames(data[i])),
          xlab = colnames(data[i]))
}

    #Histograms
par(mfrow=c(3,4))
for (i in 1:(length(data)-1)){
  hist(x = data[[i]], 
       main = sprintf('Histogram of the variable: %s',
                    colnames(data[i])), 
       xlab = colnames(data[i]))
}

#Bivariate analysis
  #Correlation matrix
# install.packages('ggcorrplot')
library(ggcorrplot)
ggcorrplot(round(cor(data[-12]), 2), 
           type = "lower", 
           lab = TRUE, 
           title = 
             'Correlation matrix of the red wine quality dataset')

#DATA PREPARATION
#Missing values
sum(is.na(data))

#Outliers
  #Identifing outliers
is_outlier <- function(x) {
  return(x < quantile(x, 0.25) - 1.5 * IQR(x) | 
           x > quantile(x, 0.75) + 1.5 * IQR(x))
}

outlier <- data.frame(variable = character(), 
                      sum_outliers = integer(),
                      stringsAsFactors=FALSE)

for (j in 1:(length(data)-1)){
  variable <- colnames(data[j])
  for (i in data[j]){
    sum_outliers <- sum(is_outlier(i))
  }
  row <- data.frame(variable,sum_outliers)
  outlier <- rbind(outlier, row)
}

  #Identifying the percentage of outliers
for (i in 1:nrow(outlier)){
  if (outlier[i,2]/nrow(data) * 100 >= 5){
    print(paste(outlier[i,1], 
                '=', 
                round(outlier[i,2]/nrow(data) * 100, digits = 2),
                '%'))
  }
}

  #Inputting outlier values
for (i in 4:5){
  for (j in 1:nrow(data)){
    if (data[[j, i]] > as.numeric(quantile(data[[i]], 0.75) + 
                                  1.5 * IQR(data[[i]]))){
      if (i == 4){
        data[[j, i]] <- round(mean(data[[i]]), digits = 2)
      } else{
        data[[j, i]] <- round(mean(data[[i]]), digits = 3)
      }
    }
  }
}

#MODELING
#Splitting the dataset into the Training set and Test set
  #Stratified sample
data_ones <- data[which(data$quality == 1), ]
data_zeros <- data[which(data$quality == 0), ]

    #Train data
set.seed(123)
train_ones_rows <- sample(1:nrow(data_ones), 0.8*nrow(data_ones))
train_zeros_rows <- sample(1:nrow(data_zeros), 0.8*nrow(data_ones))
train_ones <- data_ones[train_ones_rows, ]  
train_zeros <- data_zeros[train_zeros_rows, ]
training_set <- rbind(train_ones, train_zeros)

table(training_set$quality)

    #Test Data
test_ones <- data_ones[-train_ones_rows, ]
test_zeros <- data_zeros[-train_zeros_rows, ]
test_set <- rbind(test_ones, test_zeros)

table(test_set$quality)

#Logistic Regression
lr = glm(formula = quality ~.,
         data = training_set,
         family = binomial)

  #Predictions
prob_pred = predict(lr, 
                    type = 'response', 
                    newdata = test_set[-12])

# install.packages('InformationValue')
library(InformationValue)
optCutOff <- optimalCutoff(test_set$quality, prob_pred)[1]

y_pred = ifelse(prob_pred > optCutOff, 1, 0)

  #Making the confusion matrix
cm_lr = table(test_set[, 12], y_pred)
cm_lr

  #Accuracy
accuracy_lr = (cm_lr[1,1] + cm_lr[2,2])/
  (cm_lr[1,1] + cm_lr[2,2] + cm_lr[2,1] + cm_lr[1,2])
accuracy_lr

  #ROC curve
# install.packages('ROSE')
library(ROSE)
par(mfrow = c(1, 1))
roc.curve(test_set$quality, y_pred)

#Decision Tree
# install.packages('rpart')
library(rpart)
dt = rpart(formula = quality ~ .,
           data = training_set,
           method = 'class')

  #Predictions
y_pred = predict(dt, 
                 type = 'class', 
                 newdata = test_set[-12])

  #Making the confusion matrix
cm_dt = table(test_set[, 12], y_pred)
cm_dt

  #Accuracy
accuracy_dt = (cm_dt[1,1] + cm_dt[2,2])/
  (cm_dt[1,1] + cm_dt[2,2] + cm_dt[2,1] + cm_dt[1,2])
accuracy_dt

  #ROC curve
library(ROSE)
roc.curve(test_set$quality, y_pred)

#Random forest
# install.packages('randomForest')
library(randomForest)
rf = randomForest(x = training_set[-12],
                  y = training_set$quality,
                  ntree = 10)

  #Predictions
y_pred = predict(rf, 
                 type = 'class', 
                 newdata = test_set[-12])

  #Making the confusion matrix
cm_rf = table(test_set[, 12], y_pred)
cm_rf

  #Accuracy
accuracy_rf = (cm_rf[1,1] + cm_rf[2,2])/
  (cm_rf[1,1] + cm_rf[2,2] + cm_rf[2,1] + cm_rf[1,2])
accuracy_rf

  #ROC curve
library(ROSE)
roc.curve(test_set$quality, y_pred)

#Variable importance
library(caret)
varImp(lr)


