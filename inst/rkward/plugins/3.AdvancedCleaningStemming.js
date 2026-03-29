// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(tm)\n");	echo("require(SnowballC)\n");
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
  
    var corpus = getValue('ac_corpus');
    var do_stop = getValue('ac_do_stop');
    var stop_var = getValue('ac_stop_var');
    var do_subs = getValue('ac_do_subs');
    var do_stem = getValue('ac_do_stem');
    var stem_lang = getValue('ac_stem_lang');

    echo('docs <- ' + corpus + '\n');
    echo('trim <- function(x) trimws(x)\n');

    if (do_stop == 'TRUE' && stop_var != '') {
        echo('docs <- tm::tm_map(docs, tm::removeWords, as.character(' + stop_var + '))\n');
        echo('docs <- tm::tm_map(docs, trim)\n');
        echo('docs <- tm::tm_map(docs, tm::stripWhitespace)\n');
    }

    if (do_stem == 'TRUE') {
        echo('docs <- tm::tm_map(docs, tm::stemDocument, language="' + stem_lang + '")\n');
        echo('docs <- tm::tm_map(docs, trim)\n');
    }

    if (do_subs == 'TRUE') {
        var mat_val = getValue('ac_subs_matrix');
        if (mat_val != '') {
            echo('subs_mat <- ' + mat_val + '\n');
            echo('if (is.matrix(subs_mat) && nrow(subs_mat) > 0) {\n');
            echo('  for(i in 1:nrow(subs_mat)) {\n');
            echo('    pat <- subs_mat[i, 1]\n');
            echo('    rep <- subs_mat[i, 2]\n');
            echo('    if (!is.na(pat) && pat != "") {\n');
            echo('      docs <- tm::tm_map(docs, tm::content_transformer(gsub), pattern = pat, replacement = rep)\n');
            echo('    }\n');
            echo('  }\n');
            echo('  docs <- tm::tm_map(docs, trim)\n');
            echo('}\n');
        }
    }

    echo('advanced_corpus <- docs\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("3. Advanced Cleaning & Stemming results")).print();

    echo('rk.header("Advanced Cleaning & Stemming Results", level=2)\n');
    echo('rk.print(advanced_corpus)\n');
  
	//// save result object
	// read in saveobject variables
	var acSave = getValue("ac_save");
	var acSaveActive = getValue("ac_save.active");
	var acSaveParent = getValue("ac_save.parent");
	// assign object to chosen environment
	if(acSaveActive) {
		echo(".GlobalEnv$" + acSave + " <- advanced_corpus\n");
	}

}

