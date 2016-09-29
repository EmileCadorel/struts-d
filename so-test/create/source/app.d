import std.stdio;
import std.conv;

class Test {
    this (int a) {
	this.a = a;
    }
    
    int a;

    string toString () {
	return "Ici:Test " ~ to!string(a);
    }
}


void call (Test data) {
    writeln(data);   
}

extern (C) {
    void load (Test data) {
	call (data);
    }
}
