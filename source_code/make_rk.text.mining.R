local({
  # =========================================================================================
  # 1. Metadatos y Configuración
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.text.mining",
    author = person(
      given = "Alfonso",
      family = "Cano Robles",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "RKWard Plugin Suite for Text Mining (tm), Corpus Cleaning, and Word Associations.",
      version = "0.0.1",
      url = "https://github.com/AlfCano/rk.text.mining",
      license = "GPL (>= 3)"
    )
  )

  common_hierarchy <- list("analysis", "Text Mining")

  js_parse_helper <- "
    function getColName(fullPath) {
        if (!fullPath) return '';
        if (fullPath.indexOf('$') > -1) {
            return fullPath.split('$')[1];
        } else if (fullPath.indexOf('[[') > -1) {
            var inner = fullPath.split('[[')[1].replace(']]', '');
            return inner.split('\"').join('').split(String.fromCharCode(39)).join('');
        }
        return fullPath;
    }
  "

  # =========================================================================================
  # COMPONENTE 1: Corpus Builder & Preprocessing
  # =========================================================================================

  help_cb <- rk.rkh.doc(title = rk.rkh.title("Corpus Builder & Preprocessing"), summary = rk.rkh.summary("Import TXT files and clean the Corpus (stopwords, punctuation)."))

  cb_dir <- rk.XML.browser("Text Files Directory", type = "dir", required = TRUE, id.name = "cb_dir")

  cb_lang <- rk.XML.dropdown("Language (Standard Stopwords)", options = list(
    "English" = list(val = "english", chk = TRUE),
    "Spanish" = list(val = "spanish"),
    "Portuguese" = list(val = "portuguese"),
    "French" = list(val = "french"),
    "German" = list(val = "german"),
    "Italian" = list(val = "italian"),
    "Dutch" = list(val = "dutch"),
    "Russian" = list(val = "russian"),
    "Swedish" = list(val = "swedish"),
    "Danish" = list(val = "danish"),
    "Finnish" = list(val = "finnish"),
    "Hungarian" = list(val = "hungarian"),
    "Norwegian" = list(val = "norwegian"),
    "Romanian" = list(val = "romanian")
  ), id.name = "cb_lang")

  cb_lower <- rk.XML.cbox("Convert to Lower Case", value = "TRUE", chk = TRUE, id.name = "cb_lower")
  cb_punct <- rk.XML.cbox("Remove Punctuation", value = "TRUE", chk = TRUE, id.name = "cb_punct")
  cb_nums <- rk.XML.cbox("Remove Numbers", value = "TRUE", chk = TRUE, id.name = "cb_nums")
  cb_spaces <- rk.XML.cbox("Strip Extra Whitespaces", value = "TRUE", chk = TRUE, id.name = "cb_spaces")
  cb_stop <- rk.XML.cbox("Remove Standard Stop Words", value = "TRUE", chk = TRUE, id.name = "cb_stop")
  cb_stem <- rk.XML.cbox("Apply Stemming (Reduce to root)", value = "TRUE", chk = FALSE, id.name = "cb_stem")

  cb_save <- rk.XML.saveobj("Save Clean Corpus as", chk = TRUE, initial = "clean_corpus", id.name = "cb_save")

  cb_warn <- rk.XML.text("WARNING: Do NOT double-click or try to edit the saved Corpus object in the RKWard Workspace viewer. Corpus objects are complex lists and will crash the GUI data editor. Use the 'Inspect Corpus' plugin to view its contents safely.")

  tab_cb_in <- rk.XML.col(cb_dir, cb_lang)
  tab_cb_cl <- rk.XML.col(cb_lower, cb_punct, cb_nums, cb_spaces, cb_stop, cb_stem)
  tab_cb_out <- rk.XML.col(cb_save, cb_warn)

  dialog_cb <- rk.XML.dialog(label = "Corpus Builder", child = rk.XML.tabbook(tabs = list("Input" = tab_cb_in, "Cleaning Rules" = tab_cb_cl, "Output" = tab_cb_out)))

  js_calc_cb <- paste0(js_parse_helper, "
    var dir = getValue('cb_dir');
    var lang = getValue('cb_lang');
    var lower = getValue('cb_lower');
    var punct = getValue('cb_punct');
    var nums = getValue('cb_nums');
    var spaces = getValue('cb_spaces');
    var stop = getValue('cb_stop');
    var stem = getValue('cb_stem');

    echo('docs <- tm::Corpus(tm::DirSource(\"' + dir + '\", encoding=\"UTF-8\"))\\n');
    echo('trim <- function(x) trimws(x)\\n');
    echo('toSpace <- tm::content_transformer(function(x, pattern) { return(gsub(pattern, \" \", x)) })\\n');

    echo('symbols <- c(\"\\\\\\\\r\\\\\\\\n\", \"[,]\", \"-\", \"¿\", \"•\", \"¡\", \"“\", \"”\", \"–\", \"…\")\\n');
    echo('for (sym in symbols) { docs <- tm::tm_map(docs, toSpace, sym) }\\n');

    if (punct == 'TRUE') echo('docs <- tm::tm_map(docs, tm::removePunctuation)\\n');
    if (lower == 'TRUE') echo('docs <- tm::tm_map(docs, tm::content_transformer(tolower))\\n');
    if (nums == 'TRUE') echo('docs <- tm::tm_map(docs, tm::removeNumbers)\\n');
    if (spaces == 'TRUE') echo('docs <- tm::tm_map(docs, tm::stripWhitespace)\\n');
    if (stop == 'TRUE') echo('docs <- tm::tm_map(docs, tm::removeWords, tm::stopwords(\"' + lang + '\"))\\n');

    if (stem == 'TRUE') {
        echo('docs <- tm::tm_map(docs, trim)\\n');
        echo('docs <- tm::tm_map(docs, tm::stemDocument, language=\"' + lang + '\")\\n');
    }

    echo('clean_corpus <- tm::tm_map(docs, trim)\\n');
  ")

  js_print_cb <- "
    var dir = getValue('cb_dir');
    echo('rk.header(\"Corpus Building & Cleaning Process\", level=2)\\n');
    echo('rk.print(paste(\"Corpus imported from:\", \"' + dir + '\"))\\n');
    echo('rk.print(clean_corpus)\\n');
  "

  comp_cb <- rk.plugin.component("1. Build & Clean Corpus", xml = list(dialog = dialog_cb), js = list(require = c("tm", "SnowballC"), calculate = js_calc_cb, printout = js_print_cb), hierarchy = common_hierarchy, rkh = list(help = help_cb))

  # =========================================================================================
  # COMPONENTE 2: Inspect Corpus (ACTUALIZADO CON TRUNCADO DE TEXTO)
  # =========================================================================================

  help_ic <- rk.rkh.doc(title = rk.rkh.title("Inspect Corpus"), summary = rk.rkh.summary("Safely inspects the text and metadata of a Corpus object without crashing RKWard."))

  var_sel_ic <- rk.XML.varselector(id.name = "var_sel_ic")
  ic_corpus <- rk.XML.varslot("Corpus Object to Inspect", source = var_sel_ic, required = TRUE, id.name = "ic_corpus")
  ic_n_docs <- rk.XML.spinbox("Number of documents to display", min = 1, initial = 5, id.name = "ic_n_docs")

  # NUEVO: Opciones para limitar el tamaño de salida (Truncar texto)
  ic_trunc_cbox <- rk.XML.cbox("Truncate text in output", value = "TRUE", chk = TRUE, id.name = "ic_trunc_cbox")
  ic_max_chars <- rk.XML.spinbox("Max characters per document", min = 10, max = 100000, initial = 500, id.name = "ic_max_chars")

  ic_note <- rk.XML.text("Displays the actual text content of the corpus formatted safely as a table.")

  tab_ic_in <- rk.XML.row(var_sel_ic, rk.XML.col(ic_corpus, ic_n_docs, rk.XML.frame(ic_trunc_cbox, ic_max_chars, label="Display Limits"), ic_note))

  dialog_ic <- rk.XML.dialog(label = "Inspect Corpus", child = rk.XML.tabbook(tabs = list("Inspection Options" = tab_ic_in)))

  js_calc_ic <- paste0(js_parse_helper, "
    var corpus = getValue('ic_corpus');
    var n = getValue('ic_n_docs');
    var trunc = getValue('ic_trunc_cbox');
    var max_chars = getValue('ic_max_chars');

    echo('n_docs <- min(' + n + ', length(' + corpus + '))\\n');
    echo('docs_subset <- ' + corpus + '[1:n_docs]\\n');

    echo('doc_content <- sapply(docs_subset, as.character)\\n');

    // Lógica para recortar el texto y prevenir sobrecarga de memoria
    if (trunc == 'TRUE') {
        echo('doc_content <- ifelse(nchar(doc_content) > ' + max_chars + ', paste0(substr(doc_content, 1, ' + max_chars + '), \\\" [...truncated]\\\"), doc_content)\\n');
    }

    echo('text_df <- data.frame(Document = names(docs_subset), Content = doc_content, stringsAsFactors = FALSE)\\n');
  ")

  js_print_ic <- "
    var corpus = getValue('ic_corpus');

    echo('rk.header(\"Corpus Inspection\", level=2)\\n');
    echo('rk.print(paste(\"Object:\", \"' + corpus + '\"))\\n');
    echo('rk.print(' + corpus + ')\\n');

    echo('rk.header(\"Document Contents (Preview)\", level=3)\\n');
    echo('rk.print(text_df)\\n');
  "

  comp_ic <- rk.plugin.component("2. Inspect Corpus", xml = list(dialog = dialog_ic), js = list(require = c("tm"), calculate = js_calc_ic, printout = js_print_ic), hierarchy = common_hierarchy, rkh = list(help = help_ic))

  # =========================================================================================
  # COMPONENTE 3: Advanced Cleaning & Stemming
  # =========================================================================================

  help_ac <- rk.rkh.doc(title = rk.rkh.title("Advanced Cleaning & Stemming"), summary = rk.rkh.summary("Aplica listas personalizadas de stopwords, sustitución manual y stemming."))

  var_sel_ac <- rk.XML.varselector(id.name = "var_sel_ac")
  ac_corpus <- rk.XML.varslot("Target Corpus", source = var_sel_ac, required = TRUE, id.name = "ac_corpus")

  ac_do_stop <- rk.XML.cbox("Remove Custom Stopwords", value = "TRUE", chk = FALSE, id.name = "ac_do_stop")
  ac_stop_var <- rk.XML.varslot("Custom Stopwords Vector (e.g., filtro.data[['P']])", source = var_sel_ac, required = FALSE, id.name = "ac_stop_var")

  ac_do_subs <- rk.XML.cbox("Apply Manual Replacements", value = "TRUE", chk = FALSE, id.name = "ac_do_subs")
  ac_subs_matrix <- rk.XML.matrix("Replacement Rules (Col 1: Pattern, Col 2: Replacement)", rows = 1, columns = 2, min = 0, mode = "string", id.name = "ac_subs_matrix")

  ac_do_stem <- rk.XML.cbox("Apply Stemming (Reduce to root)", value = "TRUE", chk = FALSE, id.name = "ac_do_stem")
  ac_stem_lang <- rk.XML.dropdown("Stemming Language", options = list("English" = list(val = "english", chk = TRUE), "Spanish" = list(val = "spanish")), id.name = "ac_stem_lang")

  ac_save <- rk.XML.saveobj("Save Advanced Corpus as", chk = TRUE, initial = "advanced_corpus", id.name = "ac_save")

  ac_warn <- rk.XML.text("WARNING: Do NOT edit the saved Corpus in the Workspace viewer. Use 'Inspect Corpus'.")

  tab_ac_in <- rk.XML.row(var_sel_ac, rk.XML.col(ac_corpus, rk.XML.frame(ac_do_stop, ac_stop_var, label="Custom Stopwords")))
  tab_ac_rules <- rk.XML.col(rk.XML.frame(ac_do_subs, ac_subs_matrix, label="Manual Substitutions"), rk.XML.frame(ac_do_stem, ac_stem_lang, label="Stemming"))
  tab_ac_out <- rk.XML.col(ac_save, ac_warn)

  dialog_ac <- rk.XML.dialog(label = "Advanced Cleaning & Stemming", child = rk.XML.tabbook(tabs = list("Input & Stopwords" = tab_ac_in, "Replace & Stem" = tab_ac_rules, "Output" = tab_ac_out)))

  js_calc_ac <- paste0(js_parse_helper, "
    var corpus = getValue('ac_corpus');
    var do_stop = getValue('ac_do_stop');
    var stop_var = getValue('ac_stop_var');
    var do_subs = getValue('ac_do_subs');
    var do_stem = getValue('ac_do_stem');
    var stem_lang = getValue('ac_stem_lang');

    echo('docs <- ' + corpus + '\\n');
    echo('trim <- function(x) trimws(x)\\n');

    if (do_stop == 'TRUE' && stop_var != '') {
        echo('docs <- tm::tm_map(docs, tm::removeWords, as.character(' + stop_var + '))\\n');
        echo('docs <- tm::tm_map(docs, trim)\\n');
        echo('docs <- tm::tm_map(docs, tm::stripWhitespace)\\n');
    }

    if (do_stem == 'TRUE') {
        echo('docs <- tm::tm_map(docs, tm::stemDocument, language=\"' + stem_lang + '\")\\n');
        echo('docs <- tm::tm_map(docs, trim)\\n');
    }

    if (do_subs == 'TRUE') {
        var mat_val = getValue('ac_subs_matrix');
        if (mat_val != '') {
            echo('subs_mat <- ' + mat_val + '\\n');
            echo('if (is.matrix(subs_mat) && nrow(subs_mat) > 0) {\\n');
            echo('  for(i in 1:nrow(subs_mat)) {\\n');
            echo('    pat <- subs_mat[i, 1]\\n');
            echo('    rep <- subs_mat[i, 2]\\n');
            echo('    if (!is.na(pat) && pat != \"\") {\\n');
            echo('      docs <- tm::tm_map(docs, tm::content_transformer(gsub), pattern = pat, replacement = rep)\\n');
            echo('    }\\n');
            echo('  }\\n');
            echo('  docs <- tm::tm_map(docs, trim)\\n');
            echo('}\\n');
        }
    }

    echo('advanced_corpus <- docs\\n');
  ")

  js_print_ac <- "
    echo('rk.header(\"Advanced Cleaning & Stemming Results\", level=2)\\n');
    echo('rk.print(advanced_corpus)\\n');
  "

  comp_ac <- rk.plugin.component("3. Advanced Cleaning & Stemming", xml = list(dialog = dialog_ac), js = list(require = c("tm", "SnowballC"), calculate = js_calc_ac, printout = js_print_ac), hierarchy = common_hierarchy, rkh = list(help = help_ac))

  # =========================================================================================
  # COMPONENTE 4: Term Frequencies & DTM
  # =========================================================================================

  help_tf <- rk.rkh.doc(title = rk.rkh.title("Term Frequencies & DTM"), summary = rk.rkh.summary("Creates a Document-Term Matrix and extracts frequent words."))

  var_select_tf <- rk.XML.varselector(id.name = "var_sel_tf")
  tf_corpus <- rk.XML.varslot("Target Corpus Object", source = var_select_tf, required = TRUE, id.name = "tf_corpus")

  tf_min_len <- rk.XML.spinbox("Min Word Length", min = 1, initial = 4, id.name = "tf_min_len")
  tf_max_len <- rk.XML.spinbox("Max Word Length", min = 2, initial = 20, id.name = "tf_max_len")
  tf_min_bnd <- rk.XML.spinbox("Min Document Frequency Bounds", min = 1, initial = 3, id.name = "tf_min_bnd")
  tf_max_bnd <- rk.XML.spinbox("Max Document Frequency Bounds", min = 2, initial = 27, id.name = "tf_max_bnd")

  tf_save_dtm <- rk.XML.saveobj("Save DocumentTermMatrix as", chk = TRUE, initial = "dtm_obj", id.name = "tf_save_dtm")
  tf_save_df <- rk.XML.saveobj("Save Frequencies DataFrame as", chk = TRUE, initial = "frecpalabras.data", id.name = "tf_save_df")

  tab_tf_in <- rk.XML.row(var_select_tf, rk.XML.col(tf_corpus, rk.XML.frame(tf_min_len, tf_max_len, label="Word Lengths"), rk.XML.frame(tf_min_bnd, tf_max_bnd, label="Global Bounds")))
  tab_tf_out <- rk.XML.col(tf_save_dtm, tf_save_df)

  dialog_tf <- rk.XML.dialog(label = "Term Frequencies & DTM", child = rk.XML.tabbook(tabs = list("Input & Control" = tab_tf_in, "Output" = tab_tf_out)))

  js_calc_tf <- paste0(js_parse_helper, "
    var corpus = getValue('tf_corpus');
    var minl = getValue('tf_min_len');
    var maxl = getValue('tf_max_len');
    var minb = getValue('tf_min_bnd');
    var maxb = getValue('tf_max_bnd');

    echo('dtm_obj <- tm::DocumentTermMatrix(' + corpus + ', control=list(wordLengths=c(' + minl + ',' + maxl + '), bounds=list(global=c(' + minb + ',' + maxb + '))))\\n');
    echo('freqs <- sort(colSums(as.matrix(dtm_obj)), decreasing=TRUE)\\n');
    echo('frecpalabras.data <- as.data.frame(freqs)\\n');
    echo('frecpalabras.data <- tibble::rownames_to_column(frecpalabras.data, var=\"palabras\")\\n');
  ")

  js_print_tf <- "
    echo('rk.header(\"Document Term Matrix Frequencies\", level=2)\\n');
    echo('rk.print(head(frecpalabras.data, 100))\\n');
  "

  comp_tf <- rk.plugin.component("4. Frequencies & DTM", xml = list(dialog = dialog_tf), js = list(require = c("tm", "tibble", "reshape"), calculate = js_calc_tf, printout = js_print_tf), hierarchy = common_hierarchy, rkh = list(help = help_tf))

  # =========================================================================================
  # COMPONENTE 5: Word Associations
  # =========================================================================================

  help_wa <- rk.rkh.doc(title = rk.rkh.title("Word Associations"), summary = rk.rkh.summary("Finds associations (correlations) between specific words in the DTM."))

  var_sel_wa <- rk.XML.varselector(id.name = "var_sel_wa")
  wa_dtm <- rk.XML.varslot("DocumentTermMatrix Object", source = var_sel_wa, required = TRUE, id.name = "wa_dtm")

  wa_words <- rk.XML.input("Target Words (comma separated)", initial = "community, children, works", required = TRUE, id.name = "wa_words")
  wa_cor <- rk.XML.spinbox("Correlation Threshold", min = 0, max = 1, initial = 0.9, real = TRUE, id.name = "wa_cor")

  tab_wa_in <- rk.XML.row(var_sel_wa, rk.XML.col(wa_dtm, rk.XML.frame(wa_words, wa_cor, label="Association Settings")))

  dialog_wa <- rk.XML.dialog(label = "Word Associations", child = rk.XML.tabbook(tabs = list("Input" = tab_wa_in)))

  js_calc_wa <- paste0(js_parse_helper, "
    var words = getValue('wa_words');
    echo('target_words <- trimws(unlist(strsplit(\"' + words + '\", \",\")))\\n');
  ")

  js_print_wa <- "
    var dtm = getValue('wa_dtm');
    var cor = getValue('wa_cor');

    echo('rk.header(\"Word Associations Results\", level=2)\\n');
    echo('for (w in target_words) {\\n');
    echo('  res <- tm::findAssocs(' + dtm + ', w, ' + cor + ')\\n');
    echo('  res_df <- as.data.frame(res)\\n');
    echo('  rk.header(paste(\"Associations with:\", w, \"(Threshold:\", ' + cor + ', \")\"), level=3)\\n');
    echo('  rk.print(res_df)\\n');
    echo('}\\n');
  "

  comp_wa <- rk.plugin.component("5. Word Associations", xml = list(dialog = dialog_wa), js = list(require = c("tm"), calculate = js_calc_wa, printout = js_print_wa), hierarchy = common_hierarchy, rkh = list(help = help_wa))

  # =========================================================================================
  # CONSTRUCCIÓN DEL ESQUELETO MÚLTIPLE
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_cb),
    js = list(require = c("tm", "SnowballC"), calculate = js_calc_cb, printout = js_print_cb),
    rkh = list(help = help_cb),
    components = list(comp_ic, comp_ac, comp_tf, comp_wa),
    pluginmap = list(name = "1. Build & Clean Corpus", hierarchy = common_hierarchy),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin 'rk.text.mining' successfully generated.\n")
  cat("Menu locations:\n")
  cat("  1. Analysis -> Text Mining -> 1. Build & Clean Corpus\n")
  cat("  2. Analysis -> Text Mining -> 2. Inspect Corpus\n")
  cat("  3. Analysis -> Text Mining -> 3. Advanced Cleaning & Stemming\n")
  cat("  4. Analysis -> Text Mining -> 4. Frequencies & DTM\n")
  cat("  5. Analysis -> Text Mining -> 5. Word Associations\n")
})
