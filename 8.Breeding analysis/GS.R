library(lightgbm)
library(rrBLUP)
library(caret)
library(readr)

x <- as.matrix(read.table("~sv.txt", header = T))
y <- as.matrix(read.table("~phe.txt", header = T)) 
colnames(x) <- as.character(seq_len(ncol(x)))

set.seed(123)
n_repeats <- 10
cor_results <- list()

for (rep in 1:n_repeats) {
  
  folds <- createFolds(y, k = 10, list = TRUE)
  cor_list <- c()  
  
  for (i in 1:10) {
    test_index <- folds[[i]]
    train_index <- setdiff(1:nrow(x), test_index)
    
    train_x <- as.matrix(x[train_index, , drop = FALSE])
    test_x <- as.matrix(x[test_index, , drop = FALSE])
    train_y <- as.matrix(y[train_index])
    test_y <- as.matrix(y[test_index])
   	
    dtrain <- lgb.Dataset(data = train_x, label = train_y)
    params <- list(objective = "regression", metric = "mse")
    lgb_model <- lgb.train(params, dtrain)
        
    importance <- lgb.importance(lgb_model, percentage = TRUE)
    important_features <- as.character(importance$Feature[importance$Gain > 0])
        
    train_x_filtered <- as.matrix(train_x[, important_features, drop = FALSE])
    test_x_filtered <- as.matrix(test_x[, important_features, drop = FALSE])
    
    #mode(train_x_filtered) <- "numeric"
    #mode(test_x_filtered) <- "numeric"
    rrblup_model <- mixed.solve(train_y, Z = train_x_filtered)
    predicted_y <- test_x_filtered %*% rrblup_model$u
    
    cor_val <- cor(predicted_y, test_y)
    cor_list <- c(cor_list, cor_val)
  }
  
  cor_results[[rep]] <- cor_list
}

cor_results_df <- do.call(rbind, lapply(cor_results, function(x) data.frame(t(x))))
colnames(cor_results_df) <- paste0("Fold_", 1:10)
write.csv(cor_results_df, file = "repeated_cor_results.csv", row.names = FALSE)
