// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(tm)\n");	echo("require(tibble)\n");	echo("require(reshape)\n");
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
  
    var corpus = getValue('tf_corpus');
    var minl = getValue('tf_min_len');
    var maxl = getValue('tf_max_len');
    var minb = getValue('tf_min_bnd');
    var maxb = getValue('tf_max_bnd');

    echo('dtm_obj <- tm::DocumentTermMatrix(' + corpus + ', control=list(wordLengths=c(' + minl + ',' + maxl + '), bounds=list(global=c(' + minb + ',' + maxb + '))))\n');
    echo('freqs <- sort(colSums(as.matrix(dtm_obj)), decreasing=TRUE)\n');
    echo('frecpalabras.data <- as.data.frame(freqs)\n');
    echo('frecpalabras.data <- tibble::rownames_to_column(frecpalabras.data, var="palabras")\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("4. Frequencies & DTM results")).print();

    echo('rk.header("Document Term Matrix Frequencies", level=2)\n');
    echo('rk.print(head(frecpalabras.data, 100))\n');
  
	//// save result object
	// read in saveobject variables
	var tfSaveDtm = getValue("tf_save_dtm");
	var tfSaveDtmActive = getValue("tf_save_dtm.active");
	var tfSaveDtmParent = getValue("tf_save_dtm.parent");	var tfSaveDf = getValue("tf_save_df");
	var tfSaveDfActive = getValue("tf_save_df.active");
	var tfSaveDfParent = getValue("tf_save_df.parent");
	// assign object to chosen environment
	if(tfSaveDtmActive) {
		echo(".GlobalEnv$" + tfSaveDtm + " <- dtm_obj\n");
	}
	if(tfSaveDfActive) {
		echo(".GlobalEnv$" + tfSaveDf + " <- frecpalabras.data\n");
	}

}

