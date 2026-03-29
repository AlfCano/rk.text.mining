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
  
    var words = getValue('wa_words');
    echo('target_words <- trimws(unlist(strsplit("' + words + '", ",")))\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("5. Word Associations results")).print();

    var dtm = getValue('wa_dtm');
    var cor = getValue('wa_cor');

    echo('rk.header("Word Associations Results", level=2)\n');
    echo('for (w in target_words) {\n');
    echo('  res <- tm::findAssocs(' + dtm + ', w, ' + cor + ')\n');
    echo('  res_df <- as.data.frame(res)\n');
    echo('  rk.header(paste("Associations with:", w, "(Threshold:", ' + cor + ', ")"), level=3)\n');
    echo('  rk.print(res_df)\n');
    echo('}\n');
  

}

