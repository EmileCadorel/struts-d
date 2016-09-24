module utils.lexermod.Word;
import std.conv;

struct Word {
    string str = "";
    bool isKey = false;
    int line = 0;
    int column = 0;

    void reset() {
	str = "";
	isKey = false;
    }

    string toStr () {
	return str ~ "(" ~ to!string (line) ~ ":" ~ to!string(column) ~ ")";
    }
}

