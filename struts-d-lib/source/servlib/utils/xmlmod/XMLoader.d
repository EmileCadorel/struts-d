module servlib.utils.xmlmod.XMLoader;
import servlib.utils.lexer;
import std.outbuffer, std.traits;
import std.conv : to;
import std.container, std.string, std.stdio;
import servlib.utils.exception;
import std.algorithm : equal, find;
import servlib.utils.xml;


enum XMLTokens : string {
    START = "<",
    END = ">",
	SSTART = "</",
	SEND = "/>",
	SEMI_COLON = ":",
	START_COMMENT = "<!--",
	END_COMMENT = "-->",
	START_PROC = "<?",
	END_PROC = "?>",
	EQUAL = "=",
	QUOT = "\""
}

class XMLoader {

    /**
     Analyse lexical du fichier, et retourne la balise de la racine
     Return:
     la balise racine,
     (si le fichier possede plusieurs racine, retourne une racine eof avec les autres racine en enfant)
     */
    static Balise root (string filename) {
	LexerFile lex = new LexerFile (filename);
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

	if (roots.length == 1) {
	    return roots[0];
	} else {
	    return new Balise (Identifiant.eof, roots);
	}
    }

    private {

	this () {}

	static Balise make_eof () {
	    return new Balise (Identifiant.eof);
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
	static Balise readOpen (LexerFile file) {
	    Identifiant id = readIdentifiant (file);
	    Word word;
	    Array!Balise childs;
	    string [Identifiant] attrs;
	    while (true) {
		auto end = file.getNext (word);
		if (!end) throw new XMLSyntaxError (file, word);
		if (word.str == XMLTokens.END) break;
		else if (word.str == XMLTokens.SEND)
		    return new Balise (id, attrs);
		else {
		    file.rewind ();
		    readAttr (file, attrs);
		}
	    }

	    while (true) {
		auto end = file.getNext (word);
		if (!end) throw new XMLSyntaxError (file, word);
		if (word.str == XMLTokens.START) {
		    childs.insertBack (readOpen (file));
		} else if (word.str == XMLTokens.SSTART) {
		    Identifiant close_id = readIdentifiant (file);
		    if (close_id != id)
			throw new XMLSyntaxError (file, word);
		    if (!file.getNext (word) || word.str != XMLTokens.END)
			throw new XMLSyntaxError (file, word);
		    return new Balise (id, attrs, childs);
		} else {
		    file.rewind ();
		    childs.insertBack (readText (file));
		}
	    }

	}

	/**
	 Tout ce qui est nom de balise, variable...
	 */
	static Identifiant readIdentifiant (LexerFile file) {
	    Word word;
	    auto end = file.getNext (word);
	    if (!end) throw new XMLSyntaxError (file, word);
	    string name = word.str;
	    Location locate = Location(file.getFileName(), word.line, word.column);
	    if (!file.getNext (word))
		throw new XMLSyntaxError (file, word);
	    if (word.str == XMLTokens.SEMI_COLON)
		return readIdentifiant (file, new Identifiant (name, locate));
	    file.rewind ();
	    return new Identifiant (name, locate);
	}

	static Identifiant readIdentifiant (LexerFile file, Identifiant space) {
	    Word word;
	    auto end = file.getNext (word);
	    if (!end) throw new XMLSyntaxError (file, word);
	    string name = word.str;
	    Location locate = Location(file.getFileName(), word.line, word.column);
	    if (!file.getNext (word))
		throw new XMLSyntaxError (file, word);
	    if (word.str == XMLTokens.SEMI_COLON)
		return readIdentifiant (file, new Identifiant (name, space, locate));
	    file.rewind ();
	    return new Identifiant (name, space, locate);
	}

	/**
	 Examples:
	 ----
	 <? b ?>
	 ----
	 */
	static Balise readProc (LexerFile file) {
	    return make_eof ();
	}

	/**
	 Examples:
	 ----
	 <b attr="value"/>
	 // ^^^^^^^^^^^^
	 ----
	 */
	static void readAttr (LexerFile file, ref string [Identifiant] attrs) {
	    Identifiant id = readIdentifiant (file);
	    Word word;
	    if (!file.getNext (word) || word.str != XMLTokens.EQUAL)
		throw new XMLSyntaxError (file, word);
	    string value = readValue (file);
	    attrs[id] = value;
	}

	/**
	 Examples:
	 ----
	 <b attr="value"/>
	 //      ^^^^^^^
	 ----
	 */
	static string readValue (LexerFile file) {
	    Word word;
	    string total;
	    if (!file.getNext (word) || word.str != XMLTokens.QUOT)
		throw new XMLSyntaxError (file, word);
	    file.setSkip (make!(Array!string)());
	    while (true) {
		auto end = file.getNext (word);
		if (!end) throw new XMLSyntaxError (file, word);
		if (word.str == XMLTokens.QUOT) {
		    file.setSkip (make!(Array!string)(" ", "\n", "\r"));
		    return (total);
		} else {
		    if (word.str == "\n" || word.str == "\r") total ~= " ";
		    else total ~= word.str;
		}
	    }
	}

	/**
	 Examples:
	 ----
	 <> content </>
	 // ^^^^^^^
	 ----
	 */
	static Balise readText (LexerFile file) {
	    Word word;
	    string total;
	    file.setSkip (make!(Array!string)());
	    while (true) {
		auto end = file.getNext (word);
		if (!end) throw new XMLSyntaxError (file, word);
		if (find ([EnumMembers!XMLTokens], word.str) != []) {
		    file.rewind ();
		    file.setSkip (make!(Array!string)(" ", "\n", "\r"));
		    return new Text (total);
		} else {
		    if (word.str == "\n" || word.str == "\r") total ~= " ";
		    else total ~= word.str;
		}
	    }
	}	
    }
    
}
