# rk.text.mining: Text Mining and Corpus Analysis for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.text.mining/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.text.mining/actions/workflows/lintr.yml)

**rk.text.mining** brings a complete, user-friendly text mining pipeline to the RKWard GUI. Powered by the industry-standard `tm` (Text Mining) and `SnowballC` packages, this plugin suite allows researchers to import text documents, clean corpora, extract term frequencies, and discover word associations without writing a single line of complex R code.

## 🚀 What's New in Version 0.0.1

This is the initial release of the package, introducing five sequential statistical tools for comprehensive text analysis:

1.  **Build & Clean Corpus:** Import folders of `.txt` files and apply standard cleaning routines (lowercase, punctuation, numbers, whitespaces, and standard stopwords for 14 languages).
2.  **Inspect Corpus:** Safely view the contents and metadata of complex Corpus objects formatted as clean HTML tables, preventing RKWard GUI crashes.
3.  **Advanced Cleaning & Stemming:** Apply custom stopword vectors from your workspace, use a spreadsheet interface for manual pattern replacements, and reduce words to their root (stemming).
4.  **Frequencies & DTM:** Create Document-Term Matrices (DTM) with specific word length and global frequency bounds, outputting ordered frequency data frames.
5.  **Word Associations:** Calculate and extract correlations between multiple target words simultaneously across your document matrix.

### 🌍 Internationalization
The interface is fully localized in:
*   🇺🇸 English (Default)
*   🇪🇸 Spanish (`es`)
*   🇫🇷 French (`fr`)
*   🇩🇪 German (`de`)
*   🇧🇷 Portuguese (Brazil) (`pt_BR`)

## ✨ Features

### 1. Robust Data Import
*   **Batch Processing:** Point the plugin to a directory, and it will automatically ingest all `.txt` files into a unified UTF-8 encoded Corpus.
*   **Multilingual Stopwords:** Native support for 14 languages (English, Spanish, Portuguese, French, German, etc.) when removing standard stopwords.

### 2. Deep Customization & Safety
*   **Safe Inspection:** Corpus objects are complex S3 lists that crash standard GUI data editors. Our dedicated inspection tool safely truncates long documents and presents them safely in the output window.
*   **Spreadsheet Replacements:** Fix OCR errors or normalize words (e.g., `trabajando` -> `trabaj`) using an intuitive matrix grid instead of writing `gsub()` regular expressions.

### 3. Analytics
*   **Matrix Control:** Fine-tune your Document-Term Matrix by defining minimum/maximum word lengths and bounds.
*   **Batch Associations:** Type a comma-separated list of words (e.g., `community, children, works`) and instantly generate correlation tables for all of them at once.

## 📦 Installation

This plugin is available via GitHub. Use the `remotes` or `devtools` package in RKWard to install it.

1.  **Open RKWard**.
2.  **Run the following command** in the R Console:

    ```R
    # If you don't have devtools installed:
    # install.packages("devtools")
    
    local({
      require(devtools)
      install_github("AlfCano/rk.text.mining", force = TRUE)
    })
    ```
3.  **Restart RKWard** to load the new menu entries.

## 💻 Usage & Testing Instructions

Once installed, the tools are organized under:
**`Analysis` -> `Text Mining`**

To test the entire suite, you need some `.txt` files. Copy and paste this code into your RKWard console to instantly generate a temporary folder with dummy documents and a custom stopwords vector:

```R
# 1. Create a temporary folder and some dummy text files
test_dir <- file.path(tempdir(), "corpus_test")
dir.create(test_dir, showWarnings = FALSE)

writeLines("La comunidad está trabajando en obras públicas para los niños.", file.path(test_dir, "doc1.txt"))
writeLines("Los niños de la comunidad necesitan nuevas obras y escuelas.", file.path(test_dir, "doc2.txt"))
writeLines("El trabajo en la localidad ayuda a la comunidad entera.", file.path(test_dir, "doc3.txt"))

# Print the path you need to copy!
cat("COPY THIS PATH:\n", test_dir, "\n")

# 2. Create a custom stopwords vector
my_stopwords <- c("para", "las", "los", "del")
```

### Test 1: Build & Clean Corpus
1. Go to **Analysis -> Text Mining -> 1. Build & Clean Corpus**.
2. In **Text Files Directory**, paste the path printed in your console.
3. Set Language to **Spanish**. Check all cleaning options. Click **Submit**. 
4. *(You now have `clean_corpus` in your workspace).*

### Test 2: Inspect Corpus
1. Go to **2. Inspect Corpus**.
2. Select `clean_corpus` and click **Submit**. Check your Output window to see your documents cleanly formatted.

### Test 3: Advanced Cleaning
1. Go to **3. Advanced Cleaning & Stemming**.
2. Select `clean_corpus` as target. 
3. Check **Remove Custom Stopwords** and select `my_stopwords`.
4. Check **Apply Manual Replacements**. In the matrix, type `trabajando` in Col 1, and `trabaj` in Col 2. Add a second row: `trabajo` -> `trabaj`.
5. Click **Submit**. *(You now have `advanced_corpus`).*

### Test 4: Frequencies & DTM
1. Go to **4. Frequencies & DTM**.
2. Target `advanced_corpus`. Leave defaults. Click **Submit**. 
3. *(You now have `dtm_obj` and `frecpalabras.data`).*

### Test 5: Word Associations
1. Go to **5. Word Associations**.
2. Target `dtm_obj`.
3. In Target Words, type: `comunidad, niños, obras`. Set threshold to `0.1`.
4. Click **Submit**. View the correlation tables in your Output window!

## 🛠️ Dependencies

This plugin relies on the following R packages:
*   `tm` (Text Mining framework)
*   `SnowballC` (Multilingual Stemming)
*   `tibble` (Data formatting)
*   `rkwarddev` (Plugin generation)

## ✍️ Author & License

*   **Author:** Alfonso Cano (<alfonso.cano@correo.buap.mx>)
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)
