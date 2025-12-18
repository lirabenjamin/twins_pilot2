# Citation and Caption Guide for report.qmd

## Citations

### Adding References

1. Add your references to `lit/references.bib` in BibTeX format
2. Cite in text using `@citationkey` or `[@citationkey]`

### Citation Formats

- **In-text citation**: `@smith2024` → Smith (2024)
- **Parenthetical citation**: `[@smith2024]` → (Smith, 2024)
- **Multiple citations**: `[@smith2024; @jones2023]` → (Smith, 2024; Jones, 2023)
- **With page numbers**: `[@smith2024, p. 42]` → (Smith, 2024, p. 42)
- **Suppress author**: `[-@smith2024]` → (2024)

### Example BibTeX Entry

```bibtex
@article{smith2024,
  author = {Smith, John and Doe, Jane},
  title = {Understanding Political Polarization},
  journal = {Journal of Marketing},
  year = {2024},
  volume = {88},
  number = {3},
  pages = {123--145},
  doi = {10.1177/00222429241234567}
}
```

### Bibliography Location

The bibliography will automatically appear at the end of your document under a "References" heading.

## Figure Captions

Figures get captions **below** the figure.

### Basic Figure Caption

```r
```{r}
#| label: fig-my-figure
#| fig-cap: "This is the figure caption text."
#| fig-width: 6
#| fig-height: 4

ggplot(data, aes(x, y)) + geom_point()
```
```

### Cross-referencing Figures

In your text, reference the figure using `@fig-my-figure`:

```markdown
As shown in @fig-my-figure, the relationship is positive.
```

This will render as: "As shown in Figure 1, the relationship is positive."

### Multi-panel Figures

```r
```{r}
#| label: fig-multi-panel
#| fig-cap: "Main caption for the entire figure."
#| fig-subcap:
#|   - "Panel A: First plot"
#|   - "Panel B: Second plot"
#| layout-ncol: 2

plot1
plot2
```
```

## Table Captions

Tables get captions **above** the table.

### Basic Table Caption

```r
```{r}
#| label: tbl-my-table
#| tbl-cap: "This is the table caption text."

dat %>%
  group_by(group) %>%
  summarise(mean = mean(value)) %>%
  gt()
```
```

### Cross-referencing Tables

In your text, reference the table using `@tbl-my-table`:

```markdown
The results are shown in @tbl-my-table.
```

This will render as: "The results are shown in Table 1."

## Current Configuration

Your report is configured with:
- **Bibliography**: `lit/references.bib`
- **Citation style**: APA (via CSL from Zotero)
- **Figure captions**: Bottom
- **Table captions**: Top
- **Linked citations**: Enabled (citations are clickable)

## Tips

1. **Label naming conventions**:
   - Figures: Start with `fig-` (e.g., `fig-accuracy-plot`)
   - Tables: Start with `tbl-` (e.g., `tbl-descriptives`)

2. **Caption text**:
   - Keep captions concise but informative
   - Use sentence case
   - End with a period

3. **Cross-references**:
   - Use `@fig-label` or `@tbl-label` to reference
   - Quarto will auto-number and create clickable links

4. **Citation style**:
   - Change CSL file in YAML to use different citation style
   - Browse styles at: https://www.zotero.org/styles
