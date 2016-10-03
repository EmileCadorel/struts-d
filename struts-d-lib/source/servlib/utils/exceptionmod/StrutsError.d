module servlib.utils.exceptionmod.StrutsError;
import servlib.utils.exception;
import servlib.utils.XMLoader;

class StrutsError : StrutsException {

    this (Balise balise) {
	super ("Erreur : Struts, " ~ balise.toStr ());
    }    

}
