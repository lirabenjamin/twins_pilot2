# Analyze extreme cases: most and least accuracy improvement
# Show marketing messages and conversations

library(arrow)
library(dplyr)
library(jsonlite)

# Load data
dat <- read_parquet("data/processed/cleaned_data.parquet")

# Calculate accuracy improvement (negative = improvement)
dat <- dat %>%
  mutate(accuracy_improvement = accuracy_pre - accuracy_post)

# Find extreme cases by learner party
extreme_cases <- dat %>%
  group_by(learner_party) %>%
  arrange(desc(accuracy_improvement)) %>%
  slice(c(1, n())) %>%
  ungroup() %>%
  mutate(
    case_type = rep(c("Most Improved", "Least Improved"), 2)
  ) %>%
  select(ResponseId, learner_party, case_type,
         accuracy_pre, accuracy_post, accuracy_improvement,
         Q23)

# Print summary
cat("=" %>% rep(80) %>% paste(collapse = ""), "\n")
cat("EXTREME CASES: ACCURACY IMPROVEMENT\n")
cat("=" %>% rep(80) %>% paste(collapse = ""), "\n\n")

for (i in 1:nrow(extreme_cases)) {
  case <- extreme_cases[i, ]

  cat(sprintf("\n%s - %s\n", case$learner_party, case$case_type))
  cat(sprintf("ResponseId: %s\n", case$ResponseId))
  cat(sprintf("Accuracy Pre:  %.3f\n", case$accuracy_pre))
  cat(sprintf("Accuracy Post: %.3f\n", case$accuracy_post))
  cat(sprintf("Improvement:   %.3f %s\n",
              case$accuracy_improvement,
              ifelse(case$accuracy_improvement > 0, "(IMPROVED)", "(WORSENED)")))
  cat("\nMarketing Message:\n")
  cat(sprintf("\"%s\"\n",
              ifelse(is.na(case$Q23), "[No message provided]", case$Q23)))
  cat("-" %>% rep(80) %>% paste(collapse = ""), "\n")
}

# Load and display full conversations
cat("\n\n")
cat("=" %>% rep(80) %>% paste(collapse = ""), "\n")
cat("FULL CONVERSATIONS\n")
cat("=" %>% rep(80) %>% paste(collapse = ""), "\n\n")

for (i in 1:nrow(extreme_cases)) {
  case <- extreme_cases[i, ]

  cat(sprintf("\n\n### %s - %s ###\n", case$learner_party, case$case_type))
  cat(sprintf("ResponseId: %s\n", case$ResponseId))
  cat("=" %>% rep(80) %>% paste(collapse = ""), "\n\n")

  # Load conversation
  convo_file <- sprintf("data/processed/conversations/%s.json", case$ResponseId)

  if (file.exists(convo_file)) {
    convo <- fromJSON(convo_file)

    for (j in 1:nrow(convo)) {
      msg <- convo[j, ]

      # Format role
      role_display <- if(msg$role == "user") "USER" else "ASSISTANT"

      cat(sprintf("[%s]\n", role_display))
      cat(sprintf("%s\n\n", msg$content))

      if (j < nrow(convo)) {
        cat("---\n\n")
      }
    }
  } else {
    cat("Conversation file not found.\n")
  }

  cat("\n")
  cat("=" %>% rep(80) %>% paste(collapse = ""), "\n")
}

# Save extreme cases info
write.csv(extreme_cases, "output/extreme_cases.csv", row.names = FALSE)
cat("\n\nExtreme cases summary saved to output/extreme_cases.csv\n")
