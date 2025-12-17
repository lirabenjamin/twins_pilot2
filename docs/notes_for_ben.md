# Notes for Ben

## Data Needed for Complete Analysis

### Q5: Engagement Analysis
- **Missing**: Word count or chat length data
- **Variable needed**: Number of words typed by participant during chatbot interaction
- **Purpose**: Test whether engagement predicts belief updating and warmth change
- **Pre-registration**: "examine whether engagement with the chatbot—operationalized as the number of words typed by the participant during the chat—is associated with post-interaction outcomes"

### Q6: Applied Judgment (Slogan Quality)
- **Available**: Raw slogan text in variable `Q23`
- **Missing**:
  1. Semantic similarity scores (comparing to AI-generated responses from ChatGPT, Claude, Gemini)
  2. Quality ratings (human or LLM ratings of fit to target group)
- **Pre-registration**: "assess potential copying by computing semantic similarity... Slogans with similarity values more than 3 SDs above the mean will be excluded"
- **Action needed**:
  1. Generate comparison slogans from ChatGPT/Claude/Gemini
  2. Compute semantic embeddings and similarity scores
  3. Get quality ratings for slogans

## Report Organization Complete

The report has been reorganized around 7 research questions:
1. Q1: Do people update their beliefs? (accuracy + warmth)
2. Q2: Is updating symmetric across groups? (time × party interaction)
3. Q3: Does extremity predict updating? (extremism moderator)
4. Q4: Is updating linked to bot perceptions? (info/empathy regressions)
5. Q5: Does engagement matter? (PLACEHOLDER - need word count data)
6. Q6: Does it improve applied judgment? (PLACEHOLDER - need slogan ratings)
7. Q7: Does confidence track accuracy? (confidence analysis)

Robustness checks (warmth difference score) are at the end of Results section.

## Code Organization Complete

All data preparation has been moved to src/clean_data.R:
- Accuracy variables (accuracy_pre, accuracy_post) are now computed in the cleaning script
- Computed as absolute error: abs(green_outgroup_pre/post - actual_green)
- Actual outgroup attitudes calculated from within-group means
- report.qmd now uses pre-computed accuracy variables from cleaned data
