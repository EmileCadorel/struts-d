module utils.exceptionmod.NoSuchFile;
import std.exception;
import utils.exception;

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

