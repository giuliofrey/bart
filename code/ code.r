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
x <- Boston[, -14]
boston_df <- as.data.frame(Boston)
y <- Boston$medv

# Load an underspecified dataset
x_under <- Boston[, c(6, 13)]
y_under <- Boston$medv
boston_under_df <- as.data.frame(Boston[, c(6, 13, 14)])

nd <- 200 # The number of posterior draws
burn <- 50 # Number of MCMC iterations to be treated as burn in

#Bayesian Additive Regression Trees
bart <- wbart(x, y, nskip = burn, ndpost = nd, ntree = 1000)
bart.mse <- mean((bart$yhat.train.mean - y)^2)

#underspecified model
bart_under <- wbart(x_under, y_under, nskip = burn, ndpost = nd, ntree = 1000)
bart_under.mse <- mean((bart_under$yhat.train.mean - y_under)^2)

# Random Forest
rf <- randomForest(medv ~ ., data = boston_df, ntree = 1000)

# underspecified model
rf_under <- randomForest(medv ~ ., data = boston_under_df, ntree = 1000)

# Generalized Boosted Regression Models
gbm <- gbm(medv ~ ., data = boston_df, n.trees = 1000, distribution = "gaussian", interaction.depth = 1)

# underspecified model
gbm_under <- gbm(medv ~ ., data = boston_under_df, n.trees = 1000, distribution = "gaussian", interaction.depth = 1)

# Bagging (Random Forest with mtry = 12, full variables considered)
bag <- randomForest(medv ~ ., data = boston_df, mtry = 12, ntree = 1000)

#underspecified model
bag_under <- randomForest(medv ~ ., data = boston_under_df, mtry = 2, ntree = 1000)


valuation <- data.frame(
    method = c("BART", "Random Forest", "Boosting", "Bagging"),
    y_hat = c(mean(bart$yhat.train.mean), mean(rf$predicted), mean(gbm$fit), mean(bag$predicted)),
    mse = c(bart.mse, mean(rf$mse), mean(gbm$train.error), mean(bag$mse)),
    mse_under = c(bart_under.mse, mean(rf_under$mse), mean(gbm_under$train.error), mean(bag_under$mse))
)

print(valuation)
