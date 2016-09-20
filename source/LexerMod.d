module LexerMod;
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
    
    void reset() {
	str = "";
	isKey = false;
    }

    string toString () {
	int [] total;
	foreach (it ; this.str)
	    total ~= [to!int (it)];	
	return "[" ~ to!string (total) ~ "]";
    }
    
}

class Lexer {
    
    this(string data) {
	this.file = data;
	this.currentChar = 0;
	this.currentWord = -1;
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

    bool getWord (ref Word word) {
	if (currentChar >= file.length - 1) {
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
    }
    
    //private:

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


