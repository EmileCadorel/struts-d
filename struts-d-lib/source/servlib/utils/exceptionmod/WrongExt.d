module servlib.utils.exceptionmod.WrongExt;
import servlib.utils.exception;

/**
 Probleme lors de l'extraction d'une archive d'application
 */
class WrongExt : StrutsException {

    this (string filename) {
	super (filename ~ " n'est pas une archive valide");
    }
    
}
