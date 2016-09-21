module utils.NoSuchFile;
import std.exception;
import utils.Exception;

class NoSuchFile : StrutsException {

    this (string file) {
	super(RED
	      ~ "Erreur "
	      ~ RESET
	      ~ " : le fichier '"
	      ~ file
	      ~ "' n'existe pas\n");
    }
    
}

