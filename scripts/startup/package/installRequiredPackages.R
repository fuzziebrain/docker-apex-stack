for(p in list('png','DBI','ROracle','randomForest','statmod','Cairo','arules')) {
    if(!require(p, character.only=TRUE, quietly=TRUE)) {
        if(p == 'arules') {
            install.packages('https://cran.r-project.org/src/contrib/Archive/arules/arules_1.1-9.tar.gz', repos=NULL, type='source');
        } else {
            install.packages(p);
        }
    }
}