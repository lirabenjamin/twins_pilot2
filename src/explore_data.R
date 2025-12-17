# Explore raw data structure
library(arrow)
library(dplyr)

# Load data
dat <- read_parquet("data/raw/qualtrics.parquet")

# Show structure
cat("Dimensions:", dim(dat), "\n")
cat("\nColumn names:\n")
names(dat) |> print()

# Show first few rows
cat("\nFirst few rows:\n")
head(dat) |> glimpse()
