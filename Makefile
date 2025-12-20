# Makefile for Learning from Twins analysis pipeline
# Author: Benjamin Lira
# Description: Reproducible pipeline for data processing and analysis

.PHONY: all clean data analysis report slides help

# Default target: run entire pipeline (data collection is complete)
all: report slides

# Help message
help:
	@echo "Learning from Twins - Analysis Pipeline"
	@echo "========================================"
	@echo ""
	@echo "Available targets:"
	@echo "  make all        - Run entire pipeline (clean → analysis → report → slides)"
	@echo "  make data       - Process all data (clean and merge)"
	@echo "  make analysis   - Create analysis dataset"
	@echo "  make report     - Render the report (HTML and PDF)"
	@echo "  make slides     - Render the presentation slides (PDF)"
	@echo "  make clean      - Remove processed data and outputs (preserves raw data)"
	@echo "  make help       - Show this help message"
	@echo ""
	@echo "Individual steps:"
	@echo "  make clean-data         - Clean and merge raw data with conversations"
	@echo "  make analysis-data      - Create minimal publication dataset"
	@echo "  make extreme-cases      - Analyze extreme cases"
	@echo "  make report-html        - Render HTML report only"
	@echo "  make report-pdf         - Render PDF report only"
	@echo ""
	@echo "Note: Data collection is complete. Raw data is immutable and never re-downloaded."

# Clean all processed data and outputs (preserves raw data)
clean:
	@echo "Cleaning processed data and outputs (preserving raw data)..."
	rm -f data/processed/cleaned_data.parquet
	rm -f data/processed/conversation_metrics.parquet
	rm -rf data/processed/conversations
	rm -f data/processed/analysis_data.parquet
	rm -f data/processed/analysis_data.csv
	rm -f output/extreme_cases.csv
	rm -f output/extreme_cases_summary.md
	rm -f analysis/report.html
	rm -f analysis/report.pdf
	rm -f analysis/slides.pdf
	@echo "Clean complete! (Raw data preserved in data/raw/)"

# Step 1: Clean and merge data (assumes raw data and conversations exist)
clean-data: data/processed/cleaned_data.parquet

data/processed/cleaned_data.parquet: data/raw/qualtrics.parquet data/processed/conversation_metrics.parquet src/r/clean_data.R
	@echo "Step 1: Cleaning and merging data..."
	Rscript src/r/clean_data.R
	@echo "✓ Cleaned data with conversation metrics created"

# Process all data (depends on clean data)
data: data/processed/cleaned_data.parquet
	@echo "✓ All data processing complete"

# Step 2: Create analysis dataset
analysis-data: data/processed/analysis_data.parquet

data/processed/analysis_data.parquet: data/processed/cleaned_data.parquet src/r/create_analysis_data.R
	@echo "Step 2: Creating analysis dataset for publication..."
	Rscript src/r/create_analysis_data.R
	@echo "✓ Analysis dataset created"

# Step 3: Analyze extreme cases
extreme-cases: output/extreme_cases.csv

output/extreme_cases.csv: data/processed/cleaned_data.parquet src/r/analyze_extreme_cases.R
	@echo "Step 3: Analyzing extreme cases..."
	Rscript src/r/analyze_extreme_cases.R
	@echo "✓ Extreme cases analyzed"

# Aggregate analysis target
analysis: analysis-data extreme-cases
	@echo "✓ All analyses complete"

# Step 4: Render HTML report
report-html: analysis/report.html

analysis/report.html: analysis/report.qmd data/processed/cleaned_data.parquet data/processed/conversation_metrics.parquet
	@echo "Step 4: Rendering HTML report..."
	cd analysis && quarto render report.qmd --to html
	@echo "✓ HTML report generated: analysis/report.html"

# Step 5: Render PDF report
report-pdf: analysis/report.pdf

analysis/report.pdf: analysis/report.qmd data/processed/cleaned_data.parquet data/processed/conversation_metrics.parquet
	@echo "Step 5: Rendering PDF report..."
	cd analysis && quarto render report.qmd --to pdf
	@echo "✓ PDF report generated: analysis/report.pdf"

# Render both reports
report: report-html report-pdf
	@echo "✓ All reports generated"
	@echo ""
	@echo "  - HTML: analysis/report.html"
	@echo "  - PDF:  analysis/report.pdf"

# Step 6: Render presentation slides
slides: analysis/slides.pdf

analysis/slides.pdf: analysis/slides.qmd data/processed/cleaned_data.parquet data/processed/conversation_metrics.parquet
	@echo "Step 6: Rendering presentation slides..."
	cd analysis && quarto render slides.qmd --to beamer
	@echo "✓ Slides generated: analysis/slides.pdf"

# Development: quick HTML-only render (faster for iteration)
dev: data
	@echo "Development mode: HTML report only..."
	cd analysis && quarto render report.qmd --to html
	@echo "✓ Development report ready: analysis/report.html"
