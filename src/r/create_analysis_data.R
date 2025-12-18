# Create minimal analysis dataset for publication
# Contains only variables used in the analyses

library(arrow)
library(dplyr)

# Load cleaned data
dat <- read_parquet("data/processed/cleaned_data.parquet")

# Select only variables used in analyses
analysis_data <- dat %>%
  select(
    # Identifiers
    ResponseId,

    # Political orientation and grouping
    politicalorientation_1,
    learner_party,
    political_extremism,

    # Pre-post belief accuracy
    accuracy_pre,
    accuracy_post,

    # Individual belief items (for composite scores)
    g1_own, g2_own, g3_own, g4_own, g5_own, g6_own,
    g1_ingroup, g2_ingroup, g3_ingroup, g4_ingroup, g5_ingroup, g6_ingroup,
    g1_outgroup_pre, g2_outgroup_pre, g3_outgroup_pre, g4_outgroup_pre, g5_outgroup_pre, g6_outgroup_pre,
    g1_outgroup_post, g2_outgroup_post, g3_outgroup_post, g4_outgroup_post, g5_outgroup_post, g6_outgroup_post,

    # Composite scores
    green_own,
    green_ingroup,
    green_outgroup_pre,
    green_outgroup_post,

    # Warmth measures
    warmth_outgroup_pre,
    warmth_ingroup_pre,
    warmth_outgroup_post,
    warmth_ingroup_post,
    warmth_diff_pre,
    warmth_diff_post,

    # Confidence measures
    confidence_ingroup,
    confidence_outgroup_pre,
    confidence_outgroup_post,

    # Bot perception measures
    info,
    empathy,

    # Engagement measures
    user_turn_count,
    user_word_count,
    has_conversation,

    # Applied judgment (slogans)
    slogan = Q23
  ) %>%

  # Derive participant_party from learner_party (avoiding redundancy)
  mutate(
    participant_party = case_when(
      learner_party == "D→R" ~ "Democrat",
      learner_party == "R→D" ~ "Republican",
      TRUE ~ NA_character_
    )
  )

# Save minimal dataset
write_parquet(analysis_data, "data/processed/analysis_data.parquet")

# Also save as CSV for broader accessibility
write.csv(analysis_data, "data/processed/analysis_data.csv", row.names = FALSE)

# Print summary
cat("Analysis dataset created successfully\n")
cat("Variables included:", ncol(analysis_data), "\n")
cat("Observations:", nrow(analysis_data), "\n")
cat("\nFiles saved:\n")
cat("  - data/processed/analysis_data.parquet\n")
cat("  - data/processed/analysis_data.csv\n")
