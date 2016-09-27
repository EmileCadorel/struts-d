module utils.exceptionmod.XMLSyntaxError;
import utils.exception;
import utils.lexer;
import std.outbuffer, std.conv;


class XMLSyntaxError : StrutsException {

    this (LexerFile file, Word word) {
	super ("");
	OutBuffer buf = new OutBuffer();
	string line;
	buf.write ("Erreur de syntaxe :");
	buf.write (file.getFileName());
	buf.write (":(" ~ to!string(word.line) ~ ", " ~ to!string(word.column) ~ ") : ");
	buf.write ("'" ~ word.str ~ "'\n");
	if (!file.getLine (word.line, line)) {
	    buf.write ("Fin de fichier inattendue\n");
	} else {
	    int j = 0;
	    for(; j < word.column - 1 && j < line.length; j++) buf.write (line[j]);
	    for(; j < word.str.length + word.column - 1  && j < line.length; j++) buf.write (line[j]);
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
