module servlib.utils.exceptionmod.StrutsError;
import servlib.utils.exception;
import servlib.utils.xml;

/**
 Erreur de semantic dans un fichier de type struts
 */
class StrutsError : StrutsException {

    this (Balise balise) {
	super ("Erreur : Struts, " ~ balise.toStr ());
    }    

}
