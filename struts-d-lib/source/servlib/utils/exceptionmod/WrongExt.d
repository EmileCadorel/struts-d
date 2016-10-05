module servlib.utils.exceptionmod.WrongExt;
import servlib.utils.exception;


class WrongExt : StrutsException {

    this (string filename) {
	super (filename ~ " n'est pas une archive valide");
    }
    
}
