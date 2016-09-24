module utils.XMLoader;
import utils.lexer;
import std.outbuffer, std.traits;
import std.conv : to;
import std.container, std.string, std.stdio;

struct Location {
    string filename;
    long line;
    long column;    
}

class Identifiant {
    string name;
    Identifiant space;
    Location locate;
    
    this (string name, Location locate) {
	this.name = name;
	this.locate = locate;
    }

    this (string name, Identifiant space, Location locate) {
	this.name = name;
	this.space = space;
	this.locate = locate;
    }

    static Identifiant eof () {
	return new Identifiant ("", Location("", -1, -1));
    }

    bool opEquals (Object other_) {
	Identifiant other = cast(Identifiant) other_;
	if (other is null) return false;
	if (this.space !is null) {
	    return this.name == other.name && this.space == other.space;
	} else {
	    return this.name == other.name;
	}
    }


    string toString () {
	if (space !is null)
	    return space.toSimpleString() ~ ":" ~ name ~ "!" ~ to!string (locate);
	else return name ~ "!" ~ to!string (locate);
    }

    private {
	string toSimpleString () {
	    return this.name;
	}
    }
}

class Balise {

    this (Identifiant name) {
	this.name = name;
    }
    
    this (Identifiant name, string [Identifiant] attrs) {
	this.name = name;
	this.attrs = attrs;
    }
    
    this (Identifiant name, Array!Balise childs) {
	this.name = name;
	this.childs = childs;
    }
    
    this (Identifiant name, string [Identifiant] attrs, Array!Balise childs) {
	this.name = name;
	this.attrs = attrs;
	this.childs = childs;
    }
    
    Identifiant name;
    string [Identifiant] attrs;
    Array!Balise childs;

    string toString (int nb = 0) {
	OutBuffer buf = new OutBuffer();
	buf.write (rightJustify("", nb, ' '));
	buf.write (this.name.toString ());
	buf.write (" ~> ");
	foreach (key, value ; attrs) {
	    buf.write (key.toString ());
	    buf.write ("=[");
	    buf.write (value);
	    buf.write ("]");
	}
	buf.write ('\n');
	foreach (it ; childs) {
	    buf.write (it.toString(nb + 4));
	    buf.write ("\n");
	}
	return buf.toString ();
    }
    
}

class ProcInst : Balise {
    this (Identifiant name, string[Identifiant] attrs) {
	super (name, attrs);	
    }
}

class Text : Balise {
    this (string content) {
	super (Identifiant.eof);
	this.content = content;
    }

    override string toString (int nb = 0) {
	OutBuffer buf = new OutBuffer;
	buf.write (rightJustify("", nb, ' '));
	buf.write ("[");
	buf.write (content);
	buf.write ("]");
	return buf.toString ();
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
	END_PROC = "?>",
	EQUAL = "=",
	QUOT = "\""
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
	
	if (roots.length == 1) {
	    return roots[0];
	} else {
	    return new Balise (Identifiant.eof, roots);
	}
    }        
    
    private {

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
	Balise readOpen (LexerFile file) {
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
		if (word.str == XMLTokens.START)
		    childs.insertBack (readOpen (file));
		else if (word.str == XMLTokens.SSTART) {
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
	Identifiant readIdentifiant (LexerFile file) {
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

	Identifiant readIdentifiant (LexerFile file, Identifiant space) {
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
	Balise readProc (LexerFile file) {
	    return make_eof ();
	}
	
	/**
	 Examples:
	 ----
	 <b attr="value"/>
	 // ^^^^^^^^^^^^
	 ----
	 */
	void readAttr (LexerFile file, ref string [Identifiant] attrs) {
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
	string readValue (LexerFile file) {
	    Word word;
	    string total;
	    file.setSkip (make!(Array!string)());
	    while (true) {
		auto end = file.getNext (word);
		if (!end) throw new XMLSyntaxError (file, word);
		if (find ([EnumMembers!XMLTokens], word.str) != []) {
		    file.rewind ();
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
	Balise readText (LexerFile file) {
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

	string filename;
	
    }
    
    
}
