module utils.exceptionmod.NoSuchFile;
import std.exception;
import utils.exception;
import utils.Log;

class NoSuchFile : StrutsException {

    this (string file) {
      Log.instance.add_err ("Erreur, le fichier " ~ file ~ " n'existe pas.");
	super(RED
	      ~ "Erreur "
	      ~ RESET
	      ~ " : le fichier '"
	      ~ file
	      ~ "' n'existe pas\n");
    }

}

