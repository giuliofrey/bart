library(ggplot2)

# import the data
data <- read.csv("outputs/abalone_results.csv")

mse_plot <- ggplot(data, aes(x = ntree, y = mse, color = method)) +
  geom_line() +
  geom_point() +
  labs(title = "MSE vs. Number of Trees",
       x = "Number of Trees",
       y = "Mean Squared Error",
       color = "Method"
       ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_color_manual(values = c("red", "blue", "green", "purple"))



time_plot <-ggplot(data, aes(x = ntree, y = time, color = method)) +
  geom_line() +
  geom_point() +
  labs(title = "Time vs. Number of Trees",
       x = "Number of Trees",
       y = "Time (s)",
       color = "Method") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_color_manual(values = c("red", "blue", "green", "purple"))

#save the plots
ggsave("outputs/mse_plot.pdf", mse_plot, width = 6, height = 4)
ggsave("outputs/time_plot.pdf", time_plot, width = 6, height = 4)