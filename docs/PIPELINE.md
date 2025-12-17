# Analysis Pipeline Documentation

## Overview

This document describes the complete analysis pipeline for the "Learning from Twins" project.

## Pipeline Diagram

```
data/raw/qualtrics.parquet
         |
         v
    [clean_data.R] ────────────────────┐
         |                              |
         v                              v
data/processed/                 [download_conversations.py]
  cleaned_data.parquet                  |
         |                              v
         |                    data/processed/
         |                      conversations/
         |                      conversation_metrics.parquet
         |                              |
         └──────────────┬───────────────┘
                        v
            [create_analysis_data.R]
                        |
                        v
              data/processed/
                analysis_data.parquet
                analysis_data.csv
                        |
                        v
            [analyze_extreme_cases.R]
                        |
                        v
                  output/
                extreme_cases.csv
                extreme_cases_summary.md
                        |
                        v
              [report.qmd rendering]
                        |
                        v
                 analysis/
                   report.html
                   report.pdf
```

## Pipeline Steps

### 1. Data Cleaning
**Script**: `src/r/clean_data.R`
**Input**: `data/raw/qualtrics.parquet`
**Output**: `data/processed/cleaned_data.parquet`

**What it does**:
- Recodes political party variables to ingroup/outgroup
- Creates composite scores for environmental attitudes
- Computes accuracy measures (absolute error from actual outgroup means)
- Computes warmth difference scores
- Calculates political extremism
- Merges conversation metrics if available

**Run**: `Rscript src/r/clean_data.R` or `make clean-data`

### 2. Conversation Download
**Script**: `src/python/download_conversations.py`
**Input**: `data/raw/qualtrics.parquet` (for participant IDs)
**Output**:
- `data/processed/conversations/*.json` (211 files)
- `data/processed/conversation_metrics.parquet`

**What it does**:
- Connects to database to download conversation logs
- Saves each conversation as JSON
- Computes engagement metrics:
  - `user_turn_count`: Number of participant messages
  - `user_word_count`: Total words typed by participant

**Run**: `python src/python/download_conversations.py` or `make conversations`

### 3. Analysis Dataset Creation
**Script**: `src/r/create_analysis_data.R`
**Input**: `data/processed/cleaned_data.parquet`
**Output**:
- `data/processed/analysis_data.parquet`
- `data/processed/analysis_data.csv`

**What it does**:
- Selects only the 50 variables used in analyses
- Creates minimal dataset suitable for publication and data sharing
- Exports in both Parquet and CSV formats

**Run**: `Rscript src/r/create_analysis_data.R` or `make analysis-data`

### 4. Extreme Cases Analysis
**Script**: `src/r/analyze_extreme_cases.R`
**Input**: `data/processed/cleaned_data.parquet`
**Output**:
- `output/extreme_cases.csv`
- `output/extreme_cases_summary.md`
- Console output with full conversation transcripts

**What it does**:
- Identifies participants with most/least accuracy improvement
- Extracts their marketing messages
- Loads and displays full conversation transcripts
- Creates summary analysis

**Run**: `Rscript src/r/analyze_extreme_cases.R` or `make extreme-cases`

### 5. Report Rendering
**Script**: `analysis/report.qmd`
**Input**:
- `data/processed/cleaned_data.parquet`
- `data/processed/conversations/*.json`
**Output**:
- `analysis/report.html`
- `analysis/report.pdf`

**What it does**:
- Runs all statistical analyses
- Creates all visualizations
- Generates tables
- Includes extreme cases analysis appendix
- Renders formatted HTML and PDF reports

**Run**: `quarto render analysis/report.qmd` or `make report`

## Running the Pipeline

### Complete pipeline (recommended)
```bash
make all
```

This runs all steps in order:
1. Clean data
2. Download conversations
3. Create analysis dataset
4. Analyze extreme cases
5. Render reports

### Individual steps
```bash
make clean-data         # Step 1 only
make conversations      # Step 2 only
make data               # Steps 1-2
make analysis           # Steps 3-4
make report-html        # Step 5 (HTML only)
make report-pdf         # Step 5 (PDF only)
make report             # Step 5 (both formats)
```

### Development workflow
For rapid iteration during analysis:
```bash
make dev                # Quick HTML-only render
```

### Clean up
To remove all processed data and outputs:
```bash
make clean
```

## Dependencies

Each step depends on previous steps:
- **clean-data**: Requires raw data
- **conversations**: Requires raw data
- **analysis-data**: Requires cleaned data
- **extreme-cases**: Requires cleaned data
- **report**: Requires cleaned data and conversations

The Makefile automatically tracks these dependencies and only rebuilds what's needed.

## File Sizes (Approximate)

- `cleaned_data.parquet`: ~145 KB (141 variables, 211 obs)
- `analysis_data.parquet`: ~48 KB (50 variables, 211 obs)
- `analysis_data.csv`: ~60 KB
- `conversation_metrics.parquet`: ~8 KB
- `conversations/`: 211 JSON files, ~2-20 KB each
- `report.html`: ~190 KB
- `report.pdf`: ~180 KB

## Time Requirements

On a typical laptop:
- Data cleaning: ~5 seconds
- Conversation download: ~2-3 minutes (depends on database connection)
- Analysis dataset: ~2 seconds
- Extreme cases: ~2 seconds
- Report rendering: ~30-45 seconds
- **Total**: ~4-5 minutes for complete pipeline

## Troubleshooting

### "No such file or directory" errors
Make sure you're running commands from the project root directory.

### Python module errors
Activate the virtual environment: `source .venv/bin/activate`

### Database connection errors
Check that `.env` file contains valid `DATABASE_URL`

### R package errors
Install missing packages with `install.packages("package_name")`

### Quarto errors
Ensure Quarto is installed: `quarto --version`
