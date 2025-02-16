library(lightgbm)
library(rrBLUP)
library(caret)
library(readr)

x <- as.matrix(read.table("~/sv_impute.txt", header = F))  
y <- as.matrix(read.table("~/phe.txt", header = T))
colnames(x) <- as.character(seq_len(ncol(x)))


dtrain_full <- lgb.Dataset(data = as.matrix(x), label = y)
params <- list(objective = "regression", metric = "mse")
lgb_model_full <- lgb.train(params, dtrain_full)


importance_full <- lgb.importance(lgb_model_full, percentage = TRUE)
important_features <- importance_full[importance_full$Gain > 0, "Feature"]
important_features <- as.character(important_features$Feature)
filtered_x <- as.matrix( x[, important_features])


set.seed(123)
n_repeats <- 10
cor_results <- list() 


for (rep in 1:n_repeats) {
  # 生成新的交叉验证折
  folds <- createFolds(y, k = 10, list = TRUE, returnTrain = FALSE)
  cor_list <- c()  # 存储当前重复的相关系数 
  for (i in 1:10) {
	test_index <- folds[[i]]
	train_index <- setdiff(1:nrow(filtered_x), test_index)
	train_x <- as.matrix(filtered_x[train_index,])
	test_x <- as.matrix(filtered_x[test_index,])
	train_y <- y[train_index]
	test_y <- y[test_index]
		
	rrblup_model <- mixed.solve(train_y, Z = train_x)
	predicted_y <- test_x %*% rrblup_model$u

	cor_val <- cor(predicted_y, test_y)
	cor_list <- c(cor_list, cor_val)
  }
  cor_results[[rep]] <- cor_list
}

cor_results_df <- do.call(rbind, lapply(cor_results, function(x) data.frame(t(x))))
colnames(cor_results_df) <- paste0("Fold_", 1:10)
write.csv(cor_results_df, file = "repeated_cor_results.csv", row.names = FALSE)
