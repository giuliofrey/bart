# Package names
packages <- c(
    "ggplot2", 
    "dplyr",
    "MASS",
    "BART",
    "gbm", # For Generalized Boosted Regression Models
    "randomForest" # For Random Forest
)
# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE, warn.conflicts = FALSE))

# Settting the seed
set.seed(123)

# Load the full Boston dataset and create a dataframe
train <- sample(1:nrow(Boston), nrow(Boston) / 2)
boston_df <- as.data.frame(Boston)
x <- Boston[, 1:12]
y <- Boston[, "medv"]
xtrain <- x[train, ]
ytrain <- y[train]
xtest <- x[-train, ]
ytest <- y[-train]

# Load an underspecified dataset
boston_under_df <- as.data.frame(Boston[, c(6, 13, 14)])
train_under <- sample(1:nrow(boston_under_df), nrow(boston_under_df) / 2)
x_under <- Boston[, c(6, 13)]
y_under <- Boston[, "medv"]
xtrain_under <- x_under[train_under, ]
ytrain_under <- y_under[train_under]
xtest_under <- x_under[-train_under, ]
ytest_under <- y_under[-train_under]

nd <- 200 # The number of posterior draws
burn <- 50 # Number of MCMC iterations to be treated as burn in

#Bayesian Additive Regression Trees
bart <- gbart(xtrain, ytrain, x.test = xtest)
bart.mse <- mean((bart$yhat.test.mean - y)^2)

#underspecified model
bart_under <- wbart(xtrain_under, ytrain_under, x.test = xtest_under)
bart_under.mse <- mean((bart_under$yhat.test.mean - y)^2)

# Random Forest
rf <- randomForest(medv ~ ., data = boston_df, ntree = 1000, subset = train)
rf.mse >- mean((rf$predicted - y)^2)

# underspecified model
rf_under <- randomForest(medv ~ ., data = boston_under_df, ntree = 1000, subset = train)

# TODO: Calculate the MSE
# Generalized Boosted Regression Models
gbm <- gbm(medv ~ ., data = Boston[train, ], n.trees = 1000, distribution = "gaussian", interaction.depth = 1)
gbm.yhat <- predict(gbm, newdata = Boston[-train, ], n.trees = 1000)
mean((gbm.yhat - boston.test)^2)


# underspecified model
gbm_under <- gbm(medv ~ ., data = Boston[train_under, ], n.trees = 1000, distribution = "gaussian", interaction.depth = 1)
gbm_under.yhat <- predict(gbm, newdata = Boston[-train_under, ], n.trees = 1000)

# Bagging (Random Forest with mtry = 12, full variables considered)
bag <- randomForest(medv ~ ., data = boston_df, mtry = 12, ntree = 1000, subset=train)

#underspecified model
bag_under <- randomForest(medv ~ ., data = boston_under_df, mtry = 2, ntree = 1000, subset=train)

#calculate the MSE




valuation <- data.frame(
    method = c("BART", "Random Forest", "Boosting", "Bagging"),
    y_hat = c(mean(bart$yhat.train.mean), mean(rf$predicted), mean(gbm$fit), mean(bag$predicted)),
    mse = c(bart.mse, mean(rf$mse), mean(gbm$train.error), mean(bag$mse)),
    mse_under = c(bart_under.mse, mean(rf_under$mse), mean(gbm_under$train.error), mean(bag_under$mse))
)

print(valuation)
