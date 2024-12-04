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

# Load the Boston dataset and create a dataframe
x <- Boston[, c(6, 13)] 
boston_df <- as.data.frame(Boston[, c(6, 13)])
boston_df$medv <- Boston$medv
y <- Boston$medv

nd <- 200 # The number of posterior draws
burn <- 50 # Number of MCMC iterations to be treated as burn in

#Bayesian Additive Regression Trees
bart <- wbart(x, y, nskip = burn, ndpost = nd, ntree = 1000)
bart.mse <- mean((bart$yhat.train.mean - y)^2)

# Random Forest
rf <- randomForest(medv ~ ., data = boston_df, ntree = 1000)

# Generalized Boosted Regression Models
gbm <- gbm(medv ~ ., data = boston_df, n.trees = 1000, distribution = "gaussian", interaction.depth = 1)

# Bagging
bag <- randomForest(medv ~ ., data = boston_df, mtry = 2, ntree = 1000)


valuation <- data.frame(
    mse = c(bart.mse, mean(rf$mse), mean(gbm$train.error), mean(bag$mse)),
    method = c("BART", "Random Forest", "GBM", "Bagging")
)

print(mse_df)
