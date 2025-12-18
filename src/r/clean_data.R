# Data cleaning script
# Recodes Republican/Democrat variables to ingroup/outgroup based on participant's political orientation

library(arrow)
library(dplyr)
library(tidyr)

# Load raw data
dat <- read_parquet("data/raw/qualtrics.parquet")

# Clean data
clean_dat <- dat %>%
  # Determine participant's party based on political orientation
  # Values < 50 = Democrat, >= 50 = Republican
  filter(Status == "IP Address") %>%
  mutate(
    participant_party = case_when(
      politicalorientation_1 < 50 ~ "Democrat",
      politicalorientation_1 >= 50 ~ "Republican",
      TRUE ~ NA_character_
    )
  ) %>%

  # Recode pre-treatment belief variables (g1-g6)
  # _1 = own opinion, _2 = republican, _3 = democrat
  mutate(
    # For Democrats: ingroup = democrat (_3), outgroup = republican (_2)
    # For Republicans: ingroup = republican (_2), outgroup = democrat (_3)
    across(starts_with("g") & matches("_[123]$"),
           ~case_when(
             grepl("_1$", cur_column()) ~ .,  # Keep own opinion as is
             grepl("_2$", cur_column()) & participant_party == "Republican" ~ .,  # Republican is ingroup for Republicans
             grepl("_3$", cur_column()) & participant_party == "Democrat" ~ .,    # Democrat is ingroup for Democrats
             TRUE ~ .
           ),
           .names = "{.col}_temp")
  ) %>%

  # Create properly named ingroup/outgroup variables
  mutate(
    # Own beliefs (always _1)
    g1_own = g1_1,
    g2_own = g2_1,
    g3_own = g3_1,
    g4_own = g4_1,
    g5_own = g5_1,
    g6_own = g6_1,

    # Ingroup beliefs
    g1_ingroup = if_else(participant_party == "Republican", g1_2, g1_3),
    g2_ingroup = if_else(participant_party == "Republican", g2_2, g2_3),
    g3_ingroup = if_else(participant_party == "Republican", g3_2, g3_3),
    g4_ingroup = if_else(participant_party == "Republican", g4_2, g4_3),
    g5_ingroup = if_else(participant_party == "Republican", g5_2, g5_3),
    g6_ingroup = if_else(participant_party == "Republican", g6_2, g6_3),

    # Outgroup beliefs (pre-interaction)
    g1_outgroup_pre = if_else(participant_party == "Republican", g1_3, g1_2),
    g2_outgroup_pre = if_else(participant_party == "Republican", g2_3, g2_2),
    g3_outgroup_pre = if_else(participant_party == "Republican", g3_3, g3_2),
    g4_outgroup_pre = if_else(participant_party == "Republican", g4_3, g4_2),
    g5_outgroup_pre = if_else(participant_party == "Republican", g5_3, g5_2),
    g6_outgroup_pre = if_else(participant_party == "Republican", g6_3, g6_2),

    # Post-interaction outgroup beliefs (post_1 through post_6 are already about outgroup)
    g1_outgroup_post = post_1,
    g2_outgroup_post = post_2,
    g3_outgroup_post = post_3,
    g4_outgroup_post = post_4,
    g5_outgroup_post = post_5,
    g6_outgroup_post = post_6
  ) %>%

  # Recode warmth variables
  mutate(
    # Pre-warmth: warmth_pre_1 is outgroup, warmth_pre_2 is ingroup (based on codebook)
    warmth_outgroup_pre = warmth_pre_1,
    warmth_ingroup_pre = warmth_pre_2,

    # Post-warmth: warmth_post_1 is outgroup, warmth_post_2 is ingroup
    warmth_outgroup_post = warmth_post_1,
    warmth_ingroup_post = warmth_post_2
  ) %>%

  # Recode confidence variables
  mutate(
    confidence_ingroup = confidence_in1,
    confidence_outgroup_pre = confidence_out1,
    confidence_outgroup_post = confidence_out2
  ) %>%

  # Create learner_party variable (D→R or R→D)
  mutate(
    learner_party = case_when(
      participant_party == "Democrat" ~ "D→R",
      participant_party == "Republican" ~ "R→D",
      TRUE ~ NA_character_
    )
  ) %>%

  # Convert Likert responses to numeric
  mutate(
    across(c(starts_with("g") & ends_with(c("_own", "_ingroup", "_outgroup_pre", "_outgroup_post"))),
           ~case_when(
             . == "Disagree strongly" ~ 1,
             . == "Disagree a little" ~ 2,
             . == "Neither agree nor disagree" ~ 3,
             . == "Agree a little" ~ 4,
             . == "Agree strongly" ~ 5,
             TRUE ~ NA_real_
           ))
  ) %>%

  # Convert confidence to numeric
  mutate(
    across(starts_with("confidence_"),
           ~case_when(
             . == "Not at all confident" ~ 1,
             . == "Slightly confident" ~ 2,
             . == "Moderately confident" ~ 3,
             . == "Very confident" ~ 4,
             . == "Extremely confident" ~ 5,
             TRUE ~ NA_real_
           ))
  ) %>%

  # Convert bot perception ratings to numeric
  mutate(
    info = case_when(
      info == "Not at all informative" ~ 1,
      info == "Slightly informative" ~ 2,
      info == "Moderately informative" ~ 3,
      info == "Very informative" ~ 4,
      info == "Extremely informative" ~ 5,
      TRUE ~ NA_real_
    ),
    empathy = case_when(
      empathy == "Not at all empathic" ~ 1,
      empathy == "Slightly empathic" ~ 2,
      empathy == "Moderately empathic" ~ 3,
      empathy == "Very empathic" ~ 4,
      empathy == "Extremely empathic" ~ 5,
      TRUE ~ NA_real_
    )
  ) %>%

  # Create composite scores (mean of 6 items)
  rowwise() %>%
  mutate(
    # Own environmental attitudes composite
    green_own = mean(c(g1_own, g2_own, g3_own, g4_own, g5_own, g6_own), na.rm = TRUE),

    # Ingroup environmental attitudes composite
    green_ingroup = mean(c(g1_ingroup, g2_ingroup, g3_ingroup, g4_ingroup, g5_ingroup, g6_ingroup), na.rm = TRUE),

    # Outgroup environmental attitudes composite (pre)
    green_outgroup_pre = mean(c(g1_outgroup_pre, g2_outgroup_pre, g3_outgroup_pre, g4_outgroup_pre, g5_outgroup_pre, g6_outgroup_pre), na.rm = TRUE),

    # Outgroup environmental attitudes composite (post)
    green_outgroup_post = mean(c(g1_outgroup_post, g2_outgroup_post, g3_outgroup_post, g4_outgroup_post, g5_outgroup_post, g6_outgroup_post), na.rm = TRUE)
  ) %>%
  ungroup() %>%

  # Create warmth difference scores (outgroup - ingroup)
  mutate(
    warmth_diff_pre = warmth_outgroup_pre - warmth_ingroup_pre,
    warmth_diff_post = warmth_outgroup_post - warmth_ingroup_post
  ) %>%

  # Create political extremism variable (distance from midpoint)
  mutate(
    political_extremism = abs(politicalorientation_1 - 50)
  )

# Calculate actual outgroup attitudes for accuracy computation
actual_outgroup_attitudes <- clean_dat %>%
  group_by(participant_party) %>%
  summarise(
    actual_green = mean(green_own, na.rm = TRUE),
    .groups = "drop"
  )

# Add accuracy measures to cleaned data
clean_dat <- clean_dat %>%
  mutate(
    outgroup_party = if_else(participant_party == "Democrat", "Republican", "Democrat")
  ) %>%
  left_join(
    actual_outgroup_attitudes,
    by = c("outgroup_party" = "participant_party"),
    suffix = c("", "_actual")
  ) %>%
  mutate(
    # Compute negative absolute error (higher = more accurate)
    accuracy_pre = -abs(green_outgroup_pre - actual_green),
    accuracy_post = -abs(green_outgroup_post - actual_green)
  )

# Merge conversation metrics if available
conversation_metrics_file <- "data/processed/conversation_metrics.parquet"
if (file.exists(conversation_metrics_file)) {
  conversation_metrics <- read_parquet(conversation_metrics_file)
  clean_dat <- clean_dat %>%
    left_join(conversation_metrics, by = "ResponseId")
  cat("Conversation metrics merged successfully\n")
} else {
  cat("No conversation metrics found. Run src/python/download_conversations.py first.\n")
}

# Write cleaned data
write_parquet(clean_dat, "data/processed/cleaned_data.parquet")

# Return summary
cat("Cleaned data saved to data/processed/cleaned_data.parquet\n")
cat("Sample size:", nrow(clean_dat), "\n")
cat("By learner party:\n")
print(table(clean_dat$learner_party))
