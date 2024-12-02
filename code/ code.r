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
invisible(lapply(packages, library, character.only = TRUE))

# Settting the seed
set.seed(123)

x <- Boston[, c(6, 13)] 

dim(x)

y <- Boston$medv

nd <- 200 # The number of posterior draws
burn <- 50 # Number of MCMC iterations to be treated as burn in


bart <- wbart(x, y, nskip = burn, ndpost = nd, ntree = 1000)
bart.mse <- mean((bart$yhat.train.mean - y)^2)

rf <- randomForest(x, y, ntree = 1000)


# TODO understand the structure of the gbm object and why works only with data frame
gbm <- gbm(medv ~ ., data = Boston, n.trees = 1000, distribution = "gaussian", interaction.depth = 1)

#TODO implement bagging

mse_df <- data.frame(
    mse = c(bart.mse, mean(rf$mse), mean(gbm$train.error)),
    method = c("BART", "Random Forest", "GBM")
)

print(mse_df)
