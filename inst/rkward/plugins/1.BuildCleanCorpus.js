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
  
    var dir = getValue('cb_dir');
    var lang = getValue('cb_lang');
    var lower = getValue('cb_lower');
    var punct = getValue('cb_punct');
    var nums = getValue('cb_nums');
    var spaces = getValue('cb_spaces');
    var stop = getValue('cb_stop');
    var stem = getValue('cb_stem');

    echo('docs <- tm::Corpus(tm::DirSource("' + dir + '", encoding="UTF-8"))\n');
    echo('trim <- function(x) trimws(x)\n');
    echo('toSpace <- tm::content_transformer(function(x, pattern) { return(gsub(pattern, " ", x)) })\n');

    echo('symbols <- c("\\\\r\\\\n", "[,]", "-", "¿", "•", "¡", "“", "”", "–", "…")\n');
    echo('for (sym in symbols) { docs <- tm::tm_map(docs, toSpace, sym) }\n');

    if (punct == 'TRUE') echo('docs <- tm::tm_map(docs, tm::removePunctuation)\n');
    if (lower == 'TRUE') echo('docs <- tm::tm_map(docs, tm::content_transformer(tolower))\n');
    if (nums == 'TRUE') echo('docs <- tm::tm_map(docs, tm::removeNumbers)\n');
    if (spaces == 'TRUE') echo('docs <- tm::tm_map(docs, tm::stripWhitespace)\n');
    if (stop == 'TRUE') echo('docs <- tm::tm_map(docs, tm::removeWords, tm::stopwords("' + lang + '"))\n');

    if (stem == 'TRUE') {
        echo('docs <- tm::tm_map(docs, trim)\n');
        echo('docs <- tm::tm_map(docs, tm::stemDocument, language="' + lang + '")\n');
    }

    echo('clean_corpus <- tm::tm_map(docs, trim)\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("1. Build & Clean Corpus results")).print();

    var dir = getValue('cb_dir');
    echo('rk.header("Corpus Building & Cleaning Process", level=2)\n');
    echo('rk.print(paste("Corpus imported from:", "' + dir + '"))\n');
    echo('rk.print(clean_corpus)\n');
  
	//// save result object
	// read in saveobject variables
	var cbSave = getValue("cb_save");
	var cbSaveActive = getValue("cb_save.active");
	var cbSaveParent = getValue("cb_save.parent");
	// assign object to chosen environment
	if(cbSaveActive) {
		echo(".GlobalEnv$" + cbSave + " <- clean_corpus\n");
	}

}

