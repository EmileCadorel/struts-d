module servlib.dsp.HTMLoader;

import servlib.utils.XMLoader;
import servlib.dsp.HtmlTagParser;
import std.container, std.path;
import servlib.utils.Log;
import servlib.utils.exception;
import servlib.control.Session;

class HTMLoader {

  /**
     Charge tout les elements du fichier de type dsp, effectue les changements a l'aide des parser enregistre
     Params:
     filename, le nom du fichier .dsp
     app, le path de l'application courante
     Return:
     L'element root du nouveau fichier html transforme
  */
  static Balise load (string filename, string app, Session session) {
    try {
      Balise root = XMLoader.root (buildPath(app,ROOTDIR,filename));
      Balise[] dom = executeParser(root, session);
      if (dom.length == 1){
	return dom [0];
      }else{
	root = new Balise (Identifiant.eof, make!(Array!Balise) (dom));
      }
    } catch (StrutsException e) {
      Log.instance.add_err(e.toString());
    }
    return null;
  }

 static Balise[] executeParser (Balise balise, Session session) {
      auto it = (balise.name.toXml in _tagParser);
      if (it !is null) {
	return it.execute (balise, &executeParser, session);	
      } else {
	Array!Balise final_childs;
	foreach (child ; balise.childs) {
	  auto childs = executeParser (child, session);
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
  static void addParser (string id, HtmlTagParser parser) {
    Log.instance.add_info ("Ajout du modifieur " ~ id);
    _tagParser[id] = parser;
  }       

  private{
    static string ROOTDIR = "web-inf";
    static HtmlTagParser [string] _tagParser;    
  }
}
