module utils.XMLoader;
import utils.LexerFile;
import std.outbuffer, std.traits;
import std.conv : to;
import std.container;

struct Location {
    string filename;
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

class ProcInst : Balise {
    this (string name, Location locate) {
	super (name, locate);	
    }
}

class Text : Balise {
    this (string content, Location locate) {
	super ("", locate);
	this.content = content;
    }
    
    string content;    
}

enum XMLTokens : string {
    START = "<",
    END = ">",
	SSTART = "</",
	SEND = "/>",
	SEMI_COLON = ":",
	START_COMMENT = "<!--",
	END_COMMENT = "-->",
	START_PROC = "<?",
	END_PROC = "?>"
}

class XMLSyntaxError : Exception {
    
    string RESET = "\u001B[0m";
    string PURPLE = "\u001B[46m";
    string RED = "\u001B[41m";
    string GREEN = "\u001B[42m";

    this (LexerFile file, Word word) {
	super ("");
	OutBuffer buf = new OutBuffer();
	string line;
	buf.write (RED);
	buf.write ("Erreur de syntaxe " ~ RESET ~ ":");
	buf.write (file.getFileName());
	buf.write (":(" ~ to!string(word.line) ~ ", " ~ to!string(word.column) ~ ") : ");
	buf.write ("'" ~ word.str ~ "'\n");
	if (!file.getLine (word.line, line)) {
	    buf.write ("Fin de fichier inattendue\n");
	} else {
	    int j = 0;
	    for(; j < word.column - 1 && j < line.length; j++) buf.write (line[j]);
	    buf.write(GREEN);
	    for(; j < word.str.length + word.column - 1  && j < line.length; j++) buf.write (line[j]);
	    buf.write (RESET);
	    for(; j < line.length; j++) buf.write (line[j]);
	    
	    for(int i = 0; i < word.column - 1 && i < line.length; i++) {
		if (line [i] == '\t') buf.write ('\t');
		else buf.write (" ");
	    }
	    for(int i = 0; i < word.str.length; i++) buf.write ("^");
	    buf.write ("\n");
	}
	msg = buf.toString();
    }
    
}


class XMLoader {

    
    this (string filename) {
	this.filename = filename;
    }

    /**
     Analyse lexical du fichier, et retourne la balise de la racine
     Return:
     la balise racine, 
     (si le fichier possede plusieurs racine, retourne une racine eof avec les autres racine en enfant)
     */
    Balise root () {
	LexerFile lex = new LexerFile (this.filename);
	lex.setKeys (make!(Array!string)([EnumMembers!XMLTokens, " ", "\n", "\r"]));
	lex.setSkip (make!(Array!string)([" ", "\n", "\r"]));
	lex.addComment (XMLTokens.START_COMMENT, XMLTokens.END_COMMENT);

	Array!Balise roots;
	Word word;
	while ((lex.getNext (word)) == true) {
	    if (word.str == XMLTokens.START)
		roots.insertBack (readOpen (lex));
	    else if (word.str == XMLTokens.START_PROC)
		roots.insertBack (readProc (lex));
	    else throw new XMLSyntaxError (lex, word);
	}
	return make_eof ();
    }        
    
    private {

	static Balise make_eof () {
	    return new Balise ("", Location ("", -1, -1));
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
	 <? b ?>
	 ----
	 */
	Balise readProc (LexerFile file) {
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

	string filename;
	
    }
    
    
}
