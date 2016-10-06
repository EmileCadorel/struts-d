module servlib.utils.exceptionmod.XMLSyntaxError;
import servlib.utils.exception;
import servlib.utils.lexer;
import servlib.utils.Log;
import std.outbuffer, std.conv;

/**
 Erreur de syntaxe dans une fichier XML
*/
class XMLSyntaxError : StrutsException {

    string RESET = "\u001B[0m";
    string PURPLE = "\u001B[46m";
    string RED = "\u001B[41m";
    string GREEN = "\u001B[42m";

    this (LexerFile file, Word word) {
	super ("");
	OutBuffer buf = new OutBuffer();
	string line;
	buf.write ("Syntaxe :");
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
	Log.instance.addError (msg);
    }

}
