module servlib.utils.lexermod.Word;
import std.conv;

/**
 Un mot lu par un lexer
*/
struct Word {

    /// le contenu du mot
    string str = "";

    /// Est une cle (donne au lexer)
    bool isKey = false;

    /// la ligne du mot (pas forcement renseigne, depend du lexer
    int line = 0;

    /// la colonne du mot (pas forcement renseigne, depend du lexer
    int column = 0;

    /**
     Remet a zero les informations du mot
     */
    void reset() {
	str = "";
	isKey = false;
    }

    string toString () {
	return str ~ "(" ~ to!string (line) ~ ":" ~ to!string(column) ~ ")";
    }
}

