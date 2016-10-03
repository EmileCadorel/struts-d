module servlib.utils.exceptionmod.ManifestError;
import servlib.utils.exception;
import servlib.utils.XMLoader;

class ManifestError : StrutsException {

    this (Balise balise) {
	super ("Erreur : Manifest, " ~ balise.toStr ());
    }    

}
