library(qualtRics)
library(gt)

id = "SV_7V5e1i5581koSwu"

# Download Qualtrics data and save as parquet
dat <- qualtRics::fetch_survey(surveyID = id)
arrow::write_parquet(dat, sink = "data/raw/qualtrics.parquet")

# codebook <- qualtRics::codebook(surveyID = id)
attr(dat, "column_map") %>% gt() %>% 
  tab_header(
    title = "Qualtrics Survey Codebook"
  ) %>% 
  gtsave("docs/codebook.html")
