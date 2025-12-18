# Fix for emmeans Sign Flip Issue

## Problem

The simple effects tables in `report.qmd` were showing inconsistent signs between model coefficients and emmeans contrasts. This occurred because:

1. **Model coefficients** (`timepost`): Represent `E[Y|time=post] - E[Y|time=pre]`
   - For accuracy (error): Negative value = improvement (post < pre)
   - For warmth: Positive value = increase (post > pre)

2. **Default emmeans contrasts**: Computed `first_level - second_level`
   - For `factor(c("pre", "post"))`: This computes `pre - post`
   - Signs are **opposite** of model coefficients!

## Solution

Changed all emmeans contrast calculations from:
```r
emmeans(model, ~ time | group) %>%
  contrast("pairwise") %>%
  tidy()
```

To:
```r
emmeans(model, ~ time | group) %>%
  pairs(reverse = TRUE) %>%
  tidy()
```

The `reverse = TRUE` argument makes emmeans compute `post - pre` instead of `pre - post`, matching the model coefficient direction.

## Files Modified

- `analysis/report.qmd`: Fixed 4 instances of emmeans contrasts:
  - Q2: Accuracy and warmth contrasts by learner_party (lines 407-413)
  - Q3: Accuracy and warmth contrasts by extremism level (lines 529-539)
  - Q7: Confidence contrasts by learner_party (lines 810-812)
  - Robustness: Warmth difference contrasts (lines 1188-1190)

## Verification

After this fix:
- Model coefficients and emmeans contrasts have **consistent signs**
- Tables showing both regression results and simple effects are now **internally consistent**
- Negative accuracy values = improvement (error decreases)
- Positive warmth values = increase (feelings warmer)

## Technical Details

The `pairs()` function with `reverse = TRUE` is equivalent to `contrast(method = "revpairwise")`. Both reverse the default comparison direction to compute second_level - first_level instead of first_level - second_level.
