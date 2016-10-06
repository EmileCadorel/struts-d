module servlib.utils.lexermod.LexerFile;
import servlib.utils.exception;
import std.range : take;
import std.algorithm : equal, find;
import std.stdio, std.conv;
import std.outbuffer;
import std.string;
import std.container;
import std.file, std.conv;
import servlib.utils.lexermod.Word;

/**
 Lexer permettant le decoupage d'un fichier, a partir de token
*/
class LexerFile {

    /**
     Params:
     fileName, le path du fichier a lire
     */
    this(string fileName) {
	try {
	    this.filename = fileName;
	    this.currentWord = -1;
	    this.line = 1;
	    this.column = 1;
	    if (fileName.isDir) throw new NoSuchFile (filename);
	    this.file = File(fileName, "r");
	} catch (Throwable o) {
	    throw new NoSuchFile (filename);
	}
    }

    /**
     Le path du fichier en cours de lecture
     */
    string getFileName () {
	return this.filename;
    }

    /**
     Params:
     keys, les tokens qui vont couper le fichiers
     */
    void setKeys (Array!string keys) {
	foreach (string it ; keys) {
	    this.keys.insertBack(it);
	}
    }

    /**
     Params:
     skip, les tokens qui vont etre ignore dans la lecture du fichier
     */
    void setSkip(Array!string skip) {
	this.skip.clear ();
	foreach(string it ; skip) {
	    this.skip.insertBack(it);
	}
    }

    /**
     Ajoute un element de commentaire
     Params:
     beg, la chaine qui va definir un debut de commentaire
     stop, la fin du commentaire
     */
    void addComment (string beg, string stop) {
	this.comment.insertBack(make!(Array!string)(beg, stop));
    }

    /**
     Retourne le mot suivant
     Params:
     ret, Le mot qui va etre renvoye par effet de bort
     Return:
     Un mot a ete lu, ou faux si EOF
     */
    bool getNext(ref Word ret) {
	Word word;
	if(this.currentWord >= read.length() - 1) {
	    do {
		word.reset();
		if(!getWord (word)) { word.str = ""; break; }

		string come = null;
		if((come = isComment(word)) !is null && commentsOn) {
		    do {
			word.reset();
			if(!getWord (word)) { word.str = ""; break; }
		    } while (word.str != come && word.str != "");
		    if(!getWord (word)) { word.str = ""; break; }
		}
	    } while (isSkip(word) && word.str != "");

	    if(word.str != "") {
		currentWord++;
		read.insertBack (word);
		ret = word;
		return true;
	    } else {
		currentWord++;
		return false;
	    }
	} else {
	    currentWord++;
	    ret = read[currentWord];
	    return true;
	}
    }

    /**
     Params:
     on, les commentaire doivent-ils etre pris en compte
     */
    void setComments (bool on) {
	commentsOn = on;
    }

    /**
     Enleve un element de la table des element ignore
     Params:
     which, l'element qui ne doit plus etre ignore
     */
    void removeSkip (string which) {
	auto aux = skip[];
	skip.clear();
	foreach (string elem ; aux) {
	    if (elem != which)
		skip.insertBack (elem);
	}
    }

    /**
     Reviens en arriere
     Params:
     nb, le nombre de mot a rembobiner
     */
    void rewind(int nb = 1) {
	currentWord -= nb;
    }

    /**
     Retourne le contenu d'une ligne en fonction de son numero
     Params:
     line, le numero de la ligne
     line_str, la ligne a retourner par effet de bord
     Return:
     Faux, si EOF
     */
    bool getLine(int line, ref string line_str) {
	file.seek(0);
	string cline = null;
	for(int nb = 1; nb <= line; nb++) cline = file.readln();
	if (file.eof() || cline is null) return false;
	else line_str = cline;
	return true;
    }
   
    private bool getWord (ref Word word) {
	ulong where = file.tell();
	string line = file.readln();
	if(file.eof() || line is null) return false;
	int max = 0, beg = to!int(line.length);
	foreach (string it ; keys) {
	    long id = indexOf(line, it);
	    if(id != -1) {
		if(id < beg) { beg = to!int(id); max = to!int(it.length); }
		else if (id == beg && to!int(it.length) > max)
		    max = to!int(it.length);
	    }
	}

	if(beg == to!int(line.length) + 1)
	    word.str = line;
	else if (beg == 0) {
	    word.str = line[0 .. max];
	    word.isKey = true;
	    file.seek(where + max);
	} else if (beg > 0) {
	    word.str = line[0 .. beg];
	    file.seek(where + beg);
	}

	word.line = this.line;
	word.column = this.column;

	if(word.isKey && (word.str == "\n" || word.str == "\r")) {
	    this.line++;
	    this.column = 1;
	} else {
	    this.column += word.str.length;
	}
	return true;
    }

    private bool isSkip(in Word word) {
	foreach (string s ; skip) {
	    if (word.str == s) return true;
	}
	return false;
    }

    private string isComment(in Word word) {
	foreach (Array!string s ; comment) {
	    if (word.str == s[0]) return s[1];
	}
	return null;
    }

    /**
     Ajoute un element dans la table a ignore
     Params:
     name, l'element a ignore
     */
    void addSkip (string name) {
	skip.insertBack(name);
    }

    /**
     le fichier (les element lus et l'emplacement courant) formate dans une string
     */
    string toStr () {
	OutBuffer buf = new OutBuffer;
	Array!ulong sizes;
	foreach (word ; read) {
	    buf.write(word.toString ~ " ");
	    sizes.insertBack( word.toString.length + 1 );
	}
	buf.write("\n");
	foreach (it ; 0 .. currentWord + 1) {
	    buf.write (rightJustify ("", sizes[it], ' '));
	}
	buf.write("^\n");
	return buf.toString;
    }

    /**
     Ferme le fichier
     */
    ~this() {
	file.close();
    }

    private {
	string filename;
	File file;
	int line;
	int column;
	int currentWord;
	bool commentsOn = true;
	Array!string keys;
	Array!string skip;
	Array!(Array!string) comment;
	Array!Word read;
    }
}


