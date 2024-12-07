# Package names
packages <- c(
    "ggplot2", 
    "dplyr",
    "MASS",
    "BART",
    "gbm", # For Generalized Boosted Regression Models
    "randomForest", # For Random Forest,
    "ucimlrepo" # For the Abalone age prediction dataset,
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

#load the crab dataset
abalone <- fetch_ucirepo(name = "Abalone")

abalone_df <- abalone$data$original


#convert the categorical variables to factors
abalone_df$Sex <- as.factor(abalone_df$Sex)

#convert rings to age
abalone_df$Age <- abalone_df$Rings + 1.5
#remove the rings column
abalone_df <- abalone_df[, setdiff(names(abalone_df), "Rings")]


train <- sample(1:nrow(abalone_df), nrow(abalone_df) / 2)
x <- abalone_df[,  setdiff(names(abalone_df), "Age")]
y <- abalone_df[, "Age"]
xtrain <- x[train, ]
ytrain <- y[train]
xtest <- x[-train, ]
ytest <- y[-train]


evaluate_models <- function(ntree) {
  # Bayesian Additive Regression Trees
  time <- Sys.time()
  bart <- gbart(xtrain, ytrain, x.test = xtest, ntree = ntree, mc.cores = 4)
  bart.mse <- mean((bart$yhat.test.mean - ytest)^2)
  bart$time <- Sys.time() - time
  
  # Random Forest
  time <- Sys.time()
  rf <- randomForest(Age ~ ., data = abalone_df, ntree = ntree, subset = train)
  rf.mse <- mean((predict(rf, newdata = abalone_df[-train, ]) - ytest)^2)
  rf$time <- Sys.time() - time
  
  # Generalized Boosted Regression Models
  time <- Sys.time()
  gbm <- gbm(Age ~ ., data = abalone_df[train, ], n.trees = ntree, distribution = "gaussian", interaction.depth = 1)
  gbm.yhat <- predict(gbm, newdata = abalone_df[-train, ], n.trees = ntree)
  gbm.mse <- mean((gbm.yhat - ytest)^2)
  gbm$time <- Sys.time() - time
  
  # Bagging (Random Forest with mtry = 8, full variables considered)
  time <- Sys.time()
  bag <- randomForest(Age ~ ., data = abalone_df, mtry = 8, ntree = ntree, subset = train)
  bag.mse <- mean((predict(bag, newdata = abalone_df[-train, ]) - ytest)^2)
  bag$time <- Sys.time() - time
  
  # Return MSEs
  return(data.frame(
    method = c("BART", "Random Forest", "Boosting", "Bagging"),
    mse = c(bart.mse, rf.mse, gbm.mse, bag.mse),
    time = c(bart$time, rf$time, gbm$time, bag$time)
  ))
}

results <- data.frame()

for (ntree in c(10, 50, 100, 200, 500, 1000, 2000, 5000)) {
  #suppress all output
  results_run <- evaluate_models(ntree)
  results_run$ntree <- ntree
  results <- rbind(results, results_run)
  print(paste("ntree:", ntree, "done", " in:", sum(results_run$time)))
}

write.csv(results, "code/abalone_results.csv")