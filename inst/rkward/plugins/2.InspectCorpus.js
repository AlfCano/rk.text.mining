// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(tm)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getColName(fullPath) {
        if (!fullPath) return '';
        if (fullPath.indexOf('$') > -1) {
            return fullPath.split('$')[1];
        } else if (fullPath.indexOf('[[') > -1) {
            var inner = fullPath.split('[[')[1].replace(']]', '');
            return inner.split('"').join('').split(String.fromCharCode(39)).join('');
        }
        return fullPath;
    }
  
    var corpus = getValue('ic_corpus');
    var n = getValue('ic_n_docs');
    var trunc = getValue('ic_trunc_cbox');
    var max_chars = getValue('ic_max_chars');

    echo('n_docs <- min(' + n + ', length(' + corpus + '))\n');
    echo('docs_subset <- ' + corpus + '[1:n_docs]\n');

    echo('doc_content <- sapply(docs_subset, as.character)\n');

    // Lógica para recortar el texto y prevenir sobrecarga de memoria
    if (trunc == 'TRUE') {
        echo('doc_content <- ifelse(nchar(doc_content) > ' + max_chars + ', paste0(substr(doc_content, 1, ' + max_chars + '), \" [...truncated]\"), doc_content)\n');
    }

    echo('text_df <- data.frame(Document = names(docs_subset), Content = doc_content, stringsAsFactors = FALSE)\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("2. Inspect Corpus results")).print();

    var corpus = getValue('ic_corpus');

    echo('rk.header("Corpus Inspection", level=2)\n');
    echo('rk.print(paste("Object:", "' + corpus + '"))\n');
    echo('rk.print(' + corpus + ')\n');

    echo('rk.header("Document Contents (Preview)", level=3)\n');
    echo('rk.print(text_df)\n');
  

}

