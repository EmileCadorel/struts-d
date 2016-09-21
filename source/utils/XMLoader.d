module utils.XMLoader;
import utils.LexerFile;

struct Location {
    long line;
    long column;
}

class Balise {

    this (string name, Location locate) {
	this.name = name;
	this.location = locate;
    }
    
    string name;
    string [string] attrs;
    Balise [] childs;
    Location location;
}

class Text : Balise {
    this (string content, Location locate) {
	super ("", locate);
	this.content = content;
    }
    
    string content;    
}

class XMLoader {

    this (string filename) {}

    /**
     Analyse lexical du fichier, et retourne la balise de la racine
     Return:
     la balise racine, 
     (si le fichier possede plusieurs racine, retourne une racine eof avec les autres racine en enfant)
     */
    Balise root () {
	return make_eof ();
    }        
    
    private {

	static Balise make_eof () {
	    return new Balise ("", Location (-1, -1));
	}
	
	/**
	 Examples:
	 ----	 
	    <b>
	 // ^^^
	 // ou :
	    <b/>
	 // ^^^^
	 ----
	 */
	Balise readOpen (LexerFile file) {
	    return make_eof ();
	}

	/**
	 Examples:
	 ----
	    </b>
	 // ^^^^
	 ----
	 */
	Balise readClose (LexerFile file) {
	    return make_eof ();
	}

	/**
	 Examples:
	 ----
	 <b attr="value"/>
	 // ^^^^^^^^^^^^
	 ----
	 */
	string readAttr (LexerFile file) {
	    return "";
	}

	/**
	 Examples:
	 ----
	 <b attr="value"/>
	 //      ^^^^^^^
	 ----
	 */
	string readValue (LexerFile file) {
	    return "";
	}

	/**
	 Examples:
	 ----
	 <> content </>
	 // ^^^^^^^
	 ----
	 */
	string readContent (LexerFile file) {
	    return "";
	}
	
    }
    
    
}
