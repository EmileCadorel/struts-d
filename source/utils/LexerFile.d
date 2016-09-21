module utils.LexerFile;
import utils.Exception;
import std.range : take;
import std.algorithm : equal, find;
import std.stdio, std.conv;
import std.outbuffer;
import std.string;
import std.container;
import std.file;

struct Word {
    string str = "";
    bool isKey = false;
    int line = 0;
    int column = 0;
    
    void reset() {
	str = "";
	isKey = false;
    }
    
    string toString () {
	return str ~ "(" ~ to!string (line) ~ ":" ~ to!string(column) ~ ")";
    }
}

class LexerFile {
    
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

    string getFileName () {
	return this.filename;
    }
    
    
    void setKeys (Array!string keys) {
	foreach (string it ; keys) {
	    this.keys.insertBack(it);
	}
    }

    void setSkip(Array!string skip) {
	foreach(string it ; skip) {
	    this.skip.insertBack(it);
	}
    }

    void addComment (string beg, string stop) {
	this.comment.insertBack(make!(Array!string)(beg, stop));
    }

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

    void setComments (bool on) {
	commentsOn = on;
    }

    void removeSkip (string which) {
	auto aux = skip[];
	skip.clear();
	foreach (string elem ; aux) {
	    if (elem != which)
		skip.insertBack (elem);
	}
    }
    
    
    void rewind(int nb = 1) {
	currentWord -= nb;
    }

    bool getLine(int line, ref string line_str) {
	file.seek(0);
	string cline = null;
	for(int nb = 1; nb <= line; nb++) cline = file.readln();
	if (file.eof() || cline is null) return false;
	else line_str = cline;
	return true;
    }

    bool getWord (ref Word word) {
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

    bool isSkip(in Word word) {
	foreach (string s ; skip) {
	    if (word.str == s) return true;
	}
	return false;
    }

    string isComment(in Word word) {
	foreach (Array!string s ; comment) {
	    if (word.str == s[0]) return s[1];
	}
	return null;
    }

    void addSkip (string name) {
	skip.insertBack(name);
    }        

    string toString () {
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
    
    ~this() {
	file.close();
    }
    
    //private:

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


