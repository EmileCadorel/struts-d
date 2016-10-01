module servlib.utils.exceptionmod.NoSuchFile;
import std.exception;
import servlib.utils.exception;
import servlib.utils.Log;

class NoSuchFile : StrutsException {

    this (string file) {
      Log.instance.add_err ("Erreur, le fichier ", file, " n'existe pas.");
	super("Erreur : le fichier '" ~ file ~ "' n'existe pas\n");
    }

}

