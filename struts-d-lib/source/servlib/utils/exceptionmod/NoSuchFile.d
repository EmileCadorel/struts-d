module servlib.utils.exceptionmod.NoSuchFile;
import std.exception;
import servlib.utils.exception;
import servlib.utils.Log;

/**
 Erreur lors de l'ouverture d'un fichier non existant
*/
class NoSuchFile : StrutsException {

    this (string file) {
      Log.instance.addError ("Erreur, le fichier ", file, " n'existe pas.");
	super("Erreur : le fichier '" ~ file ~ "' n'existe pas\n");
    }

}

