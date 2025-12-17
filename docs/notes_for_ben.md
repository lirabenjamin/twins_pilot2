# Notes for Ben

## 2025-12-17: Makefile Added for Reproducible Pipeline

**What was done**:
- Created [Makefile](Makefile) to automate the entire analysis pipeline
- Updated [README.md](README.md) with comprehensive documentation

**Makefile features**:
- **`make all`** - Runs entire pipeline from raw data to final reports
- **`make help`** - Shows all available commands
- **`make data`** - Processes data and downloads conversations
- **`make analysis`** - Creates analysis datasets
- **`make report`** - Renders HTML and PDF reports
- **`make clean`** - Removes all processed data/outputs
- **`make dev`** - Quick HTML-only render for iteration

**Pipeline steps**:
1. Clean raw Qualtrics data (`src/r/clean_data.R`)
2. Download conversations (`src/python/download_conversations.py`)
3. Create analysis dataset (`src/r/create_analysis_data.R`)
4. Analyze extreme cases (`src/r/analyze_extreme_cases.R`)
5. Render reports (`analysis/report.qmd`)

**Benefits**:
- Single command reproducibility (`make all`)
- Dependency tracking (only rebuilds what's needed)
- Clear documentation of pipeline steps
- Easy for collaborators and reviewers

---

## 2025-12-17: Extreme Cases Appendix Added

**What was done**:
- Created [src/r/analyze_extreme_cases.R](src/r/analyze_extreme_cases.R) to identify and analyze extreme cases
- Added comprehensive **Appendix: Extreme Cases Analysis** to [analysis/report.qmd](analysis/report.qmd:753-872)
- Generated [output/extreme_cases_summary.md](output/extreme_cases_summary.md) with detailed findings

**Appendix includes**:
1. Summary table comparing most vs. least improved participants by learner party
2. Full marketing messages from extreme cases with interpretation
3. Engagement comparison table (word count, turn count)
4. Qualitative patterns distinguishing successful vs. unsuccessful learners
5. **Complete conversation transcripts** for all 4 extreme cases with detailed analysis

**Key insights**:
- Most improved: Genuine curiosity + deep engagement + finding common ground → bridge-building messages
- Least improved (worsened): Hostility + confirmation bias + surface engagement → divisive messages
- Full conversation transcripts available in data/processed/conversations/ for deeper analysis

---

## 2025-12-17: File Organization and Data Structure Completed

**Files reorganized** according to best practices:

**Source code organized** by language:
- R scripts → `src/r/` (clean_data.R, create_analysis_data.R, etc.)
- Python scripts → `src/python/` (download_conversations.py)

**Data files** (moved to `data/processed/`):
- `cleaned_data.parquet` - Full cleaned dataset with all variables
- `conversation_metrics.parquet` - Conversation engagement metrics
- `conversations/*.json` - Individual conversation files (211 participants)
- `analysis_data.parquet` - **Minimal dataset for publication** (50 variables)
- `analysis_data.csv` - Same as above, CSV format for broader accessibility

**Images** (moved to `output/figures/`):
- `accuracy_change.png`
- `warmth_change.png`

**Scripts updated** with new paths:
- [src/r/clean_data.R](src/r/clean_data.R:200-214) - Now writes to `data/processed/`
- [src/python/download_conversations.py](src/python/download_conversations.py:81-120) - Now writes to `data/processed/`
- [analysis/report.qmd](analysis/report.qmd:24) - Now reads from `data/processed/`
- [src/r/create_analysis_data.R](src/r/create_analysis_data.R) - **NEW** script to create minimal publication dataset

**Tested**: All scripts run successfully with new paths. Analysis reproduces correctly.

**Summary**:
- Full dataset: 141 variables, 211 observations
- **Publication dataset**: 50 variables, 211 observations (available as `.parquet` and `.csv`)
- All paths updated and verified working
- Documentation added to [data/processed/README.md](data/processed/README.md)
- Project instructions updated in [CLAUDE.md](CLAUDE.md)

---

## 2025-12-17: Q5 Engagement Analysis Completed

**What was done**:
1. Downloaded all conversations from the database for 211 participants
2. Saved individual conversations as JSON files in `output/conversations/`
3. Computed conversation metrics:
   - `user_turn_count`: Number of messages sent by participant (mean = 10.06, range = 1-37)
   - `user_word_count`: Total words typed by participant (mean = 182.85, range = 47-734)
   - `has_conversation`: Boolean indicating conversation data available (all TRUE)
4. Merged metrics into cleaned data via [src/clean_data.R](src/clean_data.R:199-208)
5. Implemented Q5 engagement analysis in [analysis/report.qmd](analysis/report.qmd:290-387)

**Q5 Analysis Completed**:
- Tested whether engagement predicts accuracy change using:
  - Turn count (number of messages)
  - Log-transformed word count (no +1 needed; min word count = 47)
- Tested whether engagement predicts warmth change (both metrics)
- Created 2×2 visualization grid showing all engagement effects by learner party
- Models control for baseline accuracy/warmth and learner party
- Analysis follows pre-registration specification

**Files created**:
- [src/python/download_conversations.py](src/python/download_conversations.py) - Script to download conversations
- `output/conversations/*.json` - 211 individual conversation files
- `output/conversation_metrics.parquet` - Metrics for all participants

---

## 2025-12-17: Fixed Line Plot Colors

Fixed color mapping issue in all line plots. The problem was that `learner_party` has values "D→R" and "R→D", but plots were using `party_colors` defined for "Democrat" and "Republican".

**Solution**: Created new `learner_party_colors` mapping:
- D→R (Democrats learning about Republicans) = Blue (#0015BC)
- R→D (Republicans learning about Democrats) = Red (#E81B23)

**Plots updated**:
- Belief Accuracy plot (analysis/report.qmd:161)
- Outgroup Warmth plot (analysis/report.qmd:171)
- Empathy vs. Informativeness scatter plot (analysis/report.qmd:280)
- Confidence plot (analysis/report.qmd:337)

---

## Data Needed for Complete Analysis

### Q5: Engagement Analysis
- **STATUS: ✓ DATA NOW AVAILABLE**
- **Variables added**: `user_turn_count` and `user_word_count` in cleaned data
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

## Makefile Pipeline Fixed (Dec 17, 2024)

Fixed the Makefile to correctly run the full pipeline starting from `src/r/download_qualtrics.r`:

**Pipeline sequence:**
1. **Step 0**: Download raw Qualtrics data (`src/r/download_qualtrics.r` → `data/raw/qualtrics.parquet`)
2. **Step 1**: Initial data cleaning without conversations (`src/r/clean_data.R`)
3. **Step 2**: Download conversations from database (`src/python/download_conversations.py` → `data/processed/conversation_metrics.parquet`)
4. **Step 3**: Re-clean data with conversation metrics merged (`src/r/clean_data.R`)
5. **Step 4-6**: Run analyses (create analysis dataset, extreme cases)
6. **Step 7-8**: Render HTML and PDF reports

**Key fixes:**
- Added virtual environment activation: `source .venv/bin/activate && python`
- Fixed dependency chain so conversation metrics are merged into cleaned data
- Reports now depend on both `cleaned_data.parquet` and `conversation_metrics.parquet`
- Pipeline tested and working with `make all`

**All 306 participants' conversations downloaded successfully:**
- Mean user turns: 10.6 (range: 1-93)
- Mean user words: 189.2 (range: 47-734)