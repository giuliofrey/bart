# Package names
packages <- c(
    "ggplot2", 
    "dplyr",
    "tree",
    "xtable",
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

# Settting the Warning message:
Continuous x aesthetic
ℹ did you forget `aes(group = ...)`? seed
set.seed(123)


# simulate data from sin function
x <- seq(0, 10, length.out = 1000)
y <- 2*sin(x) + x + rnorm(1000, 0, 1)

train <- sample(1:1000, 500)
xtrain <- x[train]
ytrain <- y[train]
xtest <- x[-train]
ytest <- y[-train]

# fit a bart model
bart_sin <- gbart(xtrain, ytrain, x.test = xtest)
# fit a tree model
tree_sin <- tree(ytrain ~ xtrain)
print(summary(tree_sin))

plot_data <- data.frame(xtest, ytest, yhat_mean = bart_sin$yhat.test.mean)
plot_data$true_function <- 2 * sin(xtest) + xtest
plot_data$lower_quantile <- apply(bart_sin$yhat.test, 2, quantile, probs = 0.025)
plot_data$upper_quantile <- apply(bart_sin$yhat.test, 2, quantile, probs = 0.975)

plot_sin <- ggplot(plot_data, aes(x = xtest, y = ytest)) +
  geom_point(aes(color = "Observed Data"), color = "black") +
  geom_line(aes(y = yhat_mean, color = "BART Prediction")) +
  geom_line(aes(y = true_function, color = "True Function"), linetype = "dashed") +
  geom_ribbon(aes(ymin = lower_quantile, ymax = upper_quantile, fill = "95% CI"), alpha = 0.2) +
  labs(title = "BART vs. True Function",
       x = "x",
       y = "2sin(x) + x",
       color = "Legend",
       fill = "Legend") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("outputs/sin_plot.pdf", plot_sin, width = 6, height = 4)



plot_sigma <- ggplot(data = data.frame(samples = 1:1100, sigma = bart_sin$sigma), aes(x = samples, y = sigma)) +
  geom_line() +
  geom_vline(xintercept = 100, color = "red", linetype = "solid", size = 1) +
  labs(title = "Estimated Sigma vs. Samples",
       x = "Samples",
       y = "Sigma") +
  theme_minimal()

ggsave("outputs/sigma_plot.pdf", plot_sigma, width = 6, height = 4)

small <- sample(1:1000, 200)
xsmall <- x[small]
ysmall <- y[small]
train_small <- sample(1:200, 100)
xtrain_small <- xsmall[train_small]
ytrain_small <- ysmall[train_small]
xtest_small <- xsmall[-train_small]
ytest_small <- ysmall[-train_small]

bart_sig_s1 <- gbart(xtrain_small, ytrain_small, x.test = xtest_small, sigest = 100)
bart_sig_s2 <- gbart(xtrain_small, ytrain_small, x.test = xtest_small, sigest = 1)
bart_sig_s3 <- gbart(xtrain_small, ytrain_small, x.test = xtest_small, sigest = 0.001)

plot_diff_sigma <- ggplot(data = data.frame(xtest_small, ytest_small), aes(x = xtest_small, y = ytest_small)) +
  geom_point() +  
  geom_line(aes(x = xtest_small, y = bart_sig_s1$yhat.test.mean, color = "Sigma = 100")) +
  geom_line(aes(x = xtest_small, y = bart_sig_s2$yhat.test.mean, color = "Sigma = 1")) +
  geom_line(aes(x = xtest_small, y = bart_sig_s3$yhat.test.mean, color = "Sigma = 0.001")) +
  labs(title = "BART with Different Sigma Estimates",
       x = "x",
       y = "2sin(x)+x",
       color = "Sigma Estimate") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("outputs/sin_plot_diff_sigma.pdf", plot_diff_sigma, width = 6, height = 4)


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


bart <- gbart(xtrain, ytrain, x.test = xtest, ntree = 500, mc.cores = 4)
bart.mse <- mean((bart$yhat.test.mean - ytest)^2)

ii <- order(bart$yhat.train.mean)

plot_data <- data.frame(
  ordered_obs = 1:length(ii),
  posterior_mean = bart$yhat.train.mean[ii],
  actual_y = ytrain[ii]
)

plot_posterior <- ggplot(plot_data, aes(x = ordered_obs)) +
  geom_boxplot(aes(y = bart$yhat.train[, ii]), outlier.shape = NA) +
  geom_point(aes(y = actual_y), color = "red", size = 0.5) +
  labs(
    title = "Posterior Predictions of BART Model on Training Data",
    x = "Ordered Training Observations",
    y = "Posterior Predictions"
  ) +
  theme_minimal() +
  theme(legend.position = "top")

ggsave("outputs/posterior_predictions_plot.pdf", plot_posterior, width = 6, height = 4)


# Evaluate models for a given number of trees

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

df_100 <- evaluate_models(1000)
print(xtable(df_100), type = "latex", file = "outputs/results_100.tex")

run_results <- FALSE

if (run_results) {
  results <- data.frame()
  
  for (ntree in c(10, 50, 100, 200, 500, 1000, 2000, 5000)) {
    #suppress all output
    results_run <- evaluate_models(ntree)
    results_run$ntree <- ntree
    results <- rbind(results, results_run)
    print(paste("ntree:", ntree, "done", " in:", sum(results_run$time)))
  }
  
  write.csv(results, "outputs/abalone_results.csv")
}

# simple regression tree
tree_reg <- tree(Age ~ ., data = abalone_df[train, ])
summary(tree_reg)