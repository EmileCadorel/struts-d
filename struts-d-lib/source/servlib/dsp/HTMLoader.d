module servlib.dsp.HTMLoader;

import servlib.utils.xml;
import servlib.dsp.HtmlTagParser;
import std.container, std.path;
import servlib.utils.Log;
import servlib.utils.exception;
import servlib.control.Session;
import std.stdio;
import servlib.utils.Singleton;

class HTMLoader {

    /**
     Charge tout les elements du fichier de type dsp, effectue les changements a l'aide des parser enregistre
     Params:
     filename, le nom du fichier .dsp
     app, le path de l'application courante
     Return:
     L'element root du nouveau fichier html transforme
    */
    Balise load (string filename, string app, Session session) {
	try {
	    Balise root = XMLoader.root (buildPath(app,ROOTDIR,filename));
	    Balise[] dom = executeParser(root, app, session);
	    if (dom.length == 1){
		return dom [0];
	    }else{
		root = new Balise (Identifiant.eof, make!(Array!Balise) (dom));
	    }
	} catch (StrutsException e) {
	    Log.instance.addError(e.toString());
	}
	return null;
    }

    Balise[] executeParser (Balise balise, string app, Session session) {
	auto it = (balise.name.toXml in _tagParser);
	if (it !is null) {
	    return it.execute (balise, &executeParser, app, session);	
	} else {
	    Array!Balise final_childs;
	    foreach (child ; balise.childs) {
		auto childs = executeParser (child, app, session);
		foreach (itch ; childs)
		    final_childs.insertBack (itch);
	    }
	    balise.childs = final_childs;
	    return [balise];
	}
    }

    /**
     Enregistre un tag parser dans les informations de transformateur
     Params:
     tagName, l'identifiant du tag qui va utiliser le parser
     parser, le parser qui va servir a la transformation     
    */
    void addParser (string id, HtmlTagParser parser) {
	Log.instance.addInfo ("Ajout du modifieur " ~ id);
	_tagParser[id] = parser;
    }       

    mixin Singleton!HTMLoader;
    
    private{
	string ROOTDIR = "web-inf";
	HtmlTagParser [string] _tagParser;    
    }
}
