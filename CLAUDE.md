# Project Instructions for Claude Code

## Goal
Help implement analysis and writing in a reproducible way.

## Repo Map
- analysis/report.qmd is the main analysis + narrative
- src/ contains reusable code
- output/ contains generated artifacts (ok to overwrite)
- data/raw is immutable
- lit/ contains papers you might find useful

## Rules
- Never modify data/raw.
- Prefer adding new scripts in src/ over one-off notebook code.
- When generating figures/tables, write to output/ and reference from analysis/.
- Document assumptions in analysis/report.qmd.
- Claude can talk to me by editing docs/notes_for_ben.md

## Writing Style
- Make sure every paragraph starts with a strong topic sentence
- Use simple concise and straightforward language
- Use active voice
- Never summarize one paper at a time, integrate them to tell a narrative
- When you make a list, make sure you are sorting it in some intelligent way (e.g., chronological, thematic, by importance, etc.)
- Use parallel structure whenever possible

## Project data
- title: Learning from Twins: Can marketers learn about consumers across the political divide by interacting with AI
- abstract: None yet
- stage: Pilot
- journal target: Journal of Marketing, JCR
