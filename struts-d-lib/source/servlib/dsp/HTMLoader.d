module servlib.dsp.HTMLoader;

import servlib.utils.xml;
import servlib.dsp.HtmlTagParser;

class HTMLoader {

    /**
     Charge tout les elements du fichier de type dsp, effectue les changements a l'aide des parser enregistre
     Params:
     filename, le nom du fichier .dsp
     app, le path de l'application courante
     Return:
     L'element root du nouveau fichier html transforme
     */
    static Balise load (string filename, string app) {
	return null;
    }

    /**
     Enregistre un tag parser dans les informations de transformateur
     Params:
     tagName, l'identifiant du tag qui va utiliser le parser
     parser, le parser qui va servir a la transformation     
     */
    static void addParser (Identifiant tagName, HtmlTagParser parser) {
    }       

    private string ROOTDIR = "web-inf/";    
}
