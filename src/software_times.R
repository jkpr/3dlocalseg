# Time numbers

start_time_str <- "08:10:57"
end_time_str <- "08:23:13"

#' Must be formatted as 13:14:34
get_time_diff <- function(start, end) {
    start_time <-strptime(start,format="%H:%M:%S")
    end_time <- strptime(end,format="%H:%M:%S")
    
    time_diff <- end_time - start_time
    as.numeric(time_diff, units="secs")
}

# Linear

train_start <- c("08:10:57","08:23:44","08:36:27","08:57:25",
                 "17:34:44","17:42:27","17:49:15","17:57:53",
                 "19:48:00","20:01:54","20:15:04","20:27:57")


train_end <- c("08:23:13","08:35:52","08:56:47","09:11:42",
               "17:42:08","17:48:59","17:57:32","18:05:05",
               "20:01:26","20:14:33","20:27:26","20:47:14")



test_start <- c("08:23:13","08:35:52","08:56:47","09:11:42",
                "17:42:08","17:48:59","17:57:32","18:05:05",
                "20:01:26","20:14:33","20:27:26","20:47:14")


test_end <- c("08:23:27","08:36:09","08:57:04","09:11:57",
              "17:42:18","17:49:07","17:57:43","18:05:14",
              "20:01:38","20:14:47","20:27:40","20:47:33")

train_times <- apply(cbind(train_start,train_end),1,function(x) get_time_diff(x[1],x[2]))

test_times <- apply(cbind(test_start,test_end),1,function(x) get_time_diff(x[1],x[2]))


# Spline

train_start <- c("14:53:01","15:33:18","16:09:02","16:47:17",
                 "17:33:23","17:58:18","18:14:01","18:31:53",
                 "17:36:24","18:04:19","18:32:10","18:58:10")


train_end <- c("15:32:49","16:08:28","16:46:41","17:25:27",
               "17:57:54","18:13:41","18:31:28","18:47:21",
               "18:03:17","18:31:08","18:57:13","19:22:26")



test_start <- c("15:32:49","16:08:28","16:46:41","17:25:27",
                "17:57:54","18:13:41","18:31:28","18:47:21",
                "18:03:17","18:31:08","18:57:13","19:22:26")


test_end <- c("15:33:02","16:08:45","16:46:59","17:25:40",
              "17:58:06","18:13:50","18:31:40","18:47:32",
              "18:03:43","18:31:31","18:57:36","19:22:47")

train_times <- apply(cbind(train_start,train_end),1,function(x) get_time_diff(x[1],x[2]))

test_times <- apply(cbind(test_start,test_end),1,function(x) get_time_diff(x[1],x[2]))

mean(train_times)/60
sd(train_times)/60
mean(test_times)
sd(test_times)


file_base <- "knn_arr_"
ext <- ".rda"
files <- paste0(file_base,1:80,ext)

out <- sapply(files, function(x){
    load(x)
    secs <- as.numeric(diff_time, units="secs")
    return(secs)
})

