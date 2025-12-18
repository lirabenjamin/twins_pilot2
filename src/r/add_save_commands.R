# Script to add save commands to all figures and tables in report.qmd
# This script identifies ggplot figures and tables and adds appropriate save commands

library(tidyverse)

# Read the report file
report_lines <- readLines("analysis/report.qmd")

# Function to find chunks that create plots (ggplot calls)
# and add ggsave commands

# Track modifications
modifications <- list()

# For now, let's create a comprehensive list of all chunks that need save commands
# We'll output this as a reference

cat("Chunks that create ggplot objects:\n")
in_chunk <- FALSE
chunk_name <- NULL
chunk_start <- 0

for (i in seq_along(report_lines)) {
  line <- report_lines[i]

  if (grepl("^```\\{r", line)) {
    in_chunk <- TRUE
    chunk_start <- i
    # Extract chunk name if present
    chunk_name_match <- str_extract(line, "(?<=\\{r\\s)[^,}]+")
    chunk_name <- ifelse(is.na(chunk_name_match), "unnamed", chunk_name_match)
  } else if (grepl("^```$", line) && in_chunk) {
    in_chunk <- FALSE

    # Check if chunk contains ggplot
    chunk_lines <- report_lines[chunk_start:i]
    chunk_text <- paste(chunk_lines, collapse = "\n")

    if (grepl("ggplot\\(", chunk_text) && !grepl("ggsave\\(", chunk_text)) {
      cat(sprintf("Line %d: Chunk '%s' - contains ggplot without ggsave\n", chunk_start, chunk_name))
    }

    if (grepl("(modelsummary\\(|gt\\()", chunk_text) && !grepl("save_table\\(", chunk_text)) {
      cat(sprintf("Line %d: Chunk '%s' - contains table without save_table\n", chunk_start, chunk_name))
    }
  }
}
