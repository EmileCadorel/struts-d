module servlib.utils.lexermod.LexerString;
import std.range : take;
import std.algorithm : equal, find;
import std.stdio, std.conv;
import std.outbuffer;
import std.string;
import std.container;
import std.file;
import servlib.utils.lexermod.Word;

/**
 Lexer permettant le decoupe d'une string a partir de token
*/
class LexerString {

    /**
     Params:
     data, le contenu a lexer
     */
    this(string data) {
	this.file = data;
	this.currentChar = 0;
	this.currentWord = -1;
    }

    /**
     Params:
     keys, les tokens qui vont couper la chaine
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
	this.skip = skip;
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
	if(this.currentWord >= (cast(int)read.length()) - 1) {
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
     Retire une cle de la table des cles
     Params: 
     which, l'element a supprime     
     */
    void removeKey (string which) {
	auto aux = keys[];
	keys.clear();
	foreach (string elem ; aux) {
	    if (elem != which)
		keys.insertBack (elem);
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
     Retourne la suite de la chaine en fonction d'une taille,
     getNext sera affecte par cette fonction.
     Params:
     size, le nombre de char a prendre
     Return:
     la chaine retourne
     */
    char [] getBytes (int size) {
	auto ret = cast(char[])file [currentChar .. currentChar + size];
	currentChar += size;
	return ret;
    }
    
    private bool getWord (ref Word word) {
	if (currentChar >= file.length) {
	    return false;
	}
	auto line = file[currentChar .. file.length];
	int max = 0, beg = to!int(line.length);
	foreach (string it ; keys) {
	    long id = indexOf(line, it);
	    if(id != -1) {
		if(id < beg) { beg = to!int(id); max = to!int(it.length); }
		else if (id == beg && to!int(it.length) > max)
		    max = to!int(it.length);
	    }
	}

	if(beg == to!int(line.length) + 1) {
	    word.str = line;
	    currentChar = file.length;
	} else if (beg == 0) {
	    word.str = line[0 .. max];
	    word.isKey = true;
	    currentChar += max;
	} else if (beg > 0) {
	    word.str = line[0 .. beg];
	    currentChar += beg;
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
     Ajoute un element dans la table des cles
     Params:
     name, la cle
     */
    void addKey (string name) {
	keys.insertBack (name);
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
     le fichier (les element lus) formate dans une string
     */
    string toStr () {
	OutBuffer buf = new OutBuffer;
	Array!ulong sizes;
	foreach (word ; read) {
	    buf.write(word.toString ~ " ");
	    sizes.insertBack( word.toString.length + 1 );
	}
	buf.write("\n");
	return buf.toString;
    }

    ~this() {
    }

    private {	
	string filename;
	string file;
	ulong currentChar;
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


